import SwiftUI

/// Renders detail destination content for a selected news route.
struct NewsDestinationView: View {
    let route: NewsRoute

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(route.subtitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)

                Text(route.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(route.bodyText)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(3)

                if let accentLabel = route.accentLabel {
                    Text(accentLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .background(AppTheme.canvasBackground)
        .navigationTitle(titleForNavigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var titleForNavigationBar: String {
        route.destinationID == "discussion-details" ? "Discussion" : "Article"
    }
}
