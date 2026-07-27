import Foundation

/// Render-ready state for the create/rename workspace form.
enum WorkspaceEditorViewState: Equatable {
    case editing(WorkspaceEditorFormState)
    case saving(WorkspaceEditorFormState)
    case failure(form: WorkspaceEditorFormState, message: String)

    var form: WorkspaceEditorFormState {
        switch self {
        case let .editing(form), let .saving(form), let .failure(form, _):
            form
        }
    }

    var isSaving: Bool {
        guard case .saving = self else { return false }
        return true
    }

    var errorMessage: String? {
        guard case let .failure(_, message) = self else { return nil }
        return message
    }
}

struct WorkspaceEditorFormState: Equatable {
    let navigationTitle: String
    let name: String
    let canSave: Bool
    let hasUnsavedChanges: Bool
}
