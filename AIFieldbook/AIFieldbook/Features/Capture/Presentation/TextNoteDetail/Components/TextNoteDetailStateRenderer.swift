import SwiftUI

/// Selects the detail surface for one explicit text-note state.
struct TextNoteDetailStateRenderer: View {
    let state: TextNoteDetailViewState
    let reload: () -> Void

    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView("Loading Note")
            case let .unavailable(unavailable):
                ContentUnavailableView {
                    Label("Note Unavailable", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(unavailable.message)
                } actions: {
                    Button("Try Again", action: reload)
                }
            case let .content(content), let .actionFailure(content, _):
                TextNoteDetailContentView(content: content)
            }
        }
    }
}
