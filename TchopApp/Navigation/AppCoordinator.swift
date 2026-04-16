import Foundation

/// Coordinator that owns shared tab selection and per-tab routers.
@MainActor
final class AppCoordinator: ObservableObject {
    /// Currently selected tab.
    @Published var selectedTab: AppTab

    /// Router for the news tab stack.
    let newsRouter: TabRouter<NewsRoute>

    /// Router for the mixes tab stack.
    let mixesRouter: TabRouter<MixesRoute>

    /// Router for the pinned tab stack.
    let pinnedRouter: TabRouter<PinnedRoute>

    /// Router for the chat tab stack.
    let chatRouter: TabRouter<ChatRoute>

    /// Router for the profile tab stack.
    let profileRouter: TabRouter<ProfileRoute>

    /// Creates the coordinator with empty navigation stacks.
    init(selectedTab: AppTab = .news) {
        self.selectedTab = selectedTab
        self.newsRouter = TabRouter<NewsRoute>()
        self.mixesRouter = TabRouter<MixesRoute>()
        self.pinnedRouter = TabRouter<PinnedRoute>()
        self.chatRouter = TabRouter<ChatRoute>()
        self.profileRouter = TabRouter<ProfileRoute>()
    }

    /// Selects the active application tab.
    func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    /// Clears every tab navigation stack.
    func resetAllNavigation() {
        newsRouter.popToRoot()
        mixesRouter.popToRoot()
        pinnedRouter.popToRoot()
        chatRouter.popToRoot()
        profileRouter.popToRoot()
    }

    /// Creates a serializable snapshot of the current navigation state.
    func makeSnapshot() -> NavigationSnapshot {
        NavigationSnapshot(
            selectedTab: selectedTab,
            newsPath: newsRouter.path,
            mixesPath: mixesRouter.path,
            pinnedPath: pinnedRouter.path,
            chatPath: chatRouter.path,
            profilePath: profileRouter.path
        )
    }

    /// Applies a previously saved navigation snapshot.
    func applySnapshot(_ snapshot: NavigationSnapshot) {
        selectTab(snapshot.selectedTab)
        newsRouter.replacePath(with: snapshot.newsPath)
        mixesRouter.replacePath(with: snapshot.mixesPath)
        pinnedRouter.replacePath(with: snapshot.pinnedPath)
        chatRouter.replacePath(with: snapshot.chatPath)
        profileRouter.replacePath(with: snapshot.profilePath)
    }
}
