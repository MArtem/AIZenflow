import SwiftUI

/// Sheet screen for moving one item to a selected destination workspace.
struct MoveItemScreen: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: MoveItemViewModel

    var body: some View {
        NavigationStack {
            MoveItemStateRenderer(
                state: viewModel.state,
                selectedWorkspaceID: Binding(
                    get: { viewModel.state.form.selectedWorkspaceID },
                    set: { workspaceID in
                        viewModel.destinationChanged(workspaceID)
                    }
                ),
                retry: viewModel.retryTapped
            )
            .navigationTitle("Move Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Move") {
                        if viewModel.moveTapped() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.state.form.canMove || viewModel.state.isMoving)
                }
            }
            .onAppear {
                viewModel.appeared()
            }
        }
    }
}
