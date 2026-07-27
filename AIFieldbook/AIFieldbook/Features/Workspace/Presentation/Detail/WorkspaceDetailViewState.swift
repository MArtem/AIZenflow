import Foundation

/// Render-ready state for one workspace detail route.
///
/// Content remains available during a recoverable load or delete failure so the screen never
/// falls back to a blank surface after it has rendered a workspace.
enum WorkspaceDetailViewState: Equatable {
    case loading
    case unavailable(WorkspaceDetailUnavailableState)
    case content(WorkspaceDetailContentState)
    case actionFailure(content: WorkspaceDetailContentState, message: String)

    var content: WorkspaceDetailContentState? {
        switch self {
        case let .content(content), let .actionFailure(content, _):
            content
        case .loading, .unavailable:
            nil
        }
    }

    var navigationTitle: String {
        content?.title ?? String(localized: "Workspace")
    }

    var actionFailureMessage: String? {
        guard case let .actionFailure(_, message) = self else { return nil }
        return message
    }
}

struct WorkspaceDetailUnavailableState: Equatable {
    let message: String
}

struct WorkspaceDetailContentState: Equatable {
    let id: UUID
    let title: String
    let rows: [WorkspaceDetailItemRowState]
}

struct WorkspaceDetailItemRowState: Identifiable, Equatable {
    let id: UUID
    let kind: KnowledgeItemKind
    let title: String
    let subtitle: String
    let updatedAtText: String
}
