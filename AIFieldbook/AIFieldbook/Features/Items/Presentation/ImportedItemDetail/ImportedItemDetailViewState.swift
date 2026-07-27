import Foundation

/// Render-ready state for one imported-item detail route.
///
/// Content remains visible after a recoverable action failure so the user does not lose context.
enum ImportedItemDetailViewState: Equatable {
    case loading
    case unavailable(ImportedItemDetailUnavailableState)
    case content(ImportedItemDetailContentState)
    case actionFailure(content: ImportedItemDetailContentState, message: String)

    var content: ImportedItemDetailContentState? {
        switch self {
        case let .content(content), let .actionFailure(content, _):
            content
        case .loading, .unavailable:
            nil
        }
    }

    var navigationTitle: String {
        content?.title ?? String(localized: "Item")
    }

    var actionFailureMessage: String? {
        guard case let .actionFailure(_, message) = self else { return nil }
        return message
    }
}

struct ImportedItemDetailUnavailableState: Equatable {
    let message: String
}

struct ImportedItemDetailContentState: Equatable {
    let title: String
    let preview: ImportedItemPreviewState
    let tags: [TagSummary]
    let metadata: ImportedItemMetadataState
    let textRecognition: ImportedItemTextRecognitionState?
    let shareURL: URL

    func replacingTextRecognition(
        _ textRecognition: ImportedItemTextRecognitionState?
    ) -> ImportedItemDetailContentState {
        ImportedItemDetailContentState(
            title: title,
            preview: preview,
            tags: tags,
            metadata: metadata,
            textRecognition: textRecognition,
            shareURL: shareURL
        )
    }
}

enum ImportedItemPreviewState: Equatable {
    case image(URL)
    case document(URL)
    case audio(URL)
}

struct ImportedItemMetadataState: Equatable {
    let kindTitle: String
    let kindSystemImage: String
    let originalFilename: String
    let byteCountText: String
    let dimensionsText: String?
    let pageCountText: String?
    let durationText: String?
}

/// Render-ready execution state for the image-only local OCR capability.
struct ImportedItemTextRecognitionState: Equatable {
    enum Phase: Equatable {
        case idle
        case processing
    }

    let phase: Phase
    let result: ImportedItemRecognizedTextState?
}

/// Persisted OCR output and user-safe provenance prepared for display.
struct ImportedItemRecognizedTextState: Equatable {
    let text: String
    let isEmpty: Bool
    let createdAtText: String
    let provenanceText: String
}
