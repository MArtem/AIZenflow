import SwiftUI

/// Floating action button anchored above the bottom tab bar.
struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        let glassStyle = AppTheme.glassStyle(for: .floatingActionButton)

        Button(action: action) {
            Image(systemName: "plus")
                .font(AppTypography.fabIcon)
                .foregroundStyle(AppTheme.accentOnColor)
                .frame(width: 56, height: 56)
                .appGlassChrome(
                    in: Circle(),
                    glassTint: glassStyle?.tint,
                    glassStroke: glassStyle?.stroke,
                    fallbackBackground: AppTheme.floatingActionButtonFill,
                    fallbackShadowColor: AppTheme.floatingActionButtonShadow,
                    fallbackShadowRadius: 10,
                    fallbackShadowY: 6,
                    interactive: true
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppLocalization.text("accessibility.fab.create"))
        .accessibilityHint(AppLocalization.text("accessibility.fab.createHint"))
    }
}

#if DEBUG
#Preview("Floating Action Button") {
    FloatingActionButton(action: {})
        .padding()
        .background(AppTheme.canvasBackground)
}
#endif
