import Foundation

/// Pure mapper for Workspace Editor form and validation presentation.
struct WorkspaceEditorViewStateBuilder {
    func editing(
        mode: WorkspaceEditorViewModel.Mode,
        name: String,
        initialName: String
    ) -> WorkspaceEditorViewState {
        .editing(form(mode: mode, name: name, initialName: initialName))
    }

    func saving(
        mode: WorkspaceEditorViewModel.Mode,
        name: String,
        initialName: String
    ) -> WorkspaceEditorViewState {
        .saving(form(mode: mode, name: name, initialName: initialName))
    }

    func failure(
        mode: WorkspaceEditorViewModel.Mode,
        name: String,
        initialName: String,
        message: String
    ) -> WorkspaceEditorViewState {
        .failure(form: form(mode: mode, name: name, initialName: initialName), message: message)
    }

    private func form(
        mode: WorkspaceEditorViewModel.Mode,
        name: String,
        initialName: String
    ) -> WorkspaceEditorFormState {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return WorkspaceEditorFormState(
            navigationTitle: navigationTitle(for: mode),
            name: name,
            canSave: !trimmedName.isEmpty && trimmedName != initialName,
            hasUnsavedChanges: name != initialName
        )
    }

    private func navigationTitle(for mode: WorkspaceEditorViewModel.Mode) -> String {
        switch mode {
        case .create:
            String(localized: "New Workspace")
        case .rename:
            String(localized: "Rename Workspace")
        }
    }
}
