import SwiftUI

/// Sheet screen for importing one user-selected external file into app-owned storage.
///
/// The picker URL is forwarded directly to the model and is never retained by the view.
struct ImportItemScreen: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: ImportItemViewModel
    @State private var showsFileImporter = false

    var body: some View {
        NavigationStack {
            ImportItemStateRenderer(
                state: viewModel.state,
                selectedWorkspaceID: Binding(
                    get: { viewModel.state.form.selectedWorkspaceID },
                    set: { workspaceID in
                        viewModel.destinationChanged(workspaceID)
                    }
                ),
                chooseFile: {
                    showsFileImporter = true
                },
                retry: viewModel.retryTapped
            )
            .navigationTitle("Import \(viewModel.kind.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.state.isImporting)
                }
            }
            .fileImporter(
                isPresented: $showsFileImporter,
                allowedContentTypes: viewModel.kind.allowedContentTypes,
                allowsMultipleSelection: false
            ) { result in
                guard case let .success(urls) = result, let url = urls.first else { return }
                Task {
                    if await viewModel.fileSelected(url) {
                        dismiss()
                    }
                }
            }
            .interactiveDismissDisabled(viewModel.state.isImporting)
            .onAppear {
                viewModel.appeared()
            }
        }
    }
}
