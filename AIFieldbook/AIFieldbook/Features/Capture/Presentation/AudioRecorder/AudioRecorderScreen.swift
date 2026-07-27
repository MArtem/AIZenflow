import SwiftUI

/// Sheet screen for one local audio recording flow.
///
/// The screen owns no audio resources and keeps only environment-driven presentation behavior.
struct AudioRecorderScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    let viewModel: AudioRecorderViewModel

    var body: some View {
        NavigationStack {
            AudioRecorderStateRenderer(
                state: viewModel.state,
                selectedWorkspaceID: Binding(
                    get: { viewModel.state.form?.selectedWorkspaceID },
                    set: { workspaceID in
                        viewModel.destinationChanged(workspaceID)
                    }
                ),
                title: Binding(
                    get: { viewModel.state.form?.title ?? "" },
                    set: { title in
                        viewModel.titleChanged(title)
                    }
                ),
                record: {
                    Task { await viewModel.recordTapped() }
                },
                openSettings: openSettings
            )
            .navigationTitle("Record Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        Task {
                            await viewModel.cancelled()
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if await viewModel.saveTapped() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.state.canSave)
                }
            }
        }
        .onAppear {
            viewModel.appeared()
        }
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.scenePhaseChanged(newPhase)
        }
        .onDisappear {
            Task { await viewModel.cancelled() }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
