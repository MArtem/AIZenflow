import Foundation
import Observation
import SwiftUI
import UIKit

/// Owns Settings screen state and local data lifecycle actions.
///
/// Ownership:
/// Created by `AppComposition` and reused for the app lifetime.
///
/// Side effects:
/// Export and cleanup actions touch app-owned files. Delete-all removes SwiftData records,
/// app-owned files, temporary exports, and Core Spotlight indexes so private local content
/// does not survive the destructive flow in another local system surface.
@MainActor
@Observable
final class SettingsViewModel {
    private let repository: FieldbookRepository
    private let exportService: FieldbookExportService
    private let fileStore: AppFileStore
    private let spotlight: SpotlightIndexService
    private(set) var storageBytes: Int64 = 0
    private(set) var exportURL: URL?
    private(set) var errorMessage: String?
    private(set) var isWorking = false
    @ObservationIgnored private var exportTask: Task<Void, Never>?

    init(
        repository: FieldbookRepository,
        exportService: FieldbookExportService,
        fileStore: AppFileStore,
        spotlight: SpotlightIndexService
    ) {
        self.repository = repository
        self.exportService = exportService
        self.fileStore = fileStore
        self.spotlight = spotlight
    }

    func appeared() async { storageBytes = await fileStore.storageByteCount() }

    func cleanupTemporaryFilesTapped() async {
        guard !isWorking else { return }
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
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
    }

    func deleteAllConfirmed() async -> Bool {
        guard !isWorking else { return false }
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        var staged = StagedDeletionBatch.empty
        do {
            staged = try await fileStore.stageDeletion(
                repository.allFileReferences(),
                missingFilePolicy: .ignoreMissing
            )
            do { try repository.deleteAllData() }
            catch {
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
    }

    private func exportCancelled() {
        exportTask = nil
        isWorking = false
    }

    private func exportFailed() {
        errorMessage = String(localized: "Local data couldn’t be exported.")
        exportTask = nil
        isWorking = false
    }
}

/// Settings tab UI for privacy, storage, export, permissions, and destructive reset.
///
/// The view owns confirmation UI only. Storage/export/delete side effects are owned by
/// `SettingsViewModel`, and navigation reset after delete-all is delegated to app composition.
struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Bindable var viewModel: SettingsViewModel
    let localDataResetCompleted: () -> Void
    @State private var confirmsDeleteAll = false

    var body: some View {
        List {
            Section("Privacy") {
                Label("All content stays on this device.", systemImage: "lock.shield")
                Text(String(localized: "AI Fieldbook has no account, backend, analytics, or cloud processing in Iteration 1."))
                    .font(FieldbookTypography.supporting)
                    .foregroundStyle(.secondary)
                Text(String(localized: "System Spotlight indexing is disabled until a separate opt-in privacy control is added."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Storage") {
                LabeledContent("App-owned data", value: ByteCountFormatter.string(fromByteCount: viewModel.storageBytes, countStyle: .file))
                Button("Clean Temporary Files", systemImage: "trash.slash") { Task { await viewModel.cleanupTemporaryFilesTapped() } }
                    .disabled(viewModel.isWorking)
            }
            Section("Export") {
                Button("Prepare Local Export", systemImage: "square.and.arrow.up") { viewModel.exportTapped() }
                    .disabled(viewModel.isWorking)
                if let url = viewModel.exportURL { ShareLink(item: url) { Label("Share Export Folder", systemImage: "square.and.arrow.up") } }
            }
            Section("Permissions") {
                Button("Open App Settings", systemImage: "gear") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
                Text(String(localized: "Microphone access is requested only when you start recording."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Data Lifecycle") {
                Button("Delete All Local Data", systemImage: "trash", role: .destructive) { confirmsDeleteAll = true }
                    .disabled(viewModel.isWorking)
            }
            if viewModel.isWorking {
                ProgressView("Working")
            }
            if let error = viewModel.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(FieldbookColor.destructive)
                    .accessibilityLabel("Error: \(error)")
            }
        }
        .navigationTitle("Settings")
        .alert("Delete All Local Data?", isPresented: $confirmsDeleteAll) {
            Button("Delete Everything", role: .destructive) {
                Task {
                    if await viewModel.deleteAllConfirmed() {
                        localDataResetCompleted()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { Text(String(localized: "This permanently deletes every workspace, item, tag, and app-owned file.")) }
        .task { await viewModel.appeared() }
        .onDisappear { viewModel.disappeared() }
    }
}
