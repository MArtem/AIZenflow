import SwiftUI

/// Detail screen for one app-owned imported file.
///
/// The screen owns only visual confirmation state and forwards product intents to its injected
/// route model or composition-owned callbacks.
struct ImportedItemDetailScreen: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: ImportedItemDetailViewModel
    let manageTags: () -> Void
    let moveItem: () -> Void
    @State private var showsDeleteConfirmation = false

    var body: some View {
        ImportedItemDetailStateRenderer(
            state: viewModel.state,
            playbackModel: viewModel.playbackModel,
            reload: viewModel.reloadRequested
        )
        .navigationTitle(viewModel.state.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Manage Tags", systemImage: "tag", action: manageTags)
                Button("Move Item", systemImage: "folder", action: moveItem)
                if let content = viewModel.state.content {
                    ShareLink(item: content.shareURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                Button("Delete Item", systemImage: "trash", role: .destructive) {
                    showsDeleteConfirmation = true
                }
            }
        }
        .alert("Delete Item?", isPresented: $showsDeleteConfirmation) {
            Button("Delete Item", role: .destructive) {
                Task {
                    if await viewModel.deleteConfirmed() {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(String(localized: "This permanently deletes the item and its app-owned local file."))
        }
        .alert(
            "Action Failed",
            isPresented: Binding(
                get: { viewModel.state.actionFailureMessage != nil },
                set: { if !$0 { Task { await viewModel.actionFailureDismissed() } } }
            )
        ) {
            Button("OK") {}
        } message: {
            Text(viewModel.state.actionFailureMessage ?? "")
        }
        .task(id: viewModel.itemID) {
            await viewModel.appeared()
        }
    }
}
