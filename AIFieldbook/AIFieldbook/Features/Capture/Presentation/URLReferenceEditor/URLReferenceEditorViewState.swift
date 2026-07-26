import Foundation

/// Render-ready state for the create/edit web-link form.
enum URLReferenceEditorViewState: Equatable {
    case loading(navigationTitle: String)
    case editing(URLReferenceEditorFormState)
    case saving(URLReferenceEditorFormState)
    case failure(form: URLReferenceEditorFormState, message: String)

    var form: URLReferenceEditorFormState? {
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

struct URLReferenceEditorFormState: Equatable {
    let navigationTitle: String
    let selectedWorkspaceID: UUID?
    let workspaces: [URLReferenceEditorWorkspaceOptionState]
    let title: String
    let urlText: String
    let notes: String
    let canSave: Bool
    let usesInsecureHTTP: Bool
}

struct URLReferenceEditorWorkspaceOptionState: Identifiable, Equatable {
    let id: UUID
    let title: String
}
