import SwiftUI

/// Hosts tab-level content including top bar, feed, and action affordances.
struct TabContentView: View {
    let selectedTab: AppTab
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var newsFeedViewModel: NewsFeedViewModel
    let currentUser: AppUser?
    let onLogout: () -> Void

    var body: some View {
        switch selectedTab {
        case .news:
            NewsTabRootView(
                viewModel: newsFeedViewModel,
                router: coordinator.newsRouter
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
                    onLogout: onLogout
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
