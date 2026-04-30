import SwiftUI

/// Reusable top bar with menu trigger and channel metadata.
struct TopBarView: View {
    let channelInfo: ChannelHeaderInfo
    var onMenuTap: () -> Void
    var onChannelTap: () -> Void
    var onSearchTap: () -> Void
    var onNotificationsTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(AppTheme.iconPrimary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AppLocalization.text("accessibility.topBar.menu"))
            .accessibilityHint(AppLocalization.text("accessibility.topBar.menuHint"))

            Button(action: onChannelTap) {
                HStack(spacing: 12) {
                    BrandMarkView(iconSize: 48, cardSize: CGSize(width: 28, height: 34))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(channelInfo.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)

                        HStack(spacing: 4) {
                            Text(channelInfo.subtitle)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(AppTheme.textTertiary)

                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .semibold))
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

            HStack(spacing: 18) {
                Button(action: onSearchTap) {
                    Image(systemName: "magnifyingglass")
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
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(AppTheme.iconSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .appGlassChrome(
            in: RoundedRectangle(cornerRadius: 24, style: .continuous),
            fallbackBackground: AppTheme.surfacePrimary,
            fallbackShadowColor: AppTheme.shadow.opacity(0.25),
            fallbackShadowRadius: 6,
            fallbackShadowY: 2
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .zIndex(1)
    }
}

#if DEBUG
#Preview("Top Bar") {
    TopBarView(
        channelInfo: ViewPreviewSupport.sampleChannelInfo,
        onMenuTap: {},
        onChannelTap: {},
        onSearchTap: {},
        onNotificationsTap: {}
    )
}
#endif
