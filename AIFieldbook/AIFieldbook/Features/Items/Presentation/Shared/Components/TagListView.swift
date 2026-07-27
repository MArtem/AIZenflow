import SwiftUI

/// Horizontal tag display shared by item-detail screens.
///
/// Accepts immutable tag snapshots and performs no persistence lookups during rendering.
struct TagListView: View {
    let tags: [TagSummary]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: FieldbookSpacing.compact) {
                ForEach(tags) { tag in
                    Label(tag.name, systemImage: "tag.fill")
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.horizontal, FieldbookSpacing.standard)
                        .padding(.vertical, FieldbookSpacing.compact)
                        .background(FieldbookColor.surface)
                        .clipShape(.capsule)
                }
            }
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tags")
    }
}
