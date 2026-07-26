import SwiftUI

/// Renders the Workspace Editor form for its current explicit state.
struct WorkspaceEditorStateRenderer: View {
    let state: WorkspaceEditorViewState
    @Binding var name: String
    var nameIsFocused: FocusState<Bool>.Binding

    var body: some View {
        switch state {
        case let .editing(form), let .saving(form):
            WorkspaceEditorFormView(
                form: form,
                errorMessage: nil,
                name: $name,
                nameIsFocused: nameIsFocused
            )
        case let .failure(form, message):
            WorkspaceEditorFormView(
                form: form,
                errorMessage: message,
                name: $name,
                nameIsFocused: nameIsFocused
            )
        }
    }
}
