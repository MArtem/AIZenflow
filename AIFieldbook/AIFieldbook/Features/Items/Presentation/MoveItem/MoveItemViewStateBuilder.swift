import Foundation

/// Pure mapper for move-item destination choices and explicit lifecycle states.
struct MoveItemViewStateBuilder {
    func loading() -> MoveItemViewState {
        .loading
    }

    func content(form: MoveItemFormState) -> MoveItemViewState {
        .content(form)
    }

    func empty(form: MoveItemFormState) -> MoveItemViewState {
        .empty(form)
    }

    func moving(form: MoveItemFormState) -> MoveItemViewState {
        .moving(form)
    }

    func failure(form: MoveItemFormState, message: String) -> MoveItemViewState {
        .failure(form: form, message: message)
    }

    func form(
        selectedWorkspaceID: UUID?,
        workspaces: [WorkspaceSummary]
    ) -> MoveItemFormState {
        MoveItemFormState(
            selectedWorkspaceID: selectedWorkspaceID,
            workspaces: workspaces.map {
                MoveItemWorkspaceOptionState(id: $0.id, title: $0.name)
            },
            canMove: selectedWorkspaceID != nil
        )
    }
}
