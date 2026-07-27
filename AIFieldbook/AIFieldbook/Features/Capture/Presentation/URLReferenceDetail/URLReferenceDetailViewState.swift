import Foundation

/// Render-ready state for one URL-reference detail route.
///
/// Existing content is retained for recoverable load or delete failures.
enum URLReferenceDetailViewState: Equatable {
    case loading
    case unavailable(URLReferenceDetailUnavailableState)
    case content(URLReferenceDetailContentState)
    case actionFailure(content: URLReferenceDetailContentState, message: String)

    var content: URLReferenceDetailContentState? {
        switch self {
        case let .content(content), let .actionFailure(content, _):
            content
        case .loading, .unavailable:
            nil
        }
    }

    var navigationTitle: String {
        content?.title ?? String(localized: "Web Link")
    }

    var actionFailureMessage: String? {
        guard case let .actionFailure(_, message) = self else { return nil }
        return message
    }
}

struct URLReferenceDetailUnavailableState: Equatable {
    let message: String
}

struct URLReferenceDetailContentState: Equatable {
    let id: UUID
    let title: String
    let url: URL
    let urlText: String
    let notes: String
    let tags: [TagSummary]
    let updatedAtText: String
}
