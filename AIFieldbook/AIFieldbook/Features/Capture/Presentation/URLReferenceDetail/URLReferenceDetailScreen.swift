import SwiftUI

/// Detail screen for one locally stored web-link route.
///
/// It owns only deletion-confirmation presentation and forwards external navigation actions to
/// the view system through `Link` and `ShareLink` in the passive content surface.
struct URLReferenceDetailScreen: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: URLReferenceDetailViewModel
    let edit: () -> Void
    let manageTags: () -> Void
    let moveItem: () -> Void
    @State private var confirmsDelete = false

    var body: some View {
        URLReferenceDetailStateRenderer(
            state: viewModel.state,
            reload: viewModel.reloadRequested
        )
        .navigationTitle(viewModel.state.navigationTitle)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit", systemImage: "pencil", action: edit)
                Button("Manage Tags", systemImage: "tag", action: manageTags)
                Button("Move", systemImage: "folder", action: moveItem)
                if let content = viewModel.state.content {
                    ShareLink(item: content.url) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                Button("Delete", systemImage: "trash", role: .destructive) {
                    confirmsDelete = true
                }
            }
        }
        .alert("Delete Web Link?", isPresented: $confirmsDelete) {
            Button("Delete", role: .destructive) {
                if viewModel.deleteConfirmed() {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
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
        .task(id: viewModel.itemID) {
            viewModel.appeared()
        }
    }
}
