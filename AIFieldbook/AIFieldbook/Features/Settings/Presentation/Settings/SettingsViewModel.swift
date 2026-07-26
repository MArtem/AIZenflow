import Foundation
import Observation

/// Owns Settings screen state and local data lifecycle actions.
///
/// Created by `AppComposition` and reused for the app lifetime. Export and cleanup actions touch
/// app-owned files. Delete-all removes SwiftData records, app-owned files, temporary exports, and
/// Core Spotlight indexes before app composition resets runtime navigation.
@MainActor
@Observable
final class SettingsViewModel {
    private let repository: FieldbookRepository
    private let exportService: FieldbookExportService
    private let fileStore: AppFileStore
    private let spotlight: SpotlightIndexService
    private let stateBuilder: SettingsViewStateBuilder

    private var storageBytes: Int64 = 0
    private var exportURL: URL?
    private var errorMessage: String?
    private var isWorking = false
    @ObservationIgnored private var exportTask: Task<Void, Never>?

    private(set) var state: SettingsViewState

    init(
        repository: FieldbookRepository,
        exportService: FieldbookExportService,
        fileStore: AppFileStore,
        spotlight: SpotlightIndexService,
        stateBuilder: SettingsViewStateBuilder = SettingsViewStateBuilder()
    ) {
        self.repository = repository
        self.exportService = exportService
        self.fileStore = fileStore
        self.spotlight = spotlight
        self.stateBuilder = stateBuilder
        self.state = stateBuilder.state(
            storageBytes: 0,
            exportURL: nil,
            errorMessage: nil,
            isWorking: false
        )
    }

    func appeared() async {
        storageBytes = await fileStore.storageByteCount()
        state = displayState()
    }

    func cleanupTemporaryFilesTapped() async {
        guard !isWorking else { return }
        isWorking = true
        errorMessage = nil
        state = displayState()
        defer {
            isWorking = false
            state = displayState()
        }

        do {
            try await fileStore.recoverAbandonedStaging(activeReferences: repository.allFileReferences())
            await fileStore.cleanupExports()
            exportURL = nil
            storageBytes = await fileStore.storageByteCount()
        } catch {
            errorMessage = String(localized: "Temporary files need recovery before cleanup can continue.")
        }
    }

    func exportTapped() {
        guard !isWorking else { return }
        exportTask?.cancel()
        isWorking = true
        errorMessage = nil
        state = displayState()
        exportTask = Task { [weak self, exportService, fileStore] in
            do {
                let manifest = try await exportService.manifestData()
                try Task.checkCancellation()
                let exportURL = try await fileStore.createExport(manifest: manifest)
                let storageBytes = await fileStore.storageByteCount()
                if Task.isCancelled {
                    await fileStore.cleanupExports()
                    self?.exportCancelled()
                    return
                }
                self?.exportCompleted(url: exportURL, storageBytes: storageBytes)
            } catch is CancellationError {
                self?.exportCancelled()
            } catch {
                self?.exportFailed()
            }
        }
    }

    func disappeared() {
        exportTask?.cancel()
        exportTask = nil
        isWorking = false
        state = displayState()
    }

    func deleteAllConfirmed() async -> Bool {
        guard !isWorking else { return false }
        isWorking = true
        errorMessage = nil
        state = displayState()
        defer {
            isWorking = false
            state = displayState()
        }

        var staged = StagedDeletionBatch.empty
        do {
            staged = try await fileStore.stageDeletion(
                repository.allFileReferences(),
                missingFilePolicy: .ignoreMissing
            )
            do {
                try repository.deleteAllData()
            } catch {
                do {
                    try await fileStore.rollbackDeletion(staged)
                } catch {
                    throw AppFileStoreError.deletionRecoveryConflict
                }
                throw error
            }
            try await fileStore.commitDeletion(staged)
            await fileStore.cleanupExports()
            await spotlight.clear()
            exportURL = nil
            storageBytes = await fileStore.storageByteCount()
            return true
        } catch {
            errorMessage = String(localized: "Local data couldn’t be deleted completely.")
            return false
        }
    }

    private func exportCompleted(url: URL, storageBytes: Int64) {
        exportURL = url
        self.storageBytes = storageBytes
        exportTask = nil
        isWorking = false
        state = displayState()
    }

    private func exportCancelled() {
        exportTask = nil
        isWorking = false
        state = displayState()
    }

    private func exportFailed() {
        errorMessage = String(localized: "Local data couldn’t be exported.")
        exportTask = nil
        isWorking = false
        state = displayState()
    }

    private func displayState() -> SettingsViewState {
        stateBuilder.state(
            storageBytes: storageBytes,
            exportURL: exportURL,
            errorMessage: errorMessage,
            isWorking: isWorking
        )
    }
}
