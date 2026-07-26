import SwiftUI

enum TextNoteEditorFocusField: Hashable {
    case title
    case body
}

/// Sheet screen for creating or editing a text note.
///
/// Durable form values, validation, and persistence are owned by the injected model. This screen
/// owns only focus and discard-confirmation presentation.
struct TextNoteEditorScreen: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: TextNoteEditorViewModel
    @State private var showsDiscardConfirmation = false
    @FocusState private var focusedField: TextNoteEditorFocusField?

    var body: some View {
        NavigationStack {
            TextNoteEditorStateRenderer(
                state: viewModel.state,
                title: Binding(
                    get: { viewModel.state.form?.title ?? "" },
                    set: { updatedTitle in
                        viewModel.titleChanged(updatedTitle)
                    }
                ),
                noteBody: Binding(
                    get: { viewModel.state.form?.body ?? "" },
                    set: { updatedBody in
                        viewModel.bodyChanged(updatedBody)
                    }
                ),
                selectedWorkspaceID: Binding(
                    get: { viewModel.state.form?.selectedWorkspaceID },
                    set: { updatedWorkspaceID in
                        viewModel.workspaceSelectionChanged(updatedWorkspaceID)
                    }
                ),
                focusedField: $focusedField
            )
            .navigationTitle(viewModel.state.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.state.form?.hasUnsavedChanges == true {
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
                    .disabled(viewModel.state.form?.canSave != true || viewModel.state.isSaving)
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
            .interactiveDismissDisabled(viewModel.state.form?.hasUnsavedChanges == true)
            .onAppear {
                viewModel.appeared()
                focusedField = .title
            }
        }
    }
}
