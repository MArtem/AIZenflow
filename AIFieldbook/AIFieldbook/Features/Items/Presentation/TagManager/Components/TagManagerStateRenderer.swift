import SwiftUI

/// Selects the tag-management form surface for one explicit state.
struct TagManagerStateRenderer: View {
    let state: TagManagerViewState
    @Binding var newTagName: String
    let createTag: () -> Void
    let assignmentChanged: (UUID, Bool) -> Void
    let retry: () -> Void

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Loading Tags")
        case let .content(form), let .empty(form), let .mutating(form):
            TagManagerFormView(
                form: form,
                errorMessage: nil,
                isMutating: state.isMutating,
                newTagName: $newTagName,
                createTag: createTag,
                assignmentChanged: assignmentChanged
            )
        case let .failure(form, message):
            TagManagerFormView(
                form: form,
                errorMessage: message,
                isMutating: false,
                newTagName: $newTagName,
                createTag: createTag,
                assignmentChanged: assignmentChanged
            )
            .safeAreaInset(edge: .bottom) {
                Button("Try Again", action: retry)
                    .buttonStyle(.bordered)
                    .padding()
            }
        }
    }
}
