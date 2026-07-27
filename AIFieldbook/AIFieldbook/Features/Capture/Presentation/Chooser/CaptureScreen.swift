import SwiftUI

/// Capture tab boundary using the existing workspace availability state.
///
/// The chooser owns no mutable state or side effects. It forwards explicit capture intents to
/// app composition and asks the shared workspace-list model to refresh availability.
struct CaptureScreen: View {
    let workspaceModel: WorkspaceListViewModel
    let createTextNote: () -> Void
    let importItem: (ImportKind) -> Void
    let createURLReference: () -> Void
    let recordAudio: () -> Void

    var body: some View {
        CaptureStateRenderer(
            state: workspaceModel.state,
            retry: {
                workspaceModel.reloadRequested()
            },
            createTextNote: createTextNote,
            importItem: importItem,
            createURLReference: createURLReference,
            recordAudio: recordAudio
        )
        .navigationTitle("Capture")
        .onAppear {
            workspaceModel.appeared()
        }
    }
}
