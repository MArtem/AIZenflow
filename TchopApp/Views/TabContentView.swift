import SwiftUI
import TchopErrors

/// Hosts tab-level content including top bar, feed, and action affordances.
struct TabContentView: View {
    let selectedTab: AppTab
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var newsFeedViewModel: NewsFeedViewModel
    let errorManager: any AppErrorManaging
    let onNewsFeedScrollProximityChange: (Bool) -> Void
    let currentUser: AppUser?
    let onNavigationRestoreChange: (Bool) throws -> Void
    let onLogout: () -> Void

    var body: some View {
        switch selectedTab {
        case .news:
            NewsTabRootView(
                viewModel: newsFeedViewModel,
                router: coordinator.newsRouter,
                onFeedScrollProximityChange: onNewsFeedScrollProximityChange
            )
        case .mixes:
            MixesTabRootView(
                router: coordinator.mixesRouter
            )
        case .pinned:
            PinnedTabRootView(
                router: coordinator.pinnedRouter
            )
        case .chat:
            ChatTabRootView(
                router: coordinator.chatRouter
            )
        case .profile:
            if let currentUser {
                ProfileTabRootView(
                    currentUser: currentUser,
                    router: coordinator.profileRouter,
                    errorManager: errorManager,
                    onNavigationRestoreChange: onNavigationRestoreChange,
                    onLogout: onLogout
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
