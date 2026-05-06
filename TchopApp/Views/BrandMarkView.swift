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
            BrandMarkPalette.orange
        case .blue:
            BrandMarkPalette.blue
        case .yellow:
            BrandMarkPalette.yellow
        case .gray:
            BrandMarkPalette.gray
        }
    }
}

private enum BrandMarkPalette {
    static let orange = Color.orange
    static let blue = Color.blue
    static let yellow = Color.yellow
    static let gray = Color.gray.opacity(0.8)
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
