import SwiftUI

/// Slide-out menu with app-level navigation actions.
struct SideMenuView: View {
    let channelInfo: ChannelHeaderInfo
    let accountSummary: AccountProfileSummary?
    let selectedTab: AppTab
    let footerText: String
    var onSelect: (AppTab) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 14) {
                BrandMarkView(iconSize: 54, cardSize: CGSize(width: 30, height: 36))

                VStack(alignment: .leading, spacing: 4) {
                    Text(channelInfo.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(channelInfo.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
            .padding(.top, 22)

            VStack(spacing: 8) {
                ForEach(AppTab.allCases) { tab in
                    Button(action: { onSelect(tab) }) {
                        HStack(spacing: 14) {
                            Image(systemName: tab.menuIcon)
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 22)

                            Text(tab.title)
                                .font(.system(size: 16, weight: .semibold))

                            Spacer()

                            if selectedTab == tab {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
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
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    selectedTab == tab
                                        ? AppTheme.selectionFill
                                        : Color.clear
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            if let accountSummary {
                SideMenuAccountSummaryCard(accountSummary: accountSummary)
            }

            Text(footerText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 26)
        }
        .padding(.horizontal, 18)
        .background(AppTheme.menuSurface)
        .shadow(color: AppTheme.shadow.opacity(0.5), radius: 18, x: 4)
        .ignoresSafeArea()
    }
}

private struct SideMenuAccountSummaryCard: View {
    let accountSummary: AccountProfileSummary

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppTheme.surfacePrimary)
                .frame(width: 42, height: 42)
                .overlay(
                    Text(accountSummary.initials)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.accent)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(accountSummary.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Text(accountSummary.providerTitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(14)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
