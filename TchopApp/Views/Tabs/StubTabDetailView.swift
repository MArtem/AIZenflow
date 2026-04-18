import SwiftUI

/// Generic destination view used by scaffolded feature-tab routes.
struct StubTabDetailView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(description)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(3)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(20)
        .background(AppTheme.canvasBackground)
        .navigationBarTitleDisplayMode(.inline)
    }
}
