import SwiftUI
import AppGlassUI

/// Floating action button anchored above the bottom tab bar.
struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        let glassStyle = AppTheme.glassStyle(for: .floatingActionButton)

        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.clear)
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

                Image(systemName: "plus")
                    .font(AppTypography.fabIcon)
                    .foregroundStyle(AppTheme.accentOnColor)
                    .accessibilityHidden(true)
            }
            .frame(width: 56, height: 56)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("shell.fab.create")
        .accessibilityLabel(AppLocalization.text("accessibility.fab.create"))
        .accessibilityHint(AppLocalization.text("accessibility.fab.createHint"))
        .accessibilityRepresentation {
            Button(AppLocalization.text("accessibility.fab.create"), action: action)
                .accessibilityIdentifier("shell.fab.create")
                .accessibilityHint(AppLocalization.text("accessibility.fab.createHint"))
        }
    }
}

#if DEBUG
#Preview("Floating Action Button") {
    FloatingActionButton(action: {})
        .padding()
        .background(AppTheme.canvasBackground)
}
#endif
