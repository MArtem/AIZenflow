import SwiftUI

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
            StubTabNavigationRootView(
                tab: .mixes,
                router: coordinator.mixesRouter,
                sampleRoute: MixesRoute(
                    title: "Mix Details",
                    description: "This navigation stack belongs only to the Mixes tab and is preserved when you switch tabs."
                ),
                destinationBuilder: { route in
                    StubTabDetailView(
                        title: route.title,
                        description: route.description
                    )
                }
            )
        case .pinned:
            StubTabNavigationRootView(
                tab: .pinned,
                router: coordinator.pinnedRouter,
                sampleRoute: PinnedRoute(
                    title: "Pinned Details",
                    description: "Pinned uses its own router path managed by the shared app coordinator."
                ),
                destinationBuilder: { route in
                    StubTabDetailView(
                        title: route.title,
                        description: route.description
                    )
                }
            )
        case .chat:
            StubTabNavigationRootView(
                tab: .chat,
                router: coordinator.chatRouter,
                sampleRoute: ChatRoute(
                    title: "Chat Thread",
                    description: "Chat navigation is isolated per tab, but coordinated from the same app-level coordinator."
                ),
                destinationBuilder: { route in
                    StubTabDetailView(
                        title: route.title,
                        description: route.description
                    )
                }
            )
        case .profile:
            ProfileTabRootView(
                currentUser: currentUser ?? AppUser(
                    id: "missing-user",
                    username: "Unknown User",
                    createdAt: .now
                ),
                router: coordinator.profileRouter,
                onLogout: onLogout
            )
        }
    }
}
