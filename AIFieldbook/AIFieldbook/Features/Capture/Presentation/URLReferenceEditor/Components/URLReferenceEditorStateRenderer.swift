import SwiftUI

/// Selects the web-link editor visual branch for its explicit state.
struct URLReferenceEditorStateRenderer: View {
    let state: URLReferenceEditorViewState
    @Binding var selectedWorkspaceID: UUID?
    @Binding var title: String
    @Binding var urlText: String
    @Binding var notes: String

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Loading Web Link Editor")
        case let .editing(form), let .saving(form):
            URLReferenceEditorFormView(
                form: form,
                errorMessage: nil,
                selectedWorkspaceID: $selectedWorkspaceID,
                title: $title,
                urlText: $urlText,
                notes: $notes
            )
        case let .failure(form, message):
            URLReferenceEditorFormView(
                form: form,
                errorMessage: message,
                selectedWorkspaceID: $selectedWorkspaceID,
                title: $title,
                urlText: $urlText,
                notes: $notes
            )
        }
    }
}
