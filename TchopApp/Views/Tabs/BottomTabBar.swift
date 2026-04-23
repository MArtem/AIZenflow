import SwiftUI

/// Custom bottom tab bar that drives coordinator tab selection.
struct BottomTabBar: View {
    static let contentHeight: CGFloat = 67
    static let bottomSpacing: CGFloat = 8
    static let occupiedHeight: CGFloat = contentHeight + bottomSpacing

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
                            ? AppTheme.accent
                            : AppTheme.textSecondary
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .frame(height: Self.contentHeight)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: AppTheme.shadow.opacity(0.4), radius: 10, y: -1)
        .padding(.horizontal, 10)
        .padding(.bottom, Self.bottomSpacing)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}
