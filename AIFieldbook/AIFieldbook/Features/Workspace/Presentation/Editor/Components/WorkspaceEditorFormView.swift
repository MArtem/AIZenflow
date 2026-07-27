import SwiftUI

/// Passive form surface for one prepared workspace editor state.
struct WorkspaceEditorFormView: View {
    let form: WorkspaceEditorFormState
    let errorMessage: String?
    @Binding var name: String
    var nameIsFocused: FocusState<Bool>.Binding

    var body: some View {
        Form {
            Section("Workspace Name") {
                TextField("Name", text: $name)
                    .focused(nameIsFocused)
                    .submitLabel(.done)
            }

            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(FieldbookColor.destructive)
                        .accessibilityLabel("Error: \(errorMessage)")
                }
            }
        }
    }
}
