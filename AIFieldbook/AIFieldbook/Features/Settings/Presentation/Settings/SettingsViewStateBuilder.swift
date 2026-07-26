import Foundation

/// Pure mapper from Settings lifecycle values into an explicit render contract.
struct SettingsViewStateBuilder {
    func state(
        storageBytes: Int64,
        exportURL: URL?,
        errorMessage: String?,
        isWorking: Bool
    ) -> SettingsViewState {
        let content = SettingsContentState(
            storageDescription: ByteCountFormatter.string(fromByteCount: storageBytes, countStyle: .file),
            exportURL: exportURL,
            areMutatingActionsDisabled: isWorking
        )

        if let errorMessage {
            return .failure(content: content, message: errorMessage)
        }
        if isWorking {
            return .working(content)
        }
        if exportURL != nil {
            return .exportReady(content)
        }
        return .content(content)
    }
}
