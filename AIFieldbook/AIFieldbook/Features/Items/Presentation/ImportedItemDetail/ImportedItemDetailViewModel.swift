import Foundation
import Observation

/// Owns loading and deletion for one imported-item detail route.
///
/// `AudioPlaybackModel` deliberately remains a separate resource owner. It is created once for
/// this composition-owned route model and never becomes passive render state.
@Observable
@MainActor
final class ImportedItemDetailViewModel {
    private let repository: FieldbookRepository
    private let fileStore: AppFileStore
    private let stateBuilder: ImportedItemDetailViewStateBuilder
    let itemID: UUID
    let playbackModel = AudioPlaybackModel()

    private(set) var state: ImportedItemDetailViewState

    init(
        repository: FieldbookRepository,
        fileStore: AppFileStore,
        itemID: UUID,
        stateBuilder: ImportedItemDetailViewStateBuilder = ImportedItemDetailViewStateBuilder()
    ) {
        self.repository = repository
        self.fileStore = fileStore
        self.itemID = itemID
        self.stateBuilder = stateBuilder
        self.state = stateBuilder.loading()
    }

    func appeared() async {
        await reloadRequested()
    }

    func reloadRequested() async {
        let previousContent = state.content
        if previousContent == nil {
            state = stateBuilder.loading()
        }

        do {
            let detail = try repository.fetchImportedItem(id: itemID)
            let fileURL = try await fileStore.resolvedURL(for: detail.reference)
            state = stateBuilder.loaded(detail: detail, fileURL: fileURL)
        } catch let error as LocalizedError {
            applyLoadFailure(
                previousContent: previousContent,
                message: error.errorDescription ?? String(localized: "This item couldn’t be loaded.")
            )
        } catch {
            applyLoadFailure(
                previousContent: previousContent,
                message: String(localized: "This item couldn’t be loaded.")
            )
        }
    }

    func actionFailureDismissed() async {
        await reloadRequested()
    }

    func deleteConfirmed() async -> Bool {
        var staged = StagedDeletionBatch.empty

        do {
            let references = try repository.itemFileReferences(id: itemID)
            staged = try await fileStore.stageDeletion(references)
            do {
                try repository.deleteItem(id: itemID)
            } catch {
                do {
                    try await fileStore.rollbackDeletion(staged)
                } catch {
                    throw AppFileStoreError.deletionRecoveryConflict
                }
                throw error
            }
            try await fileStore.commitDeletion(staged)
            return true
        } catch {
            applyActionFailure(String(localized: "The item couldn’t be deleted completely."))
            return false
        }
    }

    private func applyLoadFailure(
        previousContent: ImportedItemDetailContentState?,
        message: String
    ) {
        if let previousContent {
            state = stateBuilder.actionFailure(content: previousContent, message: message)
        } else {
            state = stateBuilder.unavailable(message: message)
        }
    }

    private func applyActionFailure(_ message: String) {
        guard let content = state.content else {
            state = stateBuilder.unavailable(message: message)
            return
        }
        state = stateBuilder.actionFailure(content: content, message: message)
    }
}
