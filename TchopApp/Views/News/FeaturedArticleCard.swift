import SwiftUI

/// Primary hero card for the featured article at the top of the feed.
struct FeaturedArticleCard: View {
    let article: FeaturedArticleCardModel
    let onTap: () -> Void
    let onAction: (FeaturedArticleCardAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                        .accessibilityHidden(true)
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
                        .frame(height: article.uiState.displayMode == .expanded ? 208 : 156)

                        Image(systemName: "pawprint.fill")
                            .font(.system(size: article.uiState.displayMode == .expanded ? 120 : 88))
                            .foregroundStyle(.white.opacity(0.18))
                            .padding(18)
                            .accessibilityHidden(true)
                    }
                    .overlay {
                        VStack(spacing: 8) {
                            if let pendingOperation = article.uiState.pendingOperation {
                                FeedCardStatusBadge(
                                    title: pendingOperation.statusText,
                                    showsProgress: true
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 14)
                                .padding(.horizontal, 14)
                            } else if let inlineStatusMessage = article.uiState.inlineStatusMessage {
                                FeedCardStatusBadge(
                                    title: inlineStatusMessage,
                                    showsProgress: false
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 14)
                                .padding(.horizontal, 14)
                            }

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
                            .accessibilityHidden(true)
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
                            .font(.system(size: article.uiState.displayMode == .expanded ? 18 : 16, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        if article.uiState.displayMode == .expanded {
                            Text(article.summary)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineSpacing(2)
                        }

                        Text(article.metadataLine)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(AppTheme.textTertiary)

                        if article.uiState.displayMode == .expanded {
                            Text(article.translationLabel)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppTheme.accent)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                AppLocalization.text(
                    "accessibility.news.featuredCard",
                    fallback: "%@. %@. %@.",
                    article.sourceTitle,
                    article.headline,
                    article.metadataLine
                )
            )
            .accessibilityHint(AppLocalization.text("accessibility.news.featuredCardHint", fallback: "Opens article details."))

            Divider()
                .overlay(AppTheme.borderSubtle)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ForEach(article.actions.indices, id: \.self) { index in
                        let action = article.actions[index]
                        ArticleActionView(
                            action: action,
                            isActive: action.kind == .like && article.uiState.isLiked,
                            isLoading: action.kind == .like
                                ? article.uiState.pendingOperation == .liking
                                : article.uiState.pendingOperation == .addingComment,
                            isDisabled: article.uiState.blocksActions
                                && !(
                                    (action.kind == .like && article.uiState.pendingOperation == .liking)
                                    || (action.kind == .comments && article.uiState.pendingOperation == .addingComment)
                                ),
                            title: action.kind == .like
                                ? (
                                    article.uiState.isLiked
                                        ? AppLocalization.text("news.featured.action.liked", fallback: "Liked")
                                        : action.title
                                )
                                : "\(article.commentCount) " + AppLocalization.text("news.featured.action.comments", fallback: "Comments"),
                            onTap: {
                                switch action.kind {
                                case .like:
                                    onAction(.toggleLike)
                                case .comments:
                                    onAction(.addComment)
                                }
                            }
                        )

                        if index < article.actions.count - 1 {
                            Spacer()
                        }
                    }

                    Spacer()

                    Menu {
                        Button {
                            onAction(.setDisplayMode(.expanded))
                        } label: {
                            Label(
                                AppLocalization.text(
                                    "news.featured.menu.expanded",
                                    fallback: "Expanded layout"
                                ),
                                systemImage: article.uiState.displayMode == .expanded ? "checkmark.circle.fill" : "text.alignleft"
                            )
                        }

                        Button {
                            onAction(.setDisplayMode(.compact))
                        } label: {
                            Label(
                                AppLocalization.text(
                                    "news.featured.menu.compact",
                                    fallback: "Compact layout"
                                ),
                                systemImage: article.uiState.displayMode == .compact ? "checkmark.circle.fill" : "rectangle.compress.vertical"
                            )
                        }

                        Divider()

                        Button {
                            onAction(.refreshContent)
                        } label: {
                            Label(
                                AppLocalization.text(
                                    "news.featured.menu.refresh",
                                    fallback: "Refresh card"
                                ),
                                systemImage: "arrow.clockwise"
                            )
                        }

                        Button {
                            onAction(.runLongTask)
                        } label: {
                            Label(
                                AppLocalization.text(
                                    "news.featured.menu.update",
                                    fallback: "Run update task"
                                ),
                                systemImage: "wand.and.stars"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.iconSecondary)
                    }
                    .disabled(article.uiState.blocksActions)
                    .accessibilityLabel(AppLocalization.text("accessibility.news.articleOptions", fallback: "Article options"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: AppTheme.shadow.opacity(0.35), radius: 6, y: 1)
    }
}

#if DEBUG
#Preview("Featured Article Card") {
    FeaturedArticleCard(
        article: ViewPreviewSupport.sampleFeaturedArticle,
        onTap: {},
        onAction: { _ in }
    )
    .padding()
    .background(AppTheme.canvasBackground)
}
#endif
