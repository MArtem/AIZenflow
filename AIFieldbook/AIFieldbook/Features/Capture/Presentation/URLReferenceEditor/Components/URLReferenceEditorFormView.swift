import SwiftUI

/// Passive web-link form surface for one prepared editor state.
struct URLReferenceEditorFormView: View {
    let form: URLReferenceEditorFormState
    let errorMessage: String?
    @Binding var selectedWorkspaceID: UUID?
    @Binding var title: String
    @Binding var urlText: String
    @Binding var notes: String

    var body: some View {
        Form {
            Section("Destination") {
                Picker("Workspace", selection: $selectedWorkspaceID) {
                    Text(String(localized: "Choose a Workspace")).tag(UUID?.none)
                    ForEach(form.workspaces) { workspace in
                        Text(workspace.title).tag(Optional(workspace.id))
                    }
                }
            }
            Section("Web Link") {
                TextField("Title", text: $title)
                TextField("https://example.com", text: $urlText)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                TextField("Notes (optional)", text: $notes, axis: .vertical)
                    .lineLimit(3...8)
            }
            if form.usesInsecureHTTP {
                Section("Connection Warning") {
                    Label(
                        "This HTTP address is not encrypted. Avoid opening it with private information in the URL.",
                        systemImage: "lock.open.trianglebadge.exclamationmark"
                    )
                    .foregroundStyle(FieldbookColor.destructive)
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
