import Foundation

/// Pure mapper for web-link form values, validation display, and editor lifecycle states.
struct URLReferenceEditorViewStateBuilder {
    func loading(mode: URLReferenceEditorViewModel.Mode) -> URLReferenceEditorViewState {
        .loading(navigationTitle: navigationTitle(for: mode))
    }

    func editing(form: URLReferenceEditorFormState) -> URLReferenceEditorViewState {
        .editing(form)
    }

    func saving(form: URLReferenceEditorFormState) -> URLReferenceEditorViewState {
        .saving(form)
    }

    func failure(form: URLReferenceEditorFormState, message: String) -> URLReferenceEditorViewState {
        .failure(form: form, message: message)
    }

    func form(
        mode: URLReferenceEditorViewModel.Mode,
        selectedWorkspaceID: UUID?,
        title: String,
        urlText: String,
        notes: String,
        workspaces: [WorkspaceSummary],
        normalizedURL: URL?
    ) -> URLReferenceEditorFormState {
        URLReferenceEditorFormState(
            navigationTitle: navigationTitle(for: mode),
            selectedWorkspaceID: selectedWorkspaceID,
            workspaces: workspaces.map {
                URLReferenceEditorWorkspaceOptionState(id: $0.id, title: $0.name)
            },
            title: title,
            urlText: urlText,
            notes: notes,
            canSave: normalizedURL != nil
                && selectedWorkspaceID != nil
                && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            usesInsecureHTTP: normalizedURL?.scheme?.lowercased() == "http"
        )
    }

    private func navigationTitle(for mode: URLReferenceEditorViewModel.Mode) -> String {
        switch mode {
        case .create:
            String(localized: "New Web Link")
        case .edit:
            String(localized: "Edit Web Link")
        }
    }
}
