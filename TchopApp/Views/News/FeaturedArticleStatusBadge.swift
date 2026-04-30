import SwiftUI

/// Inline status badge shown inside feed cards while local operations are running.
struct FeedCardStatusBadge: View {
    let title: String
    let showsProgress: Bool

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            if showsProgress {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(AppTypography.labelSemibold)
            }

            Text(title)
                .font(AppTypography.labelSemibold)
                .lineLimit(1)
        }
        .foregroundStyle(AppTheme.textPrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

#if DEBUG
#Preview("Feed Status Badge") {
    FeedCardStatusBadge(
        title: "Saving reaction...",
        showsProgress: true
    )
    .padding()
    .background(AppTheme.canvasBackground)
}
#endif
