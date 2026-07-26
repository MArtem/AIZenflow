import SwiftUI

/// Settings tab boundary for presentation state and system Settings navigation.
struct SettingsScreen: View {
    @Environment(\.openURL) private var openURL
    @State private var confirmsDeleteAll = false

    let viewModel: SettingsViewModel
    let localDataResetCompleted: () -> Void

    var body: some View {
        SettingsStateRenderer(
            state: viewModel.state,
            cleanupTemporaryFiles: {
                Task { await viewModel.cleanupTemporaryFilesTapped() }
            },
            prepareExport: {
                viewModel.exportTapped()
            },
            openAppSettings: openAppSettings,
            requestDeleteAll: {
                confirmsDeleteAll = true
            }
        )
        .navigationTitle("Settings")
        .alert("Delete All Local Data?", isPresented: $confirmsDeleteAll) {
            Button("Delete Everything", role: .destructive) {
                Task {
                    if await viewModel.deleteAllConfirmed() {
                        localDataResetCompleted()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(String(localized: "This permanently deletes every workspace, item, tag, and app-owned file."))
        }
        .task {
            await viewModel.appeared()
        }
        .onDisappear {
            viewModel.disappeared()
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
