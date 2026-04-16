import SwiftUI

struct SideMenuView: View {
    let channelInfo: ChannelHeaderInfo
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
