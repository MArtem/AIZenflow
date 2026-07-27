import Foundation

/// Pure mapper from a detached text-note snapshot into the detail screen render contract.
struct TextNoteDetailViewStateBuilder {
    func loading() -> TextNoteDetailViewState {
        .loading
    }

    func unavailable(message: String) -> TextNoteDetailViewState {
        .unavailable(TextNoteDetailUnavailableState(message: message))
    }

    func loaded(detail: TextNoteDetailState) -> TextNoteDetailViewState {
        .content(content(detail: detail))
    }

    func actionFailure(
        content: TextNoteDetailContentState,
        message: String
    ) -> TextNoteDetailViewState {
        .actionFailure(content: content, message: message)
    }

    private func content(detail: TextNoteDetailState) -> TextNoteDetailContentState {
        TextNoteDetailContentState(
            id: detail.id,
            title: detail.displayTitle,
            body: detail.body,
            tags: detail.tags,
            updatedAtText: String.localizedStringWithFormat(
                String(localized: "Updated %@"),
                detail.updatedAt.formatted(date: .abbreviated, time: .shortened)
            )
        )
    }
}
