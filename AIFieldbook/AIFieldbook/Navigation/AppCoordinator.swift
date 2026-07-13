import Foundation
import Observation

enum AppTab: Hashable {
    case workspace
    case capture
    case search
    case labs
    case settings
}

enum WorkspaceRoute: Hashable {
    case workspace(UUID)
    case item(UUID, KnowledgeItemKind)
}

enum CaptureRoute: Hashable {
    case item(UUID, KnowledgeItemKind)
}

enum SearchRoute: Hashable {
    case item(UUID, KnowledgeItemKind)
}

enum LabsRoute: Hashable {
    case overview
}

enum SettingsRoute: Hashable {
    case storage
    case permissions
    case dataLifecycle
}

enum AppPresentation: Hashable, Identifiable {
    case createWorkspace
    case renameWorkspace(UUID)
    case createTextNote(UUID?)
    case editTextNote(UUID)
    case manageTags(UUID)
    case importItem(ImportKind)
    case createURLReference
    case editURLReference(UUID)
    case recordAudio
    case moveItem(UUID)

    var id: String {
        switch self {
        case .createWorkspace: "create-workspace"
        case let .renameWorkspace(id): "rename-workspace-\(id)"
        case let .createTextNote(id): "create-note-\(id?.uuidString ?? "choose")"
        case let .editTextNote(id): "edit-note-\(id)"
        case let .manageTags(id): "manage-tags-\(id)"
        case let .importItem(kind): "import-\(kind.rawValue)"
        case .createURLReference: "create-url-reference"
        case let .editURLReference(id): "edit-url-reference-\(id)"
        case .recordAudio: "record-audio"
        case let .moveItem(id): "move-item-\(id)"
        }
    }
}

/// Owns app-level tab selection, modal presentation, and one typed stack per tab.
@MainActor
@Observable
final class AppCoordinator {
    var selectedTab: AppTab = .workspace
    var presentation: AppPresentation?

    let workspaceRouter = TabRouter<WorkspaceRoute>()
    let captureRouter = TabRouter<CaptureRoute>()
    let searchRouter = TabRouter<SearchRoute>()
    let labsRouter = TabRouter<LabsRoute>()
    let settingsRouter = TabRouter<SettingsRoute>()

    func openWorkspace(id: UUID) {
        selectedTab = .workspace
        workspaceRouter.push(.workspace(id))
    }

    func openItem(id: UUID, kind: KnowledgeItemKind, from tab: AppTab) {
        selectedTab = tab
        switch tab {
        case .workspace:
            workspaceRouter.push(.item(id, kind))
        case .capture:
            captureRouter.push(.item(id, kind))
        case .search:
            searchRouter.push(.item(id, kind))
        case .labs, .settings:
            selectedTab = .workspace
            workspaceRouter.push(.item(id, kind))
        }
    }

    func present(_ presentation: AppPresentation) {
        self.presentation = presentation
    }

    func dismissPresentation() {
        presentation = nil
    }
}
