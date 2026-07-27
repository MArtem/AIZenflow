import Foundation
import Observation

/// Top-level tabs available in the app shell.
///
/// The enum is the stable selection value for `TabView` and must stay value-only so it can
/// be used by navigation code without retaining views or state owners.
enum AppTab: Hashable {
    case workspace
    case capture
    case search
    case settings
}

/// Route values owned by the Workspace tab navigation stack.
///
/// Routes carry stable record identifiers plus item kind only; destination views resolve
/// current data through composition-owned models.
enum WorkspaceRoute: Hashable {
    case workspace(UUID)
    case item(UUID, KnowledgeItemKind)
}

/// Route values owned by the Capture tab navigation stack.
enum CaptureRoute: Hashable {
    case item(UUID, KnowledgeItemKind)
}

/// Route values owned by the Search tab navigation stack.
enum SearchRoute: Hashable {
    case item(UUID, KnowledgeItemKind)
}

/// Route values reserved for Settings tab subsections.
enum SettingsRoute: Hashable {
    case storage
    case permissions
    case dataLifecycle
}

/// Modal presentation state for app-wide sheets.
///
/// Invariant:
/// The value must remain lightweight and identifier-based. Modal content is created by
/// `AppShellView` from `AppComposition`, not stored inside the route itself.
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
///
/// Ownership:
/// Created and retained by `AppComposition` for one app scene.
///
/// Responsibilities:
/// - selects tabs before pushing cross-tab destinations;
/// - keeps each tab's path isolated in its own typed router;
/// - stores modal intent values without owning feature view models or SwiftUI views.
@MainActor
@Observable
final class AppCoordinator {
    var selectedTab: AppTab = .workspace
    var presentation: AppPresentation?

    let workspaceRouter = TabRouter<WorkspaceRoute>()
    let captureRouter = TabRouter<CaptureRoute>()
    let searchRouter = TabRouter<SearchRoute>()
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
        case .settings:
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
