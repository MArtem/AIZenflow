import SwiftUI

/// Passive row for one prepared local-search result.
struct SearchResultRow: View {
    let row: SearchResultRowState

    var body: some View {
        HStack(spacing: FieldbookSpacing.standard) {
            Image(systemName: row.kind.systemImage)
                .font(.title3)
                .frame(width: 32)
                .foregroundStyle(FieldbookColor.accent)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: FieldbookSpacing.compact) {
                Text(row.title)
                    .font(.headline)
                Text(row.subtitle)
                    .font(FieldbookTypography.supporting)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(row.updatedAtText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
