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
            shareURL: fileURL
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
