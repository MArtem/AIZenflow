import SwiftUI

/// Workspace tab screen.
///
/// It receives its composition-owned model and forwards navigation/presentation intents without
/// constructing dependencies or formatting domain values in the render path.
struct WorkspaceListScreen: View {
    let viewModel: WorkspaceListViewModel
    let createWorkspace: () -> Void
    let openWorkspace: (UUID) -> Void

    var body: some View {
        WorkspaceListStateRenderer(
            state: viewModel.state,
            createWorkspace: createWorkspace,
            openWorkspace: openWorkspace,
            reload: viewModel.reloadRequested
        )
        .navigationTitle("Workspace")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create Workspace", systemImage: "plus", action: createWorkspace)
            }
        }
        .onAppear {
            viewModel.appeared()
        }
    }
}
