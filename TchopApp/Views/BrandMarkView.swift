import SwiftUI

struct BrandMarkView: View {
    var iconSize: CGFloat
    var cardSize: CGSize

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: iconSize, height: iconSize)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 1)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.97, green: 0.95, blue: 0.92))
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
