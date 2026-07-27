import Foundation

/// Pure mapper from a detached URL-reference snapshot into a detail render contract.
struct URLReferenceDetailViewStateBuilder {
    func loading() -> URLReferenceDetailViewState {
        .loading
    }

    func unavailable(message: String) -> URLReferenceDetailViewState {
        .unavailable(URLReferenceDetailUnavailableState(message: message))
    }

    func loaded(detail: URLReferenceDetailState) -> URLReferenceDetailViewState {
        .content(content(detail: detail))
    }

    func actionFailure(
        content: URLReferenceDetailContentState,
        message: String
    ) -> URLReferenceDetailViewState {
        .actionFailure(content: content, message: message)
    }

    private func content(detail: URLReferenceDetailState) -> URLReferenceDetailContentState {
        URLReferenceDetailContentState(
            id: detail.id,
            title: detail.title,
            url: detail.url,
            urlText: detail.url.absoluteString,
            notes: detail.notes,
            tags: detail.tags,
            updatedAtText: detail.updatedAt.formatted(.dateTime)
        )
    }
}
