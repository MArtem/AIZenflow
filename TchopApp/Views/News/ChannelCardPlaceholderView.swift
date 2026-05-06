import SwiftUI

struct ChannelCardPlaceholderView: View {
    let card: ChannelCardContent

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let mediaKind = card.mediaKind {
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppTheme.surfaceSecondary)
                    .frame(height: 180)
                    .overlay {
                        Text(mediaKind.rawValue.capitalized)
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
            }

            ForEach(Array(card.orderedTextBlocks.enumerated()), id: \.offset) { _, value in
                Text(value)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }
}
