import SwiftUI

/// Passive content surface for a prepared imported-item display state.
struct ImportedItemDetailContentView: View {
    let content: ImportedItemDetailContentState
    let playbackModel: AudioPlaybackModel
    let recognizeText: () -> Void
    let cancelTextRecognition: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FieldbookSpacing.section) {
                ImportedItemPreviewView(preview: content.preview, playbackModel: playbackModel)

                if !content.tags.isEmpty {
                    TagListView(tags: content.tags)
                }

                if let textRecognition = content.textRecognition {
                    ImportedItemTextRecognitionView(
                        state: textRecognition,
                        recognizeText: recognizeText,
                        cancel: cancelTextRecognition
                    )
                }

                ImportedItemMetadataView(metadata: content.metadata)
            }
            .padding(FieldbookSpacing.standard)
        }
        .background(FieldbookColor.canvas)
    }
}

/// Presents explicit local-AI execution, result, provenance, and uncertainty states.
private struct ImportedItemTextRecognitionView: View {
    let state: ImportedItemTextRecognitionState
    let recognizeText: () -> Void
    let cancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: FieldbookSpacing.compact) {
            Label("Recognized Text", systemImage: "text.viewfinder")
                .font(FieldbookTypography.sectionTitle)

            if let result = state.result {
                if result.isEmpty {
                    Text("No text was recognized in this image.")
                        .foregroundStyle(.secondary)
                } else {
                    Text(result.text)
                        .textSelection(.enabled)
                }

                Divider()
                Label(result.provenanceText, systemImage: "iphone")
                Text(
                    String.localizedStringWithFormat(
                        String(localized: "Recognized %@"),
                        result.createdAtText
                    )
                )
            } else if state.phase == .idle {
                Text("Extract text from this image locally on this device.")
                    .foregroundStyle(.secondary)
            }

            Text("AI-generated text may contain mistakes. Check it against the original image.")
                .font(FieldbookTypography.supporting)
                .foregroundStyle(.secondary)

            switch state.phase {
            case .idle:
                Button(state.result == nil ? "Recognize Text" : "Recognize Again") {
                    recognizeText()
                }
                .buttonStyle(.borderedProminent)
            case .processing:
                HStack(spacing: FieldbookSpacing.compact) {
                    ProgressView()
                    Text("Recognizing Text")
                    Spacer()
                    Button("Cancel", role: .cancel, action: cancel)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .font(FieldbookTypography.body)
        .fieldbookCard()
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
