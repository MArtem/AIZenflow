import Foundation

/// Pure mapper from an imported-item snapshot and resolved app-owned URL into display state.
struct ImportedItemDetailViewStateBuilder {
    func loading() -> ImportedItemDetailViewState {
        .loading
    }

    func unavailable(message: String) -> ImportedItemDetailViewState {
        .unavailable(ImportedItemDetailUnavailableState(message: message))
    }

    func loaded(detail: ImportedItemDetailState, fileURL: URL) -> ImportedItemDetailViewState {
        .content(content(detail: detail, fileURL: fileURL))
    }

    func actionFailure(
        content: ImportedItemDetailContentState,
        message: String
    ) -> ImportedItemDetailViewState {
        .actionFailure(content: content, message: message)
    }

    func recognizingText(content: ImportedItemDetailContentState) -> ImportedItemDetailViewState {
        guard let recognition = content.textRecognition else { return .content(content) }
        return .content(
            content.replacingTextRecognition(
                ImportedItemTextRecognitionState(phase: .processing, result: recognition.result)
            )
        )
    }

    func recognitionStopped(content: ImportedItemDetailContentState) -> ImportedItemDetailViewState {
        guard let recognition = content.textRecognition else { return .content(content) }
        return .content(
            content.replacingTextRecognition(
                ImportedItemTextRecognitionState(phase: .idle, result: recognition.result)
            )
        )
    }

    private func content(
        detail: ImportedItemDetailState,
        fileURL: URL
    ) -> ImportedItemDetailContentState {
        ImportedItemDetailContentState(
            title: detail.displayTitle,
            preview: preview(kind: detail.kind, fileURL: fileURL),
            tags: detail.tags,
            metadata: ImportedItemMetadataState(
                kindTitle: detail.kind.displayName,
                kindSystemImage: detail.kind.systemImage,
                originalFilename: detail.originalFilename,
                byteCountText: ByteCountFormatter.string(
                    fromByteCount: detail.byteCount,
                    countStyle: .file
                ),
                dimensionsText: dimensionsText(width: detail.pixelWidth, height: detail.pixelHeight),
                pageCountText: detail.pageCount.map {
                    String.localizedStringWithFormat(String(localized: "%lld pages"), $0)
                },
                durationText: detail.durationSeconds.map {
                    Duration.seconds($0).formatted(.time(pattern: .minuteSecond))
                }
            ),
            textRecognition: textRecognition(detail: detail),
            shareURL: fileURL
        )
    }

    private func textRecognition(
        detail: ImportedItemDetailState
    ) -> ImportedItemTextRecognitionState? {
        guard ImageTextRecognitionCapability.availability(for: detail.kind) == .available else {
            return nil
        }
        return ImportedItemTextRecognitionState(
            phase: .idle,
            result: detail.recognizedImageText.map { result in
                ImportedItemRecognizedTextState(
                    text: result.text,
                    isEmpty: result.provenance.completionState == .empty,
                    createdAtText: result.provenance.createdAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    ),
                    provenanceText: String(localized: "On-device Apple Vision")
                )
            }
        )
    }

    private func preview(kind: KnowledgeItemKind, fileURL: URL) -> ImportedItemPreviewState {
        switch kind {
        case .image:
            return .image(fileURL)
        case .pdf, .plainTextDocument:
            return .document(fileURL)
        case .audio:
            return .audio(fileURL)
        case .textNote, .urlReference:
            assertionFailure("Imported item detail received a non-imported item kind.")
            return .document(fileURL)
        }
    }

    private func dimensionsText(width: Int?, height: Int?) -> String? {
        guard let width, let height else { return nil }
        return String.localizedStringWithFormat(
            String(localized: "%lld × %lld pixels"),
            width,
            height
        )
    }
}
