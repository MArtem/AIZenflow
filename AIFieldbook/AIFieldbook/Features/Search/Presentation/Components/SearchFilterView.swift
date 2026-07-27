import SwiftUI

/// Passive local-search filter controls for a prepared criteria state.
struct SearchFilterView: View {
    let form: SearchFormState
    @Binding var selectedWorkspaceID: UUID?
    @Binding var selectedKind: KnowledgeItemKind?
    @Binding var selectedTagID: UUID?
    let clear: () -> Void

    var body: some View {
        Section("Filters") {
            Picker("Workspace", selection: $selectedWorkspaceID) {
                Text(String(localized: "All Workspaces")).tag(UUID?.none)
                ForEach(form.workspaces) { workspace in
                    Text(workspace.title).tag(Optional(workspace.id))
                }
            }

            Picker("Item Type", selection: $selectedKind) {
                Text(String(localized: "All Types")).tag(KnowledgeItemKind?.none)
                ForEach(form.kinds, id: \.kind) { kind in
                    Text(kind.title).tag(Optional(kind.kind))
                }
            }

            Picker("Tag", selection: $selectedTagID) {
                Text(String(localized: "All Tags")).tag(UUID?.none)
                ForEach(form.tags) { tag in
                    Text(tag.title).tag(Optional(tag.id))
                }
            }

            if form.hasActiveCriteria {
                Button("Clear Search", systemImage: "xmark.circle", action: clear)
            }
        }
    }
}
