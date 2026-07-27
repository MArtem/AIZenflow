import SwiftUI

/// Selects the Settings surface for one explicit screen state.
struct SettingsStateRenderer: View {
    let state: SettingsViewState
    let cleanupTemporaryFiles: () -> Void
    let prepareExport: () -> Void
    let openAppSettings: () -> Void
    let requestDeleteAll: () -> Void

    var body: some View {
        switch state {
        case let .content(content), let .exportReady(content):
            SettingsContentView(
                content: content,
                isWorking: false,
                errorMessage: nil,
                cleanupTemporaryFiles: cleanupTemporaryFiles,
                prepareExport: prepareExport,
                openAppSettings: openAppSettings,
                requestDeleteAll: requestDeleteAll
            )
        case let .working(content):
            SettingsContentView(
                content: content,
                isWorking: true,
                errorMessage: nil,
                cleanupTemporaryFiles: cleanupTemporaryFiles,
                prepareExport: prepareExport,
                openAppSettings: openAppSettings,
                requestDeleteAll: requestDeleteAll
            )
        case let .failure(content, message):
            SettingsContentView(
                content: content,
                isWorking: false,
                errorMessage: message,
                cleanupTemporaryFiles: cleanupTemporaryFiles,
                prepareExport: prepareExport,
                openAppSettings: openAppSettings,
                requestDeleteAll: requestDeleteAll
            )
        }
    }
}
