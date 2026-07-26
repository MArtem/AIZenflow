import Foundation
import Observation

/// Owns detail state and destructive deletion for one workspace.
///
/// Ownership:
/// Created by `AppComposition` for a workspace route and cached as runtime UI state.
///
/// Side effects:
/// Deletion stages app-owned files before removing SwiftData records, then commits file
/// deletion only after the repository mutation succeeds.
@Observable
@MainActor
final class WorkspaceDetailViewModel {
    private let repository: FieldbookRepository
    private let fileStore: AppFileStore
    private let stateBuilder: WorkspaceDetailViewStateBuilder
    let workspaceID: UUID

    private(set) var state: WorkspaceDetailViewState

    init(
        repository: FieldbookRepository,
        fileStore: AppFileStore,
        workspaceID: UUID,
        stateBuilder: WorkspaceDetailViewStateBuilder = WorkspaceDetailViewStateBuilder()
    ) {
        self.repository = repository
        self.fileStore = fileStore
        self.workspaceID = workspaceID
        self.stateBuilder = stateBuilder
        self.state = stateBuilder.loading()
    }

    func appeared() {
        reloadRequested()
    }

    func reloadRequested() {
        let previousContent = state.content
        if previousContent == nil {
            state = stateBuilder.loading()
        }

        do {
            state = stateBuilder.loaded(detail: try repository.fetchWorkspaceDetail(id: workspaceID))
        } catch {
            applyLoadFailure(previousContent: previousContent)
        }
    }

    func actionFailureDismissed() {
        reloadRequested()
    }

    func deleteConfirmed() async -> Bool {
        var staged = StagedDeletionBatch.empty
        do {
            let references = try repository.workspaceFileReferences(id: workspaceID)
            staged = try await fileStore.stageDeletion(references, missingFilePolicy: .ignoreMissing)
            do {
                try repository.deleteWorkspace(id: workspaceID)
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
            applyActionFailure(String(localized: "The workspace couldn’t be deleted completely."))
            return false
        }
    }

    private func applyLoadFailure(previousContent: WorkspaceDetailContentState?) {
        let message = String(localized: "This workspace couldn’t be loaded.")
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
