import SwiftUI

/// Passive row for one prepared workspace value.
struct WorkspaceListRow: View {
    let row: WorkspaceListRowState

    var body: some View {
        VStack(alignment: .leading, spacing: FieldbookSpacing.compact) {
            Text(row.title)
                .font(.headline)
            Text(row.itemCountText)
                .font(FieldbookTypography.supporting)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
