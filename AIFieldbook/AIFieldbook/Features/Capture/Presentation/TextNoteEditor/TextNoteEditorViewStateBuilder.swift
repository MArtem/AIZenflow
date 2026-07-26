import Foundation

/// Pure mapper for Text Note Editor form, validation, and loading presentation.
struct TextNoteEditorViewStateBuilder {
    func loading(mode: TextNoteEditorViewModel.Mode) -> TextNoteEditorViewState {
        .loading(navigationTitle: navigationTitle(for: mode))
    }

    func editing(form: TextNoteEditorFormState) -> TextNoteEditorViewState {
        .editing(form)
    }

    func saving(form: TextNoteEditorFormState) -> TextNoteEditorViewState {
        .saving(form)
    }

    func failure(form: TextNoteEditorFormState, message: String) -> TextNoteEditorViewState {
        .failure(form: form, message: message)
    }

    func form(
        mode: TextNoteEditorViewModel.Mode,
        title: String,
        body: String,
        selectedWorkspaceID: UUID?,
        workspaces: [WorkspaceSummary],
        initialTitle: String,
        initialBody: String,
        initialWorkspaceID: UUID?
    ) -> TextNoteEditorFormState {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        return TextNoteEditorFormState(
            navigationTitle: navigationTitle(for: mode),
            showsWorkspacePicker: showsWorkspacePicker(for: mode),
            workspaces: workspaces.map {
                TextNoteEditorWorkspaceOptionState(id: $0.id, title: $0.name)
            },
            title: title,
            body: body,
            selectedWorkspaceID: selectedWorkspaceID,
            canSave: selectedWorkspaceID != nil && (!trimmedTitle.isEmpty || !trimmedBody.isEmpty),
            hasUnsavedChanges: title != initialTitle
                || body != initialBody
                || selectedWorkspaceID != initialWorkspaceID
        )
    }

    private func navigationTitle(for mode: TextNoteEditorViewModel.Mode) -> String {
        switch mode {
        case .create:
            String(localized: "New Text Note")
        case .edit:
            String(localized: "Edit Text Note")
        }
    }

    private func showsWorkspacePicker(for mode: TextNoteEditorViewModel.Mode) -> Bool {
        if case .create(preselectedWorkspaceID: nil) = mode { return true }
        return false
    }
}
