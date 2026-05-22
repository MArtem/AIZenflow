import Observation
import SwiftUI
#if !APP_EXTENSION
import TchopNavigation

/// Layout wrapper combining top chrome, tab content, and overlays.
struct ShellContentView: View {
    private static let floatingActionButtonTabBarSpacing: CGFloat = 15

    let viewModel: AppShellViewModel
    let coordinator: AppCoordinator
    @Bindable var newsRouter: TabRouter<NewsRoute>
    let currentUser: AppUser?
    let profileTabViewModel: ProfileTabViewModel?
    let onLogout: () -> Void

    private var composerIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.activeComposer != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissComposer()
                }
            }
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TopBarView(
                    channelsStore: viewModel.channelsStore,
                    isSearchPresented: viewModel.newsFeedViewModel.isSearchPresented,
                    onMenuTap: viewModel.toggleMenu,
                    onSelectChannel: handleChannelSelection,
                    onSearchTap: handleSearchTap,
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

            ShellBottomChromeHostView(
                viewModel: viewModel,
                selectedTab: coordinator.selectedTab,
                newsRouteIsAtRoot: newsRouter.path.isEmpty,
                onSelectTab: coordinator.selectTab
            )
        }
        .accessibilityIdentifier("shell.content")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .fullScreenCover(isPresented: composerIsPresented) {
            if let composer = viewModel.activeComposer {
                SharedCardComposerView(
                    viewModel: composer,
                    onCancel: viewModel.dismissComposer,
                    onPublish: viewModel.publishComposer
                )
            }
        }
    }

    /// Applies one selected channel from the top-bar dropdown and keeps the shell on the news tab.
    private func handleChannelSelection(_ channelID: String) {
        viewModel.selectChannel(id: channelID)
        coordinator.selectTab(.news)
    }

    /// Opens or closes search for the current channel feed.
    private func handleSearchTap() {
        if coordinator.selectedTab != .news {
            coordinator.selectTab(.news)
        }

        viewModel.newsFeedViewModel.toggleSearchPresentation()
    }
}

private struct ShellBottomChromeHostView: View {
    let viewModel: AppShellViewModel
    let selectedTab: AppTab
    let newsRouteIsAtRoot: Bool
    let onSelectTab: (AppTab) -> Void

    /// Whether the shell-level floating action button is allowed for the current tab, route depth and scroll position.
    private var shouldShowFloatingActionButton: Bool {
        selectedTab == .news &&
            newsRouteIsAtRoot &&
            viewModel.showsFloatingActionButton &&
            viewModel.isNewsFeedNearTop
    }

    var body: some View {
        ShellBottomChromeView(
            selectedTab: selectedTab,
            shouldShowFloatingActionButton: shouldShowFloatingActionButton,
            onFloatingActionTap: viewModel.presentComposer,
            onSelectTab: onSelectTab
        )
    }
}

private struct ShellBottomChromeView: View {
    private static let floatingActionButtonTabBarSpacing: CGFloat = 15

    let selectedTab: AppTab
    let shouldShowFloatingActionButton: Bool
    let onFloatingActionTap: () -> Void
    let onSelectTab: (AppTab) -> Void

    var body: some View {
        AppGlassContainer(spacing: 16) {
            ZStack(alignment: .bottom) {
                if shouldShowFloatingActionButton {
                    FloatingActionButton(action: onFloatingActionTap)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 18)
                        .padding(
                            .bottom,
                            BottomTabBar.occupiedHeight + Self.floatingActionButtonTabBarSpacing
                        )
                }

                BottomTabBar(selectedTab: selectedTab, onSelect: onSelectTab)
            }
        }
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
#endif
