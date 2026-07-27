import SwiftUI

/// Passive content surface for prepared workspace items.
struct WorkspaceDetailContentView: View {
    let content: WorkspaceDetailContentState
    let openItem: (UUID, KnowledgeItemKind) -> Void

    var body: some View {
        List {
            Section("Items") {
                if content.rows.isEmpty {
                    Text(String(localized: "No items yet."))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(content.rows) { row in
                        Button {
                            openItem(row.id, row.kind)
                        } label: {
                            WorkspaceDetailItemRow(row: row)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
