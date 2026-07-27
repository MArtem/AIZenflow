import Foundation

/// Pure mapper for import destination options and lifecycle states.
struct ImportItemViewStateBuilder {
    func loading(kind: ImportKind) -> ImportItemViewState {
        .loading(kindTitle: kind.title)
    }

    func ready(form: ImportItemFormState) -> ImportItemViewState {
        .ready(form)
    }

    func empty(form: ImportItemFormState) -> ImportItemViewState {
        .empty(form)
    }

    func importing(form: ImportItemFormState) -> ImportItemViewState {
        .importing(form)
    }

    func failure(form: ImportItemFormState, message: String) -> ImportItemViewState {
        .failure(form: form, message: message)
    }

    func form(
        kind: ImportKind,
        selectedWorkspaceID: UUID?,
        workspaces: [WorkspaceSummary]
    ) -> ImportItemFormState {
        ImportItemFormState(
            kind: kind,
            selectedWorkspaceID: selectedWorkspaceID,
            workspaces: workspaces.map {
                ImportItemWorkspaceOptionState(id: $0.id, title: $0.name)
            },
            canChooseFile: selectedWorkspaceID != nil
        )
    }
}
