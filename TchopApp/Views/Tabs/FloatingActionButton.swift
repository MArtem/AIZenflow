import SwiftUI

/// Floating action button anchored above the bottom tab bar.
struct FloatingActionButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(AppTheme.accent)
                .clipShape(Circle())
                .shadow(color: AppTheme.accent.opacity(0.35), radius: 10, y: 6)
        }
        .buttonStyle(.plain)
    }
}
