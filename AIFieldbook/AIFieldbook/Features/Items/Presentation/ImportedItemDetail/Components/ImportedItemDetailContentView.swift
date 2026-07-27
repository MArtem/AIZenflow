import SwiftUI

/// Passive content surface for a prepared imported-item display state.
struct ImportedItemDetailContentView: View {
    let content: ImportedItemDetailContentState
    let playbackModel: AudioPlaybackModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FieldbookSpacing.section) {
                ImportedItemPreviewView(preview: content.preview, playbackModel: playbackModel)

                if !content.tags.isEmpty {
                    TagListView(tags: content.tags)
                }

                ImportedItemMetadataView(metadata: content.metadata)
            }
            .padding(FieldbookSpacing.standard)
        }
        .background(FieldbookColor.canvas)
    }
}

/// Renders a safe preview surface without performing synchronous file or media work in `body`.
private struct ImportedItemPreviewView: View {
    let preview: ImportedItemPreviewState
    let playbackModel: AudioPlaybackModel

    var body: some View {
        switch preview {
        case let .image(url):
            DownsampledImageView(url: url)
                .frame(maxWidth: .infinity, minHeight: 240)
        case let .document(url):
            QuickLookPreviewView(url: url)
                .frame(height: 520)
                .clipShape(.rect(cornerRadius: FieldbookRadius.card))
        case let .audio(url):
            AudioPlaybackView(url: url, model: playbackModel)
                .fieldbookCard()
        }
    }
}

/// Renders precomputed imported-file metadata without inspecting the file during rendering.
private struct ImportedItemMetadataView: View {
    let metadata: ImportedItemMetadataState

    var body: some View {
        VStack(alignment: .leading, spacing: FieldbookSpacing.compact) {
            Label(metadata.kindTitle, systemImage: metadata.kindSystemImage)
            Text(metadata.originalFilename)
                .textSelection(.enabled)
            Text(metadata.byteCountText)
                .foregroundStyle(.secondary)

            if let dimensionsText = metadata.dimensionsText {
                Text(dimensionsText)
                    .foregroundStyle(.secondary)
            }
            if let pageCountText = metadata.pageCountText {
                Text(pageCountText)
                    .foregroundStyle(.secondary)
            }
            if let durationText = metadata.durationText {
                Text(durationText)
                    .foregroundStyle(.secondary)
            }
        }
        .font(FieldbookTypography.supporting)
        .fieldbookCard()
        .accessibilityElement(children: .combine)
    }
}
