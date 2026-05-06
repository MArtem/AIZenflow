import SwiftUI

/// Compact action cluster shown under article content cards.
struct ArticleActionView: View {
    let action: ArticleActionItem
    let isActive: Bool
    let isLoading: Bool
    let isDisabled: Bool
    let title: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: action.systemName)
                        .font(AppTypography.detailSemibold)
                }

                Text(title)
                    .font(AppTypography.captionSemibold)
                    .lineLimit(1)
            }
            .foregroundStyle(isActive ? AppTheme.accent : AppTheme.textTertiary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(AppLocalization.text("accessibility.news.cardActionHint"))
        .accessibilityValue(accessibilityValueText)
        .disabled(isDisabled)
        .opacity(isDisabled && !isLoading ? 0.55 : 1)
    }

    private var accessibilityValueText: String {
        if isLoading {
            return AppLocalization.text("accessibility.news.cardActionLoading")
        }

        if isActive {
            return AppLocalization.text("accessibility.news.cardActionActive")
        }

        return ""
    }
}

#if DEBUG
#Preview("Article Action") {
    ArticleActionView(
        action: ViewPreviewSupport.sampleFeaturedArticle.actions[0],
        isActive: true,
        isLoading: false,
        isDisabled: false,
        title: "Liked",
        onTap: {}
    )
    .padding()
    .background(AppTheme.surfacePrimary)
}
#endif
