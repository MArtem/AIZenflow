import SwiftUI

/// Reusable top bar with menu trigger and channel metadata.
struct TopBarView: View {
    @State private var isChannelPickerPresented = false

    let channelInfo: ChannelHeaderInfo
    let availableChannels: [AppChannel]
    let selectedChannelID: String?
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

                            Image(systemName: "chevron.down")
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
        .sheet(isPresented: $isChannelPickerPresented) {
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: AppSpacing.sm) {
                        ForEach(availableChannels) { channel in
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

                                    if channel.id == selectedChannelID {
                                        Image(systemName: "checkmark")
                                            .font(AppTypography.microLabel)
                                            .foregroundStyle(AppTheme.iconPrimary)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.surfacePrimary)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: AppRadius.buttonField,
                                        style: .continuous
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(
                                        cornerRadius: AppRadius.buttonField,
                                        style: .continuous
                                    )
                                    .stroke(
                                        channel.id == selectedChannelID
                                            ? AppTheme.accent.opacity(0.22)
                                            : AppTheme.borderSubtle,
                                        lineWidth: 1
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint(AppLocalization.text("accessibility.channel.selectHint"))
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, AppSpacing.xl)
                }
                .background(AppTheme.canvasBackground.ignoresSafeArea())
                .navigationTitle(AppLocalization.text("channels.section.title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(AppLocalization.text("common.done")) {
                            isChannelPickerPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    /// Opens the controlled channel picker sheet.
    private func presentChannelPicker() {
        isChannelPickerPresented = true
    }

    /// Applies a new active channel and closes the picker immediately.
    private func handleChannelSelection(_ channelID: String) {
        onSelectChannel(channelID)
        isChannelPickerPresented = false
    }
}

#if DEBUG
#Preview("Top Bar") {
    TopBarView(
        channelInfo: ViewPreviewSupport.sampleChannelInfo,
        availableChannels: ViewPreviewSupport.sampleChannels,
        selectedChannelID: ViewPreviewSupport.sampleChannels.first?.id,
        isSearchPresented: false,
        onMenuTap: {},
        onSelectChannel: { _ in },
        onSearchTap: {},
        onNotificationsTap: {}
    )
}
#endif
