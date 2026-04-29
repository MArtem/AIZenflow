import SwiftUI
import TchopNavigation
import TchopErrors

/// Layout wrapper combining top chrome, tab content, and overlays.
struct ShellContentView: View {
    private static let floatingActionButtonTabBarSpacing: CGFloat = 15

    @ObservedObject var viewModel: AppShellViewModel
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var newsRouter: TabRouter<NewsRoute>
    let errorManager: any AppErrorManaging
    let currentUser: AppUser?
    let onNavigationRestoreChange: (Bool) throws -> Void
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
                    onChannelTap: {},
                    onSearchTap: {},
                    onNotificationsTap: {}
                )

                TabContentView(
                    selectedTab: coordinator.selectedTab,
                    coordinator: coordinator,
                    newsFeedViewModel: viewModel.newsFeedViewModel,
                    errorManager: errorManager,
                    onNewsFeedScrollProximityChange: viewModel.setNewsFeedNearTop,
                    currentUser: currentUser,
                    onNavigationRestoreChange: onNavigationRestoreChange,
                    onLogout: onLogout
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

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
        errorManager: ViewPreviewSupport.makeErrorManager(),
        currentUser: ViewPreviewSupport.sampleUser,
        onNavigationRestoreChange: { _ in },
        onLogout: {}
    )
}
#endif
