import SwiftUI

/// Sheet screen for creating tags and changing their assignment for one item.
///
/// Dismissal is local UI state; all tag mutation and reload work belongs to the injected model.
struct TagManagerScreen: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: TagManagerViewModel

    var body: some View {
        NavigationStack {
            TagManagerStateRenderer(
                state: viewModel.state,
                newTagName: Binding(
                    get: { viewModel.state.form.newTagName },
                    set: { name in
                        viewModel.newTagNameChanged(name)
                    }
                ),
                createTag: viewModel.createTagTapped,
                assignmentChanged: viewModel.assignmentChanged,
                retry: viewModel.retryTapped
            )
            .navigationTitle("Manage Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.appeared()
            }
        }
    }
}
