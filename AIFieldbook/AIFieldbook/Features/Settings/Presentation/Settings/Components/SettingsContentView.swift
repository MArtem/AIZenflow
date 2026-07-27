import SwiftUI

/// Passive Settings content receiving prepared values and explicit action callbacks.
struct SettingsContentView: View {
    let content: SettingsContentState
    let isWorking: Bool
    let errorMessage: String?
    let cleanupTemporaryFiles: () -> Void
    let prepareExport: () -> Void
    let openAppSettings: () -> Void
    let requestDeleteAll: () -> Void

    var body: some View {
        List {
            Section("Privacy") {
                Label("All content stays on this device.", systemImage: "lock.shield")
                Text(String(localized: "AI Fieldbook has no account, backend, analytics, or cloud processing in Iteration 1."))
                    .font(FieldbookTypography.supporting)
                    .foregroundStyle(.secondary)
                Text(String(localized: "System Spotlight indexing is disabled until a separate opt-in privacy control is added."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Storage") {
                LabeledContent("App-owned data", value: content.storageDescription)
                Button(
                    "Clean Temporary Files",
                    systemImage: "trash.slash",
                    action: cleanupTemporaryFiles
                )
                .disabled(content.areMutatingActionsDisabled)
            }

            Section("Export") {
                Button("Prepare Local Export", systemImage: "square.and.arrow.up", action: prepareExport)
                    .disabled(content.areMutatingActionsDisabled)
                if let exportURL = content.exportURL {
                    ShareLink(item: exportURL) {
                        Label("Share Export Folder", systemImage: "square.and.arrow.up")
                    }
                }
            }

            Section("Permissions") {
                Button("Open App Settings", systemImage: "gear", action: openAppSettings)
                Text(String(localized: "Microphone access is requested only when you start recording."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Data Lifecycle") {
                Button(
                    "Delete All Local Data",
                    systemImage: "trash",
                    role: .destructive,
                    action: requestDeleteAll
                )
                .disabled(content.areMutatingActionsDisabled)
            }

            if isWorking {
                ProgressView("Working")
            }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(FieldbookColor.destructive)
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
    }
}
