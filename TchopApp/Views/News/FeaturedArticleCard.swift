import SwiftUI

/// Primary hero card for the featured article at the top of the feed.
struct FeaturedArticleCard: View {
    let article: FeaturedArticleCardModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(article.postedInPrefix)
                        .foregroundStyle(AppTheme.textTertiary)

                    Text(article.sourceTitle)
                        .foregroundStyle(AppTheme.accent)

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AppTheme.surfaceSecondary)
                            .frame(width: 22, height: 22)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.iconSecondary)
                    }
                }
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 14)

                ZStack(alignment: .bottomTrailing) {
                    LinearGradient(
                        colors: [
                            Color(red: 0.67, green: 0.77, blue: 0.55),
                            Color(red: 0.48, green: 0.63, blue: 0.34)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 208)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 120))
                        .foregroundStyle(.white.opacity(0.18))
                        .padding(18)
                }
                .overlay {
                    VStack {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Color(red: 0.43, green: 0.31, blue: 0.19))
                                .frame(width: 76, height: 76)

                            Circle()
                                .fill(Color(red: 0.25, green: 0.22, blue: 0.21))
                                .frame(width: 52, height: 52)

                            Circle()
                                .fill(Color(red: 0.94, green: 0.89, blue: 0.81))
                                .frame(width: 16, height: 16)
                                .offset(y: 12)
                        }
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    }
                    .padding(.bottom, 18)
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding(.horizontal, 14)

                VStack(alignment: .leading, spacing: 10) {
                    Text(article.brandTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(red: 0.36, green: 0.53, blue: 0.86))

                    Text(article.headline)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(article.summary)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(2)

                    Text(article.metadataLine)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(AppTheme.textTertiary)

                    Text(article.translationLabel)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 12)

                Divider()
                    .overlay(AppTheme.borderSubtle)

                HStack {
                    ForEach(Array(article.actions.enumerated()), id: \.element.id) { index, action in
                        ArticleActionView(action: action)

                        if index < article.actions.count - 1 {
                            Spacer()
                        }
                    }

                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.iconSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(AppTheme.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: AppTheme.shadow.opacity(0.35), radius: 6, y: 1)
        }
        .buttonStyle(.plain)
    }
}
