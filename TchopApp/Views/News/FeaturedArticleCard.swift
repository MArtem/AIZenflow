import SwiftUI

/// Primary hero card for the featured article at the top of the feed.
struct PhotoCardView: View {
    let article: PhotoCardModel
    let onTap: () -> Void
    let onAction: (PhotoCardAction) -> Void

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
                                .font(AppTypography.microLabel)
                                .foregroundStyle(AppTheme.iconSecondary)
                        }
                        .accessibilityHidden(true)
                    }
                    .font(AppTypography.captionSemibold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)

                    ZStack(alignment: .bottomTrailing) {
                        LinearGradient(
                            colors: [
                                PhotoCardArtworkPalette.heroGradientStart,
                                PhotoCardArtworkPalette.heroGradientEnd
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: article.uiState.displayMode == .expanded ? 208 : 156)

                        Image(systemName: "pawprint.fill")
                            .font(AppTypography.featuredHeroSymbol(isExpanded: article.uiState.displayMode == .expanded))
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
                                    .fill(PhotoCardArtworkPalette.illustrationOuterFill)
                                    .frame(width: 76, height: 76)

                                Circle()
                                    .fill(PhotoCardArtworkPalette.illustrationMiddleFill)
                                    .frame(width: 52, height: 52)

                                Circle()
                                    .fill(PhotoCardArtworkPalette.illustrationInnerFill)
                                    .frame(width: 16, height: 16)
                                    .offset(y: 12)
                            }
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                            .accessibilityHidden(true)
                        }
                        .padding(.bottom, 18)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.badge))
                    .padding(.horizontal, 14)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(article.brandTitle)
                            .font(AppTypography.labelSemibold)
                            .foregroundStyle(PhotoCardArtworkPalette.brandAccent)

                        Text(article.headline)
                            .font(AppTypography.featuredHeadline(isExpanded: article.uiState.displayMode == .expanded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        if article.uiState.displayMode == .expanded {
                            Text(article.summary)
                                .font(AppTypography.channelSubtitle)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineSpacing(2)
                        }

                        Text(article.metadataLine)
                            .font(AppTypography.label)
                            .foregroundStyle(AppTheme.textTertiary)

                        if article.uiState.displayMode == .expanded {
                            Text(article.translationLabel)
                                .font(AppTypography.captionSemibold)
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
                    article.sourceTitle,
                    article.headline,
                    article.metadataLine
                )
            )
            .accessibilityHint(AppLocalization.text("accessibility.news.featuredCardHint"))

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
                                        ? AppLocalization.text("news.featured.action.liked")
                                        : action.title
                                )
                                : "\(article.commentCount) " + AppLocalization.text("news.featured.action.comments"),
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
                                AppLocalization.text("news.featured.menu.expanded"),
                                systemImage: article.uiState.displayMode == .expanded ? "checkmark.circle.fill" : "text.alignleft"
                            )
                        }

                        Button {
                            onAction(.setDisplayMode(.compact))
                        } label: {
                            Label(
                                AppLocalization.text("news.featured.menu.compact"),
                                systemImage: article.uiState.displayMode == .compact ? "checkmark.circle.fill" : "rectangle.compress.vertical"
                            )
                        }

                        Divider()

                        Button {
                            onAction(.refreshContent)
                        } label: {
                            Label(
                                AppLocalization.text("news.featured.menu.refresh"),
                                systemImage: "arrow.clockwise"
                            )
                        }

                        Button {
                            onAction(.runLongTask)
                        } label: {
                            Label(
                                AppLocalization.text("news.featured.menu.update"),
                                systemImage: "wand.and.stars"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppTheme.iconSecondary)
                    }
                    .disabled(article.uiState.blocksActions)
                    .accessibilityLabel(AppLocalization.text("accessibility.news.articleOptions"))
                    .accessibilityHint(AppLocalization.text("accessibility.news.optionsHint"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.compactCard))
        .shadow(color: AppTheme.shadow.opacity(0.35), radius: 6, y: 1)
    }
}

private enum PhotoCardArtworkPalette {
    static let heroGradientStart = Color(red: 0.67, green: 0.77, blue: 0.55)
    static let heroGradientEnd = Color(red: 0.48, green: 0.63, blue: 0.34)
    static let illustrationOuterFill = Color(red: 0.43, green: 0.31, blue: 0.19)
    static let illustrationMiddleFill = Color(red: 0.25, green: 0.22, blue: 0.21)
    static let illustrationInnerFill = Color(red: 0.94, green: 0.89, blue: 0.81)
    static let brandAccent = Color(red: 0.36, green: 0.53, blue: 0.86)
}

#if DEBUG
#Preview("Featured Article Card") {
    PhotoCardView(
        article: ViewPreviewSupport.sampleFeaturedArticle,
        onTap: {},
        onAction: { _ in }
    )
    .padding()
    .background(AppTheme.canvasBackground)
}
#endif
