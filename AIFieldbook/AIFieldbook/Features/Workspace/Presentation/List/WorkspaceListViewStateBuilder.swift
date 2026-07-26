import Foundation

/// Pure mapper from local workspace snapshots into the render contract of Workspace List.
///
/// This type deliberately has no repository, navigation, task, or file-system dependency.
struct WorkspaceListViewStateBuilder {
    func loading() -> WorkspaceListViewState {
        .loading
    }

    func unavailable(message: String) -> WorkspaceListViewState {
        .unavailable(WorkspaceListUnavailableState(message: message))
    }

    func loaded(workspaces: [WorkspaceSummary]) -> WorkspaceListViewState {
        guard !workspaces.isEmpty else { return .empty }

        return .content(
            WorkspaceListContentState(
                rows: workspaces.map { workspace in
                    WorkspaceListRowState(
                        id: workspace.id,
                        title: workspace.name,
                        itemCountText: String.localizedStringWithFormat(
                            String(localized: "%lld items"),
                            workspace.itemCount
                        )
                    )
                }
            )
        )
    }
}
