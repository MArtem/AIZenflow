import SwiftUI

/// Passive text-note content surface for a prepared display state.
struct TextNoteDetailContentView: View {
    let content: TextNoteDetailContentState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FieldbookSpacing.section) {
                Text(content.body.isEmpty ? String(localized: "No note text.") : content.body)
                    .font(FieldbookTypography.body)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !content.tags.isEmpty {
                    TagListView(tags: content.tags)
                }

                Text(content.updatedAtText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(FieldbookSpacing.screen)
        }
        .background(FieldbookColor.canvas)
    }
}
