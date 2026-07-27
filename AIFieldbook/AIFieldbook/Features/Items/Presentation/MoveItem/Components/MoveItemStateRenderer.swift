import SwiftUI

/// Selects the move-destination form surface for one explicit state.
struct MoveItemStateRenderer: View {
    let state: MoveItemViewState
    @Binding var selectedWorkspaceID: UUID?
    let retry: () -> Void

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Loading Workspaces")
        case let .content(form), let .empty(form), let .moving(form):
            MoveItemFormView(
                form: form,
                errorMessage: nil,
                isMoving: state.isMoving,
                selectedWorkspaceID: $selectedWorkspaceID
            )
        case let .failure(form, message):
            MoveItemFormView(
                form: form,
                errorMessage: message,
                isMoving: false,
                selectedWorkspaceID: $selectedWorkspaceID
            )
            .safeAreaInset(edge: .bottom) {
                Button("Try Again", action: retry)
                    .buttonStyle(.bordered)
                    .padding()
            }
        }
    }
}
