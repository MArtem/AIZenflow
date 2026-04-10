import SwiftUI

struct BottomTabBar: View {
    let selectedTab: AppTab
    var onSelect: (AppTab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button(action: { onSelect(tab) }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.tabIcon)
                            .font(.system(size: 20, weight: .medium))
                        Text(tab.title)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(
                        selectedTab == tab
                            ? Color(red: 0.95, green: 0.50, blue: 0.37)
                            : Color(red: 0.35, green: 0.36, blue: 0.45)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: -1)
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }
}
