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
                BottomTabBarItemView(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    onTap: { onSelect(tab) }
                )
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .frame(height: Self.contentHeight)
        .appGlassChrome(
            in: RoundedRectangle(cornerRadius: AppRadius.quickAction, style: .continuous),
            fallbackBackground: AppTheme.surfacePrimary,
            fallbackShadowColor: AppTheme.shadow.opacity(0.4),
            fallbackShadowRadius: 10,
            fallbackShadowY: -1
        )
        .padding(.horizontal, 10)
        .padding(.bottom, Self.bottomSpacing)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

private struct BottomTabBarItemView: View {
    let tab: AppTab
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: tab.tabIcon)
                    .font(AppTypography.shellMenuIcon)
                Text(tab.title)
                    .font(AppTypography.eyebrowStrong)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isSelected ? AppTheme.accent : AppTheme.textSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityValue(
            isSelected
                ? AppLocalization.text("accessibility.tab.selected")
                : AppLocalization.text("accessibility.tab.notSelected")
        )
        .accessibilityHint(AppLocalization.text("accessibility.tab.switchHint"))
    }
}

#if DEBUG
#Preview("Bottom Tab Bar") {
    BottomTabBar(
        selectedTab: .news,
        onSelect: { _ in }
    )
    .background(AppTheme.canvasBackground)
}
#endif
