import Foundation

/// Pure mapper from a workspace detail snapshot into its screen render contract.
struct WorkspaceDetailViewStateBuilder {
    func loading() -> WorkspaceDetailViewState {
        .loading
    }

    func unavailable(message: String) -> WorkspaceDetailViewState {
        .unavailable(WorkspaceDetailUnavailableState(message: message))
    }

    func loaded(detail: WorkspaceDetailState) -> WorkspaceDetailViewState {
        .content(content(detail: detail))
    }

    func actionFailure(
        content: WorkspaceDetailContentState,
        message: String
    ) -> WorkspaceDetailViewState {
        .actionFailure(content: content, message: message)
    }

    private func content(detail: WorkspaceDetailState) -> WorkspaceDetailContentState {
        WorkspaceDetailContentState(
            id: detail.id,
            title: detail.name,
            rows: detail.items.map { item in
                WorkspaceDetailItemRowState(
                    id: item.id,
                    kind: item.kind,
                    title: item.displayTitle,
                    subtitle: item.subtitle,
                    updatedAtText: item.updatedAt.formatted(.dateTime.month().day().hour().minute())
                )
            }
        )
    }
}
