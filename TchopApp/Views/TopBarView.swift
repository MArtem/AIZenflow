import SwiftUI

/// Reusable top bar with menu trigger and channel metadata.
struct TopBarView: View {
    @State private var isChannelPickerPresented = false

    @ObservedObject var channelsStore: ChannelsStore
    let isSearchPresented: Bool
    var onMenuTap: () -> Void
    var onSelectChannel: (String) -> Void
    var onSearchTap: () -> Void
    var onNotificationsTap: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .font(AppTypography.shellMenuIcon)
                    .foregroundStyle(AppTheme.iconPrimary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AppLocalization.text("accessibility.topBar.menu"))
            .accessibilityHint(AppLocalization.text("accessibility.topBar.menuHint"))

            ZStack(alignment: .topLeading) {
                Button(action: presentChannelPicker) {
                    HStack(spacing: AppSpacing.sm) {
                        BrandMarkView(iconSize: 48, cardSize: CGSize(width: 28, height: 34))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(channelInfo.title)
                                .font(AppTypography.channelTitle)
                                .foregroundStyle(AppTheme.textPrimary)

                            HStack(spacing: AppSpacing.xxs) {
                                Text(channelInfo.subtitle)
                                    .font(AppTypography.channelSubtitle)
                                    .foregroundStyle(AppTheme.textTertiary)

                                Image(systemName: isChannelPickerPresented ? "chevron.up" : "chevron.down")
                                    .font(AppTypography.microLabel)
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    AppLocalization.text(
                        "accessibility.topBar.channel",
                        channelInfo.title,
                        channelInfo.subtitle
                    )
                )
                .accessibilityHint(AppLocalization.text("accessibility.topBar.channelHint"))

                if isChannelPickerPresented {
                    VStack(spacing: AppSpacing.xs) {
                        ForEach(channelsStore.channels) { channel in
                            Button(action: { handleChannelSelection(channel.id) }) {
                                HStack(spacing: AppSpacing.sm) {
                                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                        Text(channel.title)
                                            .font(AppTypography.body)
                                            .foregroundStyle(AppTheme.textPrimary)

                                        Text(channel.subtitle)
                                            .font(AppTypography.caption)
                                            .foregroundStyle(AppTheme.textTertiary)
                                    }

                                    Spacer()

                                    if channel.id == channelsStore.selectedChannelID {
                                        Image(systemName: "checkmark")
                                            .font(AppTypography.microLabel)
                                            .foregroundStyle(AppTheme.iconPrimary)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .frame(width: 260, alignment: .leading)
                                .background(AppTheme.surfacePrimary)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: AppRadius.buttonField,
                                        style: .continuous
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint(AppLocalization.text("accessibility.channel.selectHint"))
                        }
                    }
                    .padding(AppSpacing.sm)
                    .background(AppTheme.menuSurface)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                    .shadow(color: AppTheme.shadow.opacity(0.22), radius: 14, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .stroke(AppTheme.borderSubtle, lineWidth: 1)
                    )
                    .padding(.top, 56)
                    .zIndex(10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .zIndex(isChannelPickerPresented ? 10 : 1)

            Spacer()

            HStack(spacing: AppSpacing.cardSection) {
                Button(action: onSearchTap) {
                    Image(systemName: isSearchPresented ? "xmark.circle.fill" : "magnifyingglass")
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AppLocalization.text("accessibility.topBar.search"))
                .accessibilityHint(AppLocalization.text("accessibility.topBar.searchHint"))

                Button(action: onNotificationsTap) {
                    Image(systemName: "bell")
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AppLocalization.text("accessibility.topBar.notifications"))
                .accessibilityHint(AppLocalization.text("accessibility.topBar.notificationsHint"))
            }
            .font(AppTypography.shellIcon)
            .foregroundStyle(AppTheme.iconSecondary)
        }
        .padding(.horizontal, AppSpacing.shellHorizontal)
        .padding(.vertical, 14)
        .appGlassChrome(
            in: RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous),
            fallbackBackground: AppTheme.surfacePrimary,
            fallbackShadowColor: AppTheme.shadow.opacity(0.25),
            fallbackShadowRadius: 6,
            fallbackShadowY: 2
        )
        .padding(.horizontal, AppSpacing.shellHorizontal)
        .padding(.top, AppSpacing.xs)
        .zIndex(1)
    }

    /// Opens the controlled channel picker sheet.
    private func presentChannelPicker() {
        withAnimation(.easeInOut(duration: 0.16)) {
            isChannelPickerPresented.toggle()
        }
    }

    /// Current channel header derived from the source-of-truth channels store.
    private var channelInfo: ChannelHeaderInfo {
        channelsStore.selectedChannelHeaderInfo ?? AppChannel.defaultChannel.headerInfo
    }

    /// Applies a new active channel and closes the picker immediately.
    private func handleChannelSelection(_ channelID: String) {
        onSelectChannel(channelID)
        withAnimation(.easeInOut(duration: 0.16)) {
            isChannelPickerPresented = false
        }
    }
}

#if DEBUG
#Preview("Top Bar") {
    TopBarView(
        channelsStore: {
            let store = ChannelsStore(selectionStore: UserDefaultsChannelSelectionStore())
            store.setAvailableChannels(ViewPreviewSupport.sampleChannels)
            store.selectChannel(id: ViewPreviewSupport.sampleChannels.first?.id)
            return store
        }(),
        isSearchPresented: false,
        onMenuTap: {},
        onSelectChannel: { _ in },
        onSearchTap: {},
        onNotificationsTap: {}
    )
}
#endif
