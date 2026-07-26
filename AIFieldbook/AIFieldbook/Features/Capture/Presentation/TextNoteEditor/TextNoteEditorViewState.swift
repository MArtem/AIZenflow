import Foundation

/// Render-ready state for the create/edit text-note form.
enum TextNoteEditorViewState: Equatable {
    case loading(navigationTitle: String)
    case editing(TextNoteEditorFormState)
    case saving(TextNoteEditorFormState)
    case failure(form: TextNoteEditorFormState, message: String)

    var form: TextNoteEditorFormState? {
        switch self {
        case .loading:
            nil
        case let .editing(form), let .saving(form), let .failure(form, _):
            form
        }
    }

    var navigationTitle: String {
        switch self {
        case let .loading(navigationTitle):
            navigationTitle
        case let .editing(form), let .saving(form), let .failure(form, _):
            form.navigationTitle
        }
    }

    var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }

    var isSaving: Bool {
        guard case .saving = self else { return false }
        return true
    }
}

struct TextNoteEditorFormState: Equatable {
    let navigationTitle: String
    let showsWorkspacePicker: Bool
    let workspaces: [TextNoteEditorWorkspaceOptionState]
    let title: String
    let body: String
    let selectedWorkspaceID: UUID?
    let canSave: Bool
    let hasUnsavedChanges: Bool
}

struct TextNoteEditorWorkspaceOptionState: Identifiable, Equatable {
    let id: UUID
    let title: String
}
