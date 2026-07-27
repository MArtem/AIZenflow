import SwiftUI

/// Selects the URL-reference detail surface for one explicit state.
struct URLReferenceDetailStateRenderer: View {
    let state: URLReferenceDetailViewState
    let reload: () -> Void

    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView("Loading Web Link")
            case let .unavailable(unavailable):
                ContentUnavailableView {
                    Label("Web Link Unavailable", systemImage: "link.badge.plus")
                } description: {
                    Text(unavailable.message)
                } actions: {
                    Button("Try Again", action: reload)
                }
            case let .content(content), let .actionFailure(content, _):
                URLReferenceDetailContentView(content: content)
            }
        }
    }
}
