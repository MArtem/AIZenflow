import SwiftUI

/// Compact brand mark icon used in top bar and authentication UI.
struct BrandMarkView: View {
    var iconSize: CGFloat
    var cardSize: CGSize

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.surfacePrimary)
                .frame(width: iconSize, height: iconSize)
                .shadow(color: AppTheme.shadow.opacity(0.25), radius: 6, y: 1)

            RoundedRectangle(cornerRadius: AppRadius.badge)
                .fill(AppTheme.surfaceSecondary)
                .frame(width: cardSize.width, height: cardSize.height)

            VStack(spacing: 2) {
                ForEach(BrandStripe.allCases) { stripe in
                    Capsule()
                        .fill(stripe.color)
                        .frame(width: 18, height: 4)
                }
            }
            .rotationEffect(.degrees(-8))
        }
        .accessibilityHidden(true)
    }
}

private enum BrandStripe: CaseIterable, Identifiable {
    case orange
    case blue
    case yellow
    case gray

    var id: Self { self }

    var color: Color {
        switch self {
        case .orange:
            .orange
        case .blue:
            .blue
        case .yellow:
            .yellow
        case .gray:
            .gray.opacity(0.8)
        }
    }
}

#if DEBUG
#Preview("Brand Mark") {
    BrandMarkView(
        iconSize: 48,
        cardSize: CGSize(width: 28, height: 34)
    )
    .padding()
    .background(AppTheme.canvasBackground)
}
#endif
