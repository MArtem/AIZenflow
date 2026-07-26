import SwiftUI

/// Detail screen for one text-note route.
///
/// It owns confirmation presentation only and forwards edit, tag, move, share, and delete
/// intents to its injected model or composition-owned callbacks.
struct TextNoteDetailScreen: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: TextNoteDetailViewModel
    let editNote: () -> Void
    let manageTags: () -> Void
    let moveItem: () -> Void
    @State private var showsDeleteConfirmation = false

    var body: some View {
        TextNoteDetailStateRenderer(
            state: viewModel.state,
            reload: viewModel.reloadRequested
        )
        .navigationTitle(viewModel.state.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit Note", systemImage: "pencil", action: editNote)
                Button("Manage Tags", systemImage: "tag", action: manageTags)
                Button("Move Note", systemImage: "folder", action: moveItem)
                if let content = viewModel.state.content {
                    ShareLink(item: content.body, subject: Text(content.title)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                Button("Delete Note", systemImage: "trash", role: .destructive) {
                    showsDeleteConfirmation = true
                }
            }
        }
        .alert("Delete Note?", isPresented: $showsDeleteConfirmation) {
            Button("Delete Note", role: .destructive) {
                if viewModel.deleteConfirmed() {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(String(localized: "This permanently deletes the note."))
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
        .task(id: viewModel.noteID) {
            viewModel.appeared()
        }
    }
}
