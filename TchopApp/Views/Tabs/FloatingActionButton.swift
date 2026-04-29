import SwiftUI

/// Floating action button anchored above the bottom tab bar.
struct FloatingActionButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(AppTheme.floatingActionButtonFill)
                .clipShape(Circle())
                .shadow(color: AppTheme.floatingActionButtonShadow, radius: 10, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview("Floating Action Button") {
    FloatingActionButton()
        .padding()
        .background(AppTheme.canvasBackground)
}
#endif
