import SwiftUI

/// Selects the import destination and progress surface for one explicit state.
struct ImportItemStateRenderer: View {
    let state: ImportItemViewState
    @Binding var selectedWorkspaceID: UUID?
    let chooseFile: () -> Void
    let retry: () -> Void

    var body: some View {
        switch state {
        case let .loading(kindTitle):
            ProgressView("Loading \(kindTitle) Import")
        case let .ready(form), let .empty(form), let .importing(form):
            ImportItemFormView(
                form: form,
                errorMessage: nil,
                isImporting: state.isImporting,
                selectedWorkspaceID: $selectedWorkspaceID,
                chooseFile: chooseFile
            )
        case let .failure(form, message):
            ImportItemFormView(
                form: form,
                errorMessage: message,
                isImporting: false,
                selectedWorkspaceID: $selectedWorkspaceID,
                chooseFile: chooseFile
            )
            .safeAreaInset(edge: .bottom) {
                Button("Try Again", action: retry)
                    .buttonStyle(.bordered)
                    .padding()
            }
        }
    }
}
