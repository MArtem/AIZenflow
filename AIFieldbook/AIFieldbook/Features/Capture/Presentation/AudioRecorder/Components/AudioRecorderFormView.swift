import SwiftUI

/// Passive audio-recorder form receiving immutable display state and explicit callbacks.
struct AudioRecorderFormView: View {
    let form: AudioRecorderFormState
    @Binding var selectedWorkspaceID: UUID?
    @Binding var title: String
    let errorMessage: String?
    let showsPermissionRecovery: Bool
    let record: () -> Void
    let openSettings: () -> Void

    var body: some View {
        Form {
            Section("Destination") {
                Picker("Workspace", selection: $selectedWorkspaceID) {
                    Text(String(localized: "Choose a Workspace")).tag(UUID?.none)
                    ForEach(form.workspaces) { workspace in
                        Text(workspace.title).tag(Optional(workspace.id))
                    }
                }
                TextField("Title (optional)", text: $title)
            }

            Section("Recorder") {
                Text(form.durationText)
                    .font(.title.monospacedDigit())
                    .frame(maxWidth: .infinity)
                Button(
                    form.recordButtonTitle,
                    systemImage: form.recordButtonSystemImage,
                    action: record
                )
                .disabled(form.isRecordButtonDisabled)
            }

            if showsPermissionRecovery {
                Section("Microphone Permission") {
                    Text(String(localized: "Allow microphone access in Settings to record audio."))
                    Button("Open Settings", action: openSettings)
                }
            }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(FieldbookColor.destructive)
            }
        }
    }
}
