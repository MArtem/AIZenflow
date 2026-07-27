import SwiftUI

/// Passive destination-picker form for one prepared move-item state.
struct MoveItemFormView: View {
    let form: MoveItemFormState
    let errorMessage: String?
    let isMoving: Bool
    @Binding var selectedWorkspaceID: UUID?

    var body: some View {
        Form {
            Section("Destination Workspace") {
                if form.workspaces.isEmpty {
                    Text(String(localized: "No workspaces available."))
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Workspace", selection: $selectedWorkspaceID) {
                        Text(String(localized: "Choose a Workspace")).tag(UUID?.none)
                        ForEach(form.workspaces) { workspace in
                            Text(workspace.title).tag(Optional(workspace.id))
                        }
                    }
                    .disabled(isMoving)
                }
            }
            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(FieldbookColor.destructive)
                }
            }
        }
    }
}
