import SwiftUI

/// Generic destination view used by scaffolded feature-tab routes.
struct StubTabDetailView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.cardSection) {
            Text(title)
                .font(AppTypography.profileDisplay)
                .foregroundStyle(AppTheme.textPrimary)

            Text(description)
                .font(AppTypography.bodyRegular)
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(3)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(AppSpacing.cardPadding)
        .background(AppTheme.canvasBackground)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
#Preview("Stub Tab Detail") {
    NavigationStack {
        StubTabDetailView(
            title: "Preview Detail",
            description: "This preview keeps scaffolded destination copy visible and current."
        )
    }
}
#endif
