import Observation
import SwiftUI
#if !APP_EXTENSION

/// Layout wrapper combining top chrome, tab content, and overlays.
struct ShellContentView: View {
    private static let floatingActionButtonTabBarSpacing: CGFloat = 15

    let viewModel: AppShellViewModel
    let coordinator: AppCoordinator
    @Bindable var newsRouter: TabRouter<NewsRoute>
    let currentUser: AppUser?
    let profileTabViewModel: ProfileTabViewModel?
    let onLogout: () -> Void
    @State private var isNewsFeedNearTop = true
    @State private var isCreateActionSheetPresented = false

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
                    onNewsFeedScrollProximityChange: handleNewsFeedScrollProximityChange,
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
                isNewsFeedNearTop: isNewsFeedNearTop,
                onFloatingActionTap: presentCreateActionSheet,
                onSelectTab: coordinator.selectTab
            )

            if isCreateActionSheetPresented {
                ShellCreateActionSheetOverlay(
                    onDismiss: dismissCreateActionSheet,
                    onNewPost: handleNewPostAction,
                    onCreateThread: dismissCreateActionSheet,
                    onNewEvent: dismissCreateActionSheet,
                    onNewPoll: dismissCreateActionSheet
                )
                .transition(.opacity)
                .zIndex(20)
            }
        }
        .accessibilityIdentifier("shell.content")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .animation(.easeInOut(duration: 0.18), value: isCreateActionSheetPresented)
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

    /// Stores the feed proximity in local view state so bottom chrome visibility is updated deterministically.
    private func handleNewsFeedScrollProximityChange(_ isNearTop: Bool) {
        guard isNewsFeedNearTop != isNearTop else {
            return
        }

        isNewsFeedNearTop = isNearTop
        viewModel.setNewsFeedNearTop(isNearTop)
    }

    /// Opens or closes search for the current channel feed.
    private func handleSearchTap() {
        if coordinator.selectedTab != .news {
            coordinator.selectTab(.news)
        }

        viewModel.newsFeedViewModel.send(.searchPresentationToggled)
    }

    /// Presents the shell-level create menu anchored above the bottom safe area.
    private func presentCreateActionSheet() {
        isCreateActionSheetPresented = true
    }

    /// Dismisses the create menu without changing product state.
    private func dismissCreateActionSheet() {
        isCreateActionSheetPresented = false
    }

    /// Opens the existing post composer from the create menu.
    private func handleNewPostAction() {
        dismissCreateActionSheet()
        viewModel.presentComposer()
    }
}

private struct ShellBottomChromeHostView: View {
    let viewModel: AppShellViewModel
    let selectedTab: AppTab
    let newsRouteIsAtRoot: Bool
    let isNewsFeedNearTop: Bool
    let onFloatingActionTap: () -> Void
    let onSelectTab: (AppTab) -> Void

    /// Whether the shell-level floating action button is allowed for the current tab, route depth and scroll position.
    private var shouldShowFloatingActionButton: Bool {
        selectedTab == .news &&
            newsRouteIsAtRoot &&
            viewModel.showsFloatingActionButton &&
            isNewsFeedNearTop
    }

    var body: some View {
        ShellBottomChromeView(
            selectedTab: selectedTab,
            shouldShowFloatingActionButton: shouldShowFloatingActionButton,
            onFloatingActionTap: onFloatingActionTap,
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

private struct ShellCreateActionSheetOverlay: View {
    let onDismiss: () -> Void
    let onNewPost: () -> Void
    let onCreateThread: () -> Void
    let onNewEvent: () -> Void
    let onNewPoll: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Button(action: onDismiss) {
                Color(red: 35.0 / 255.0, green: 35.0 / 255.0, blue: 46.0 / 255.0)
                    .opacity(0.5)
                    .ignoresSafeArea()
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AppLocalization.text("common.close"))

            ShellCreateActionSheetContent(
                onNewPost: onNewPost,
                onCreateThread: onCreateThread,
                onNewEvent: onNewEvent,
                onNewPoll: onNewPoll
            )
            .padding(.horizontal, AppSpacing.xs)
            .padding(.bottom, AppSpacing.xxxl)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .accessibilityIdentifier("shell.createActionSheet")
    }
}

private struct ShellCreateActionSheetContent: View {
    let onNewPost: () -> Void
    let onCreateThread: () -> Void
    let onNewEvent: () -> Void
    let onNewPoll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ShellCreateActionSheetGrabberView()

            ShellCreateActionSheetItemView(
                title: AppLocalization.text("shell.createAction.newPost"),
                assetName: "ShellCreatePencilSimple",
                iconBackground: Color(red: 252.0 / 255.0, green: 241.0 / 255.0, blue: 238.0 / 255.0),
                action: onNewPost
            )

            ShellCreateActionSheetItemView(
                title: AppLocalization.text("shell.createAction.createThread"),
                assetName: "ShellCreateChat",
                iconBackground: AppTheme.surfaceSecondary,
                action: onCreateThread
            )

            ShellCreateActionSheetItemView(
                title: AppLocalization.text("shell.createAction.newEvent"),
                assetName: "ShellCreateCalendarCheck",
                iconBackground: Color(red: 235.0 / 255.0, green: 246.0 / 255.0, blue: 252.0 / 255.0),
                action: onNewEvent
            )

            ShellCreateActionSheetItemView(
                title: AppLocalization.text("shell.createAction.newPoll"),
                assetName: "ShellCreateListChecks",
                iconBackground: Color(red: 195.0 / 255.0, green: 247.0 / 255.0, blue: 223.0 / 255.0),
                action: onNewPoll
            )
        }
        .padding(.bottom, AppSpacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

private struct ShellCreateActionSheetGrabberView: View {
    var body: some View {
        HStack {
            Spacer()
            Capsule()
                .fill(Color(red: 222.0 / 255.0, green: 222.0 / 255.0, blue: 222.0 / 255.0))
                .frame(width: 50, height: 5)
            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.xs)
        .accessibilityHidden(true)
    }
}

private struct ShellCreateActionSheetItemView: View {
    let title: String
    let assetName: String
    let iconBackground: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(assetName)
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .accessibilityHidden(true)
                    }

                Text(title)
                    .font(AppTypography.bodyRegular)
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
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
