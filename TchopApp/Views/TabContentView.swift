import SwiftUI

/// Hosts tab-level content including top bar, feed, and action affordances.
struct TabContentView: View {
    let selectedTab: AppTab
    @ObservedObject var coordinator: AppCoordinator
    let newsFeedViewModel: NewsFeedViewModel
    let onNewsFeedScrollProximityChange: (Bool) -> Void
    let currentUser: AppUser?
    let profileTabViewModel: ProfileTabViewModel?
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
            if currentUser != nil, let profileTabViewModel {
                ProfileTabRootView(
                    viewModel: profileTabViewModel,
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

#if DEBUG
#Preview("Tab Content - News") {
    let coordinator = ViewPreviewSupport.makeCoordinator(selectedTab: .news)

    return TabContentView(
        selectedTab: .news,
        coordinator: coordinator,
        newsFeedViewModel: ViewPreviewSupport.makeNewsFeedViewModel(),
        onNewsFeedScrollProximityChange: { _ in },
        currentUser: ViewPreviewSupport.sampleUser,
        profileTabViewModel: ViewPreviewSupport.makeProfileTabViewModel(
            currentUser: ViewPreviewSupport.sampleUser
        ),
        onLogout: {}
    )
}

#Preview("Tab Content - Profile") {
    let coordinator = ViewPreviewSupport.makeCoordinator(selectedTab: .profile)

    return TabContentView(
        selectedTab: .profile,
        coordinator: coordinator,
        newsFeedViewModel: ViewPreviewSupport.makeNewsFeedViewModel(),
        onNewsFeedScrollProximityChange: { _ in },
        currentUser: ViewPreviewSupport.sampleUser,
        profileTabViewModel: ViewPreviewSupport.makeProfileTabViewModel(
            currentUser: ViewPreviewSupport.sampleUser
        ),
        onLogout: {}
    )
}
#endif
