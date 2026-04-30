import SwiftUI

/// Floating action button anchored above the bottom tab bar.
struct FloatingActionButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(AppTheme.accentOnColor)
                .frame(width: 56, height: 56)
                .appGlassChrome(
                    in: Circle(),
                    glassTint: AppTheme.floatingActionButtonFill,
                    fallbackBackground: AppTheme.floatingActionButtonFill,
                    fallbackShadowColor: AppTheme.floatingActionButtonShadow,
                    fallbackShadowRadius: 10,
                    fallbackShadowY: 6,
                    interactive: true
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppLocalization.text("accessibility.fab.create", fallback: "Create"))
        .accessibilityHint(AppLocalization.text("accessibility.fab.createHint", fallback: "Starts a new action."))
    }
}

#if DEBUG
#Preview("Floating Action Button") {
    FloatingActionButton()
        .padding()
        .background(AppTheme.canvasBackground)
}
#endif
