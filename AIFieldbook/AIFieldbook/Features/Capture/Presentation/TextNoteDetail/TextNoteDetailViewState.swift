import Foundation

/// Render-ready state for one text-note detail route.
///
/// Content is retained for recoverable failures so a loaded note never becomes a blank screen.
enum TextNoteDetailViewState: Equatable {
    case loading
    case unavailable(TextNoteDetailUnavailableState)
    case content(TextNoteDetailContentState)
    case actionFailure(content: TextNoteDetailContentState, message: String)

    var content: TextNoteDetailContentState? {
        switch self {
        case let .content(content), let .actionFailure(content, _):
            content
        case .loading, .unavailable:
            nil
        }
    }

    var navigationTitle: String {
        content?.title ?? String(localized: "Text Note")
    }

    var actionFailureMessage: String? {
        guard case let .actionFailure(_, message) = self else { return nil }
        return message
    }
}

struct TextNoteDetailUnavailableState: Equatable {
    let message: String
}

struct TextNoteDetailContentState: Equatable {
    let id: UUID
    let title: String
    let body: String
    let tags: [TagSummary]
    let updatedAtText: String
}
