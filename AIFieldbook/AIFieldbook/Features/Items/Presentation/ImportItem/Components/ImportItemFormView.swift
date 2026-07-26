import SwiftUI

/// Passive import destination and progress form for one prepared state.
struct ImportItemFormView: View {
    let form: ImportItemFormState
    let errorMessage: String?
    let isImporting: Bool
    @Binding var selectedWorkspaceID: UUID?
    let chooseFile: () -> Void

    var body: some View {
        Form {
            Section("Destination") {
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
                    .disabled(isImporting)
                }
            }

            Section("Import") {
                Button("Choose \(form.kind.title)", systemImage: "folder", action: chooseFile)
                    .disabled(!form.canChooseFile || isImporting)

                ImportLimitDescription(kind: form.kind)
            }

            if isImporting {
                Section {
                    ProgressView("Validating and Copying")
                }
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

/// User-facing limits enforced by the app-owned file-import path.
private struct ImportLimitDescription: View {
    let kind: ImportKind

    var body: some View {
        Text(description)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private var description: String {
        switch kind {
        case .image:
            String(localized: "Images up to 25 MB and 20,000 pixels per side.")
        case .pdf:
            String(localized: "PDFs up to 50 MB and 500 pages.")
        case .plainTextDocument:
            String(localized: "UTF-8 plain-text files up to 10 MB.")
        case .audio:
            String(localized: "Playable audio up to 100 MB and four hours.")
        }
    }
}
