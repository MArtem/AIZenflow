import SwiftUI

/// Simple placeholder used for tabs not yet backed by real feature screens.
struct TabStubView: View {
    var tab: AppTab
    let onOpenSample: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.featureSection) {
            Spacer(minLength: 40)

            ZStack {
                Circle()
                    .fill(AppTheme.surfacePrimary)
                    .frame(width: 96, height: 96)
                    .shadow(color: AppTheme.shadow.opacity(0.35), radius: 10, y: 4)

                Image(systemName: tab.menuIcon)
                    .font(AppTypography.heroDisplay)
                    .foregroundStyle(AppTheme.accent)
            }

            VStack(spacing: 10) {
                Text(tab.title)
                    .font(AppTypography.profileDisplay)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(tab.stubDescription)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onOpenSample) {
                Text(AppLocalization.text("tab.stub.openSampleScreen"))
                    .font(AppTypography.bodySemibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(AppTheme.accent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
        .padding(.bottom, AppSpacing.shellBottomInset)
        .background(Color.clear)
    }
}

#if DEBUG
#Preview("Tab Stub") {
    TabStubView(
        tab: .pinned,
        onOpenSample: {}
    )
}
#endif
