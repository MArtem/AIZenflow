import Foundation
import Observation

/// Owns Workspace tab list state.
///
/// Ownership:
/// Created by `AppComposition` and reused for the app scene lifetime.
///
/// Failure behavior:
/// Loading failures keep the previous list when present and expose a localized error for the
/// view to render.
@Observable
@MainActor
final class WorkspaceListViewModel {
    private let repository: FieldbookRepository

    private(set) var workspaces: [WorkspaceSummary] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository) {
        self.repository = repository
    }

    func appeared() {
        reloadRequested()
    }

    func reloadRequested() {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            workspaces = try repository.fetchWorkspaces()
        } catch {
            errorMessage = String(localized: "Your workspaces couldn’t be loaded.")
        }
    }
}

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
    let workspaceID: UUID

    private(set) var detail: WorkspaceDetailState?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository, fileStore: AppFileStore, workspaceID: UUID) {
        self.repository = repository
        self.fileStore = fileStore
        self.workspaceID = workspaceID
    }

    func appeared() {
        reloadRequested()
    }

    func reloadRequested() {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            detail = try repository.fetchWorkspaceDetail(id: workspaceID)
        } catch {
            errorMessage = String(localized: "This workspace couldn’t be loaded.")
        }
    }

    func deleteConfirmed() async -> Bool {
        errorMessage = nil
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
            errorMessage = String(localized: "The workspace couldn’t be deleted completely.")
            return false
        }
    }
}

/// Owns create/rename form state for a workspace.
///
/// Invariant:
/// Empty names are rejected, and rename is disabled until the value differs from the original
/// name captured at initialization.
@Observable
@MainActor
final class WorkspaceEditorViewModel {
    enum Mode {
        case create
        case rename(id: UUID, currentName: String)
    }

    private let repository: FieldbookRepository
    private let mode: Mode
    private let initialName: String

    var name: String
    private(set) var errorMessage: String?
    private(set) var isSaving = false

    init(repository: FieldbookRepository, mode: Mode) {
        self.repository = repository
        self.mode = mode
        switch mode {
        case .create:
            self.name = ""
            self.initialName = ""
        case let .rename(_, currentName):
            self.name = currentName
            self.initialName = currentName
        }
    }

    var navigationTitle: String {
        switch mode {
        case .create: String(localized: "New Workspace")
        case .rename: String(localized: "Rename Workspace")
        }
    }

    var canSave: Bool {
        !trimmedName.isEmpty && trimmedName != initialName
    }

    var hasUnsavedChanges: Bool {
        name != initialName
    }

    func saveTapped() -> Bool {
        guard !trimmedName.isEmpty else {
            errorMessage = String(localized: "Enter a workspace name.")
            return false
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            switch mode {
            case .create:
                try repository.createWorkspace(name: trimmedName)
            case let .rename(id, _):
                try repository.renameWorkspace(id: id, name: trimmedName)
            }
            return true
        } catch {
            errorMessage = String(localized: "The workspace couldn’t be saved.")
            return false
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
