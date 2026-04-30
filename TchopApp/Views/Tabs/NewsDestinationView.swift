import SwiftUI

/// Renders detail destination content for a selected news route.
struct NewsDestinationView: View {
    let route: NewsRoute

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.cardSection) {
                Text(route.subtitle)
                    .font(AppTypography.captionSemibold)
                    .foregroundStyle(AppTheme.accent)

                Text(route.title)
                    .font(AppTypography.profileDisplay)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(route.bodyText)
                    .font(AppTypography.bodyRegular)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(3)

                if let accentLabel = route.accentLabel {
                    Text(accentLabel)
                        .font(AppTypography.detailSemibold)
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.cardPadding)
        }
        .background(AppTheme.canvasBackground)
        .navigationTitle(titleForNavigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var titleForNavigationBar: String {
        route.destinationID == "discussion-details"
            ? AppLocalization.text("news.destination.title.discussion")
            : AppLocalization.text("news.destination.title.article")
    }
}

#if DEBUG
#Preview("News Destination") {
    NavigationStack {
        NewsDestinationView(route: ViewPreviewSupport.sampleNewsRoute)
    }
}
#endif
