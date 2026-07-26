import SwiftUI

/// Passive tag creation and assignment controls for one prepared form state.
struct TagManagerFormView: View {
    let form: TagManagerFormState
    let errorMessage: String?
    let isMutating: Bool
    @Binding var newTagName: String
    let createTag: () -> Void
    let assignmentChanged: (UUID, Bool) -> Void

    var body: some View {
        Form {
            Section("Create Tag") {
                TextField("Tag Name", text: $newTagName)
                Button("Create and Assign", systemImage: "plus", action: createTag)
                    .disabled(!form.canCreateTag || isMutating)
            }

            Section("Assigned Tags") {
                if form.rows.isEmpty {
                    Text(String(localized: "No tags created yet."))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(form.rows) { row in
                        Toggle(
                            row.title,
                            isOn: Binding(
                                get: { row.isAssigned },
                                set: { isAssigned in
                                    assignmentChanged(row.id, isAssigned)
                                }
                            )
                        )
                        .disabled(isMutating)
                    }
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
