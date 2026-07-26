import SwiftUI

/// Selects the imported-item detail surface for one explicit render state.
struct ImportedItemDetailStateRenderer: View {
    let state: ImportedItemDetailViewState
    let playbackModel: AudioPlaybackModel
    let reload: () async -> Void

    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView("Loading Item")
            case let .unavailable(unavailable):
                ContentUnavailableView {
                    Label("Item Unavailable", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(unavailable.message)
                } actions: {
                    Button("Try Again") {
                        Task { await reload() }
                    }
                }
            case let .content(content), let .actionFailure(content, _):
                ImportedItemDetailContentView(content: content, playbackModel: playbackModel)
            }
        }
    }
}
