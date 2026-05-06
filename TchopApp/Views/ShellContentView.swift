import Observation
import SwiftUI
import TchopNavigation

private struct FeedComposerView: View {
    @Bindable var viewModel: FeedComposerViewModel
    let onCancel: () -> Void
    let onPublish: () -> Void

    @State private var showsInsertionSheet = false
    @State private var showsChannelSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        composerField(
                            title: nil,
                            placeholder: ChannelCardTextFieldKind.text.placeholder,
                            text: $viewModel.text,
                            minimumHeight: 180
                        )

                        if viewModel.showsHeadlineField {
                            composerField(
                                title: ChannelCardTextFieldKind.headline.title,
                                placeholder: ChannelCardTextFieldKind.headline.placeholder,
                                text: $viewModel.headline
                            )
                        }

                        if viewModel.showsSubheadlineField {
                            composerField(
                                title: ChannelCardTextFieldKind.subheadline.title,
                                placeholder: ChannelCardTextFieldKind.subheadline.placeholder,
                                text: $viewModel.subheadline
                            )
                        }

                        if viewModel.showsSourceField {
                            composerField(
                                title: ChannelCardTextFieldKind.source.title,
                                placeholder: ChannelCardTextFieldKind.source.placeholder,
                                text: $viewModel.source
                            )
                        }

                        if let mediaKind = viewModel.mediaKind {
                            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                                .fill(AppTheme.surfaceSecondary)
                                .frame(height: 180)
                                .overlay {
                                    Text(mediaKind.rawValue.capitalized)
                                        .font(AppTypography.cardTitle)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, 96)
                }
            }

            toolbar

            if showsInsertionSheet {
                bottomSheet(
                    items: viewModel.availableInsertions.map(\.title),
                    onSelect: { title in
                        if let insertion = viewModel.availableInsertions.first(where: { $0.title == title }) {
                            viewModel.applyInsertion(insertion)
                        }
                    },
                    onDismiss: { showsInsertionSheet = false }
                )
            }

            if showsChannelSheet {
                bottomSheet(
                    items: viewModel.availableChannels.map(\.title),
                    onSelect: { title in
                        if let channel = viewModel.availableChannels.first(where: { $0.title == title }) {
                            viewModel.selectChannel(id: channel.id)
                        }
                    },
                    onDismiss: { showsChannelSheet = false }
                )
            }
        }
        .background(AppTheme.canvasBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button("Cancel", action: onCancel)
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.accent)

            Spacer()

            HStack(spacing: AppSpacing.xs) {
                Text("Post in")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppTheme.textPrimary)

                Button(action: { showsChannelSheet = true }) {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedChannelTitle)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppTheme.accent)
                }
                .buttonStyle(.plain)
            }

            Spacer()
            Color.clear.frame(width: 52)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.md)
        .background(AppTheme.surfacePrimary)
    }

    private var toolbar: some View {
        HStack {
            Button(action: { showsInsertionSheet = true }) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "plus")
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(AppTheme.textPrimary)
            }
            .buttonStyle(.plain)

            Spacer()

            if viewModel.mediaKind == nil || viewModel.mediaKind == .photo {
                Button(action: { showsInsertionSheet = true }) {
                    Image(systemName: "photo")
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, AppSpacing.lg)
            }

            Button(action: {
                guard viewModel.publish() != nil else { return }
                onPublish()
            }) {
                Text("Publish")
                    .font(AppTypography.bodySemibold)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AppTheme.accent.opacity(viewModel.canPublish ? 1 : 0.5))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canPublish)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.md)
        .background(AppTheme.surfaceSecondary)
    }

    private func composerField(
        title: String?,
        placeholder: String,
        text: Binding<String>,
        minimumHeight: CGFloat = 64
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if let title {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(AppTypography.body)
                        .foregroundStyle(AppTheme.textTertiary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }

                TextEditor(text: text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: minimumHeight)
                    .padding(.horizontal, -4)
            }
        }
    }

    private func bottomSheet(
        items: [String],
        onSelect: @escaping (String) -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(alignment: .leading, spacing: 0) {
                Capsule(style: .continuous)
                    .fill(AppTheme.textTertiary.opacity(0.3))
                    .frame(width: 50, height: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)

                ForEach(items, id: \.self) { item in
                    Button {
                        onSelect(item)
                        onDismiss()
                    } label: {
                        Text(item)
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                            .padding(.vertical, AppSpacing.md)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(AppTheme.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 8)
            .padding(.bottom, 24)
        }
    }
}

/// Layout wrapper combining top chrome, tab content, and overlays.
struct ShellContentView: View {
    private static let floatingActionButtonTabBarSpacing: CGFloat = 15

    let viewModel: AppShellViewModel
    let coordinator: AppCoordinator
    @Bindable var newsRouter: TabRouter<NewsRoute>
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

            AppGlassContainer(spacing: 16) {
                ZStack(alignment: .bottom) {
                    if shouldShowFloatingActionButton {
                        FloatingActionButton(action: viewModel.presentComposer)
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
        .sheet(
            isPresented: Binding(
                get: { viewModel.activeComposer != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissComposer()
                    }
                }
            )
        ) {
            if let composer = viewModel.activeComposer {
                FeedComposerView(
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
