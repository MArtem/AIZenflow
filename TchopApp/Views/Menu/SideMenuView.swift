import SwiftUI

/// Slide-out menu with app-level navigation actions.
struct SideMenuView: View {
    let channelsStore: ChannelsStore
    let accountSummary: AccountProfileSummary?
    let selectedTab: AppTab
    let footerText: String
    var onSelect: (AppTab) -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.featureSection) {
                    HStack(spacing: 14) {
                        BrandMarkView(iconSize: 54, cardSize: CGSize(width: 30, height: 36))

                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(channelInfo.title)
                                .font(AppTypography.menuTitle)
                                .foregroundStyle(AppTheme.textPrimary)

                            Text(channelInfo.subtitle)
                                .font(AppTypography.detail)
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isHeader)

                    VStack(spacing: AppSpacing.xs) {
                        ForEach(AppTab.allCases) { tab in
                            Button(action: { onSelect(tab) }) {
                                HStack(spacing: 14) {
                                    Image(systemName: tab.menuIcon)
                                        .font(AppTypography.cardTitle)
                                        .frame(width: 22)

                                    Text(tab.title)
                                        .font(AppTypography.actionTitle)

                                    Spacer()

                                    if selectedTab == tab {
                                        Image(systemName: "checkmark")
                                            .font(AppTypography.captionSemibold)
                                    }
                                }
                                .foregroundStyle(
                                    selectedTab == tab
                                        ? AppTheme.accent
                                        : AppTheme.textSecondary
                                )
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: AppRadius.menuSelection, style: .continuous)
                                        .fill(
                                            selectedTab == tab
                                                ? AppTheme.selectionFill
                                                : Color.clear
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(tab.title)
                            .accessibilityValue(
                                selectedTab == tab
                                    ? AppLocalization.text("accessibility.tab.selected")
                                    : AppLocalization.text("accessibility.tab.notSelected")
                            )
                            .accessibilityHint(AppLocalization.text("accessibility.sideMenu.tabHint"))
                        }
                    }

                    if let accountSummary {
                        SideMenuAccountSummaryCard(accountSummary: accountSummary)
                    }

                    Text(footerText)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.horizontal, 18)
                .padding(.top, max(22, proxy.safeAreaInsets.top + AppSpacing.sm))
                .padding(.bottom, max(26, proxy.safeAreaInsets.bottom + AppSpacing.md))
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
            .background(AppTheme.menuSurface)
            .shadow(color: AppTheme.shadow.opacity(0.5), radius: 18, x: 4)
            .ignoresSafeArea()
        }
    }

    private var channelInfo: ChannelHeaderInfo {
        channelsStore.selectionSnapshot.selectedChannel?.headerInfo ??
            channelsStore.selectionSnapshot.availableChannels.first?.headerInfo ??
            AppChannel.defaultChannel.headerInfo
    }
}

private struct SideMenuAccountSummaryCard: View {
    let accountSummary: AccountProfileSummary

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(AppTheme.surfacePrimary)
                .frame(width: 42, height: 42)
                .overlay(
                    Text(accountSummary.initials)
                        .font(AppTypography.detailSemibold)
                        .foregroundStyle(AppTheme.accent)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(accountSummary.displayName)
                    .font(AppTypography.bodySemibold)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Text(accountSummary.providerTitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textTertiary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(14)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            AppLocalization.text(
                "accessibility.sideMenu.account",
                accountSummary.displayName,
                accountSummary.providerTitle
            )
        )
    }
}

#if DEBUG
#Preview("Side Menu") {
    SideMenuView(
        channelsStore: {
            let store = ChannelsStore(selectionStore: UserDefaultsChannelSelectionStore())
            store.setAvailableChannels(ViewPreviewSupport.sampleChannels)
            store.selectChannel(id: ViewPreviewSupport.sampleChannels.first?.id)
            return store
        }(),
        accountSummary: ViewPreviewSupport.sampleAccountSummary,
        selectedTab: .news,
        footerText: AppLocalization.text("menu.footer"),
        onSelect: { _ in }
    )
    .frame(width: 320)
}
#endif
