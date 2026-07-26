import SwiftUI

/// Selects the detail surface for one explicit workspace state.
struct WorkspaceDetailStateRenderer: View {
    let state: WorkspaceDetailViewState
    let openItem: (UUID, KnowledgeItemKind) -> Void
    let reload: () -> Void

    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView("Loading Workspace")
            case let .unavailable(unavailable):
                ContentUnavailableView {
                    Label("Workspace Unavailable", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(unavailable.message)
                } actions: {
                    Button("Try Again", action: reload)
                }
            case let .content(content), let .actionFailure(content, _):
                WorkspaceDetailContentView(content: content, openItem: openItem)
            }
        }
    }
}
