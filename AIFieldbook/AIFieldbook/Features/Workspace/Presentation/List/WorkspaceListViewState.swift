import Foundation

/// Render-ready state for the Workspace tab list.
///
/// The enum makes the initial loading, unavailable, empty, and populated states mutually
/// exclusive. Rows carry only presentation data, so SwiftUI does not format domain snapshots
/// while rendering the list.
enum WorkspaceListViewState: Equatable {
    case loading
    case unavailable(WorkspaceListUnavailableState)
    case empty
    case content(WorkspaceListContentState)

    var content: WorkspaceListContentState? {
        guard case let .content(content) = self else { return nil }
        return content
    }
}

struct WorkspaceListUnavailableState: Equatable {
    let message: String
}

struct WorkspaceListContentState: Equatable {
    let rows: [WorkspaceListRowState]
}

struct WorkspaceListRowState: Identifiable, Equatable {
    let id: UUID
    let title: String
    let itemCountText: String
}
