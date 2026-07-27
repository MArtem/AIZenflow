import SwiftUI

/// Passive form surface for one prepared text-note editor state.
struct TextNoteEditorFormView: View {
    let form: TextNoteEditorFormState
    let errorMessage: String?
    @Binding var title: String
    @Binding var noteBody: String
    @Binding var selectedWorkspaceID: UUID?
    var focusedField: FocusState<TextNoteEditorFocusField?>.Binding

    var body: some View {
        Form {
            if form.showsWorkspacePicker {
                Section("Workspace") {
                    Picker("Workspace", selection: $selectedWorkspaceID) {
                        Text(String(localized: "Choose a Workspace")).tag(UUID?.none)
                        ForEach(form.workspaces) { workspace in
                            Text(workspace.title).tag(Optional(workspace.id))
                        }
                    }
                }
            }

            Section("Note") {
                TextField("Title", text: $title)
                    .focused(focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField.wrappedValue = .body
                    }

                TextEditor(text: $noteBody)
                    .focused(focusedField, equals: .body)
                    .frame(minHeight: 220)
                    .accessibilityLabel("Note Text")
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
