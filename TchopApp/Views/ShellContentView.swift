import SwiftUI
import TchopNavigation

/// Layout wrapper combining top chrome, tab content, and overlays.
struct ShellContentView: View {
    private static let floatingActionButtonTabBarSpacing: CGFloat = 15

    @ObservedObject var viewModel: AppShellViewModel
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var newsRouter: TabRouter<NewsRoute>
    let currentUser: AppUser?
    let profileTabViewModel: ProfileTabViewModel?
    let onLogout: () -> Void

    /// Whether the shell-level floating action button is allowed for the current tab, route depth and scroll position.
    private var shouldShowFloatingActionButton: Bool {
        coordinator.selectedTab == .news &&
            newsRouter.path.isEmpty &&
            viewModel.showsFloatingActionButton &&
            viewModel.isNewsFeedNearTop
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TopBarView(
                    channelInfo: viewModel.channelInfo,
                    onMenuTap: viewModel.toggleMenu,
                    onChannelTap: viewModel.toggleMenu,
                    onSearchTap: {},
                    onNotificationsTap: {}
                )

                TabContentView(
                    selectedTab: coordinator.selectedTab,
                    coordinator: coordinator,
                    newsFeedViewModel: viewModel.newsFeedViewModel,
                    onNewsFeedScrollProximityChange: viewModel.setNewsFeedNearTop,
                    currentUser: currentUser,
                    profileTabViewModel: profileTabViewModel,
                    onLogout: onLogout
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            AppGlassContainer(spacing: 16) {
                ZStack(alignment: .bottom) {
                    if shouldShowFloatingActionButton {
                        FloatingActionButton()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 18)
                            .padding(
                                .bottom,
                                BottomTabBar.occupiedHeight + Self.floatingActionButtonTabBarSpacing
                            )
                    }

                    BottomTabBar(selectedTab: coordinator.selectedTab, onSelect: coordinator.selectTab)
                }
            }
        }
        .accessibilityIdentifier("shell.content")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

#if DEBUG
#Preview("Shell Content") {
    let coordinator = ViewPreviewSupport.makeCoordinator(selectedTab: .news)

    return ShellContentView(
        viewModel: ViewPreviewSupport.makeShellViewModel(),
        coordinator: coordinator,
        newsRouter: coordinator.newsRouter,
        currentUser: ViewPreviewSupport.sampleUser,
        profileTabViewModel: ViewPreviewSupport.makeProfileTabViewModel(
            currentUser: ViewPreviewSupport.sampleUser
        ),
        onLogout: {}
    )
}
#endif
