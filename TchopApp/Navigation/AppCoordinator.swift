import Foundation
import TchopNavigation

/// Defines stack mutation policy for navigation transitions.
enum NavigationTransitionPolicy: String, Codable, Equatable {
    case push
    case replace
    case popToRoot
}

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

    /// Applies transition for a news destination with idempotency guarantees.
    func navigateToNews(_ route: NewsRoute, policy: NavigationTransitionPolicy) {
        applyTransition(
            route: route,
            policy: policy,
            router: newsRouter,
            isEquivalent: { lhs, rhs in
                lhs.destinationID == rhs.destinationID &&
                    lhs.title == rhs.title &&
                    lhs.subtitle == rhs.subtitle &&
                    lhs.bodyText == rhs.bodyText &&
                    lhs.accentLabel == rhs.accentLabel
            }
        )
    }

    /// Applies transition for a mixes destination with idempotency guarantees.
    func navigateToMixes(_ route: MixesRoute, policy: NavigationTransitionPolicy) {
        applyTransition(
            route: route,
            policy: policy,
            router: mixesRouter,
            isEquivalent: { lhs, rhs in
                lhs.title == rhs.title && lhs.description == rhs.description
            }
        )
    }

    /// Applies transition for a pinned destination with idempotency guarantees.
    func navigateToPinned(_ route: PinnedRoute, policy: NavigationTransitionPolicy) {
        applyTransition(
            route: route,
            policy: policy,
            router: pinnedRouter,
            isEquivalent: { lhs, rhs in
                lhs.title == rhs.title && lhs.description == rhs.description
            }
        )
    }

    /// Applies transition for a chat destination with idempotency guarantees.
    func navigateToChat(_ route: ChatRoute, policy: NavigationTransitionPolicy) {
        applyTransition(
            route: route,
            policy: policy,
            router: chatRouter,
            isEquivalent: { lhs, rhs in
                lhs.title == rhs.title && lhs.description == rhs.description
            }
        )
    }

    /// Applies transition for a profile destination with idempotency guarantees.
    func navigateToProfile(_ route: ProfileRoute, policy: NavigationTransitionPolicy) {
        applyTransition(
            route: route,
            policy: policy,
            router: profileRouter,
            isEquivalent: { lhs, rhs in
                lhs.title == rhs.title && lhs.description == rhs.description
            }
        )
    }

    private func applyTransition<Route: Hashable>(
        route: Route,
        policy: NavigationTransitionPolicy,
        router: TabRouter<Route>,
        isEquivalent: (Route, Route) -> Bool
    ) {
        switch policy {
        case .popToRoot:
            router.popToRoot()
        case .replace:
            if router.path.count == 1, let current = router.path.first, isEquivalent(current, route) {
                return
            }
            router.replacePath(with: [route])
        case .push:
            if let current = router.path.last, isEquivalent(current, route) {
                return
            }
            router.push(route)
        }
    }
}
