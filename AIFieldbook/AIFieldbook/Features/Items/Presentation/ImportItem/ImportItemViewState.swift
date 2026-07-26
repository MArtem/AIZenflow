import Foundation

/// Render-ready state for an external-file import sheet.
enum ImportItemViewState: Equatable {
    case loading(kindTitle: String)
    case ready(ImportItemFormState)
    case empty(ImportItemFormState)
    case importing(ImportItemFormState)
    case failure(form: ImportItemFormState, message: String)

    var form: ImportItemFormState {
        switch self {
        case .loading:
            .empty
        case let .ready(form), let .empty(form), let .importing(form), let .failure(form, _):
            form
        }
    }

    var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }

    var isImporting: Bool {
        guard case .importing = self else { return false }
        return true
    }
}

struct ImportItemFormState: Equatable {
    static let empty = ImportItemFormState(kind: .image, selectedWorkspaceID: nil, workspaces: [], canChooseFile: false)

    let kind: ImportKind
    let selectedWorkspaceID: UUID?
    let workspaces: [ImportItemWorkspaceOptionState]
    let canChooseFile: Bool
}

struct ImportItemWorkspaceOptionState: Identifiable, Equatable {
    let id: UUID
    let title: String
}
