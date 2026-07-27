import SwiftUI

/// Selects the Text Note Editor visual branch for its explicit state.
struct TextNoteEditorStateRenderer: View {
    let state: TextNoteEditorViewState
    @Binding var title: String
    @Binding var noteBody: String
    @Binding var selectedWorkspaceID: UUID?
    var focusedField: FocusState<TextNoteEditorFocusField?>.Binding

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Loading Note Editor")
        case let .editing(form), let .saving(form):
            TextNoteEditorFormView(
                form: form,
                errorMessage: nil,
                title: $title,
                noteBody: $noteBody,
                selectedWorkspaceID: $selectedWorkspaceID,
                focusedField: focusedField
            )
        case let .failure(form, message):
            TextNoteEditorFormView(
                form: form,
                errorMessage: message,
                title: $title,
                noteBody: $noteBody,
                selectedWorkspaceID: $selectedWorkspaceID,
                focusedField: focusedField
            )
        }
    }
}
