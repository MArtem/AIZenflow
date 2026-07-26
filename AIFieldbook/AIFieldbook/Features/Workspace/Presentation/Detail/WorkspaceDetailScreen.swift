import SwiftUI

/// Detail screen for one workspace route.
///
/// It owns only confirmation presentation and delegates loading, error recovery, and deletion
/// transactions to its composition-owned model.
struct WorkspaceDetailScreen: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: WorkspaceDetailViewModel
    let openItem: (UUID, KnowledgeItemKind) -> Void
    let createTextNote: () -> Void
    let renameWorkspace: (UUID, String) -> Void
    @State private var showsDeleteConfirmation = false

    var body: some View {
        WorkspaceDetailStateRenderer(
            state: viewModel.state,
            openItem: openItem,
            reload: viewModel.reloadRequested
        )
        .navigationTitle(viewModel.state.navigationTitle)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("New Text Note", systemImage: "square.and.pencil", action: createTextNote)

                Menu("Workspace Actions", systemImage: "ellipsis.circle") {
                    if let content = viewModel.state.content {
                        Button("Rename", systemImage: "pencil") {
                            renameWorkspace(content.id, content.title)
                        }
                        Button("Delete Workspace", systemImage: "trash", role: .destructive) {
                            showsDeleteConfirmation = true
                        }
                    }
                }
            }
        }
        .alert("Delete Workspace?", isPresented: $showsDeleteConfirmation) {
            Button("Delete Workspace", role: .destructive) {
                Task {
                    if await viewModel.deleteConfirmed() {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(String(localized: "This permanently deletes the workspace and every contained item."))
        }
        .alert(
            "Action Failed",
            isPresented: Binding(
                get: { viewModel.state.actionFailureMessage != nil },
                set: { if !$0 { viewModel.actionFailureDismissed() } }
            )
        ) {
            Button("OK") {}
        } message: {
            Text(viewModel.state.actionFailureMessage ?? "")
        }
        .task(id: viewModel.workspaceID) {
            viewModel.appeared()
        }
    }
}
