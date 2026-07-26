import SwiftUI

/// Sheet screen for creating or editing a locally stored web link.
///
/// Validation, normalized URL handling, and persistence are owned by the injected model.
struct URLReferenceEditorScreen: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: URLReferenceEditorViewModel

    var body: some View {
        NavigationStack {
            URLReferenceEditorStateRenderer(
                state: viewModel.state,
                selectedWorkspaceID: Binding(
                    get: { viewModel.state.form?.selectedWorkspaceID },
                    set: { workspaceID in
                        viewModel.workspaceSelectionChanged(workspaceID)
                    }
                ),
                title: Binding(
                    get: { viewModel.state.form?.title ?? "" },
                    set: { title in
                        viewModel.titleChanged(title)
                    }
                ),
                urlText: Binding(
                    get: { viewModel.state.form?.urlText ?? "" },
                    set: { urlText in
                        viewModel.urlTextChanged(urlText)
                    }
                ),
                notes: Binding(
                    get: { viewModel.state.form?.notes ?? "" },
                    set: { notes in
                        viewModel.notesChanged(notes)
                    }
                )
            )
            .navigationTitle(viewModel.state.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
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
            .onAppear {
                viewModel.appeared()
            }
        }
    }
}
