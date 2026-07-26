import Foundation

/// Render-ready state for the move-item destination sheet.
enum MoveItemViewState: Equatable {
    case loading
    case content(MoveItemFormState)
    case empty(MoveItemFormState)
    case moving(MoveItemFormState)
    case failure(form: MoveItemFormState, message: String)

    var form: MoveItemFormState {
        switch self {
        case .loading:
            .empty
        case let .content(form), let .empty(form), let .moving(form), let .failure(form, _):
            form
        }
    }

    var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }

    var isMoving: Bool {
        guard case .moving = self else { return false }
        return true
    }
}

struct MoveItemFormState: Equatable {
    static let empty = MoveItemFormState(selectedWorkspaceID: nil, workspaces: [], canMove: false)

    let selectedWorkspaceID: UUID?
    let workspaces: [MoveItemWorkspaceOptionState]
    let canMove: Bool
}

struct MoveItemWorkspaceOptionState: Identifiable, Equatable {
    let id: UUID
    let title: String
}
