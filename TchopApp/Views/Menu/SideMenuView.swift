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
                        .foregroundStyle(Color(red: 0.23, green: 0.24, blue: 0.34))

                    Text(channelInfo.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.gray)
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
                                ? Color(red: 0.95, green: 0.50, blue: 0.37)
                                : Color(red: 0.29, green: 0.30, blue: 0.39)
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    selectedTab == tab
                                        ? Color(red: 0.99, green: 0.94, blue: 0.91)
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
                .foregroundStyle(.gray)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 26)
        }
        .padding(.horizontal, 18)
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
        .shadow(color: .black.opacity(0.12), radius: 18, x: 4)
        .ignoresSafeArea()
    }
}
