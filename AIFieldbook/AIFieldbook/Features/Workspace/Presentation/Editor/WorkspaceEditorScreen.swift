import SwiftUI

/// Sheet screen for creating or renaming a workspace.
///
/// Durable form state and validation are owned by the injected model; the screen owns only
/// focus and discard-confirmation presentation.
struct WorkspaceEditorScreen: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: WorkspaceEditorViewModel
    @State private var showsDiscardConfirmation = false
    @FocusState private var nameIsFocused: Bool

    var body: some View {
        NavigationStack {
            WorkspaceEditorStateRenderer(
                state: viewModel.state,
                name: Binding(
                    get: { viewModel.state.form.name },
                    set: { updatedName in
                        viewModel.nameChanged(updatedName)
                    }
                ),
                nameIsFocused: $nameIsFocused
            )
            .navigationTitle(viewModel.state.form.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.state.form.hasUnsavedChanges {
                            showsDiscardConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.saveTapped() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.state.form.canSave || viewModel.state.isSaving)
                }
            }
            .confirmationDialog(
                "Discard Changes?",
                isPresented: $showsDiscardConfirmation,
                titleVisibility: .visible
            ) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            }
            .interactiveDismissDisabled(viewModel.state.form.hasUnsavedChanges)
            .onAppear {
                nameIsFocused = true
            }
        }
    }
}
