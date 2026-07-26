import SwiftUI

/// Renders capture availability from the shared workspace-list state without owning state.
struct CaptureStateRenderer: View {
    let state: WorkspaceListViewState
    let retry: () -> Void
    let createTextNote: () -> Void
    let importItem: (ImportKind) -> Void
    let createURLReference: () -> Void
    let recordAudio: () -> Void

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Loading Capture Options")
        case let .unavailable(unavailable):
            ContentUnavailableView {
                Label("Capture Unavailable", systemImage: "exclamationmark.triangle")
            } description: {
                Text(unavailable.message)
            } actions: {
                Button("Try Again", action: retry)
            }
        case .empty:
            ContentUnavailableView(
                "Create a Workspace First",
                systemImage: "square.grid.2x2",
                description: Text(
                    String(localized: "Every note belongs to a local workspace. Create one from the Workspace tab.")
                )
            )
        case .content:
            CaptureOptionsView(
                createTextNote: createTextNote,
                importItem: importItem,
                createURLReference: createURLReference,
                recordAudio: recordAudio
            )
        }
    }
}
