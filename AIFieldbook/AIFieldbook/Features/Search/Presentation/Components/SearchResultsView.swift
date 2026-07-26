import SwiftUI

/// Passive immutable local-search result rows.
struct SearchResultsView: View {
    let rows: [SearchResultRowState]
    let openItem: (UUID, KnowledgeItemKind) -> Void

    var body: some View {
        Section("Results") {
            ForEach(rows) { row in
                Button {
                    openItem(row.id, row.kind)
                } label: {
                    SearchResultRow(row: row)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
