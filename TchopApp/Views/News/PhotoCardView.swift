import SwiftUI

/// Primary photo card at the top of the feed.
struct PhotoCardView: View {
    let photo: PhotoCardModel
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onAction: (PhotoCardAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 0) {
                    PhotoCardSourceHeader(
                        postedInPrefix: photo.postedInPrefix,
                        sourceTitle: photo.sourceTitle
                    )

                    PhotoCardHeroView(photo: photo)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.badge))
                    .padding(.horizontal, 14)

                    PhotoCardBodyView(photo: photo)
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
                    "accessibility.news.photoCard",
                    photo.sourceTitle,
                    photo.headline,
                    photo.metadataLine
                )
            )
            .accessibilityHint(AppLocalization.text("accessibility.news.photoCardHint"))

            if let translationAction {
                FeedCardTranslationButton(action: translationAction)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
            }

            Divider()
                .overlay(AppTheme.borderSubtle)

            PhotoCardActionBar(photo: photo, onAction: onAction)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.compactCard))
        .shadow(color: AppTheme.shadow.opacity(0.35), radius: 6, y: 1)
    }

}

private struct PhotoCardSourceHeader: View {
    let postedInPrefix: String
    let sourceTitle: String

    var body: some View {
        HStack(spacing: 0) {
            Text(postedInPrefix)
                .foregroundStyle(AppTheme.textTertiary)

            Text(sourceTitle)
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
    }
}

private struct PhotoCardHeroView: View {
    let photo: PhotoCardModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [
                    PhotoCardArtworkPalette.heroGradientStart,
                    PhotoCardArtworkPalette.heroGradientEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: photo.uiState.displayMode == .expanded ? 208 : 156)

            Image(systemName: "pawprint.fill")
                .font(AppTypography.photoHeroSymbol(isExpanded: photo.uiState.displayMode == .expanded))
                .foregroundStyle(.white.opacity(0.18))
                .padding(18)
                .accessibilityHidden(true)
        }
        .overlay {
            VStack(spacing: 8) {
                PhotoCardStatusView(photo: photo)

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
    }
}

private struct PhotoCardStatusView: View {
    let photo: PhotoCardModel

    var body: some View {
        if let pendingOperation = photo.uiState.pendingOperation {
            FeedCardStatusBadge(
                title: pendingOperation.statusText,
                showsProgress: true
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 14)
            .padding(.horizontal, 14)
        } else if let inlineStatusMessage = photo.uiState.inlineStatusMessage {
            FeedCardStatusBadge(
                title: inlineStatusMessage,
                showsProgress: false
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 14)
            .padding(.horizontal, 14)
        }
    }
}

private struct PhotoCardBodyView: View {
    let photo: PhotoCardModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(photo.brandTitle)
                .font(AppTypography.labelSemibold)
                .foregroundStyle(PhotoCardArtworkPalette.brandAccent)

            Text(photo.headline)
                .font(AppTypography.photoHeadline(isExpanded: photo.uiState.displayMode == .expanded))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if photo.uiState.displayMode == .expanded {
                Text(photo.summary)
                    .font(AppTypography.channelSubtitle)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(2)
            }

            Text(photo.metadataLine)
                .font(AppTypography.label)
                .foregroundStyle(AppTheme.textTertiary)

            if photo.uiState.displayMode == .expanded {
                Text(photo.translationLabel)
                    .font(AppTypography.captionSemibold)
                    .foregroundStyle(AppTheme.accent)
            }
        }
    }
}

private struct PhotoCardActionBar: View {
    let photo: PhotoCardModel
    let onAction: (PhotoCardAction) -> Void

    private var indexedActions: [(index: Int, action: PhotoActionItem)] {
        Array(photo.actions.enumerated()).map { (index: $0.offset, action: $0.element) }
    }

    var body: some View {
        HStack {
            ForEach(indexedActions, id: \.index) { entry in
                let action = entry.action
                PhotoActionView(
                    action: action,
                    isActive: action.kind == .like && photo.uiState.isLiked,
                    isLoading: action.kind == .like
                        ? photo.uiState.pendingOperation == .liking
                        : photo.uiState.pendingOperation == .addingComment,
                    isDisabled: photo.uiState.blocksActions
                        && !(
                            (action.kind == .like && photo.uiState.pendingOperation == .liking)
                            || (action.kind == .comments && photo.uiState.pendingOperation == .addingComment)
                        ),
                    title: actionTitle(for: action),
                    onTap: { handleActionTap(action.kind) }
                )

                if entry.index < photo.actions.count - 1 {
                    Spacer()
                }
            }

            Spacer()

            Menu {
                Button {
                    onAction(.setDisplayMode(.expanded))
                } label: {
                    Label(
                        AppLocalization.text("news.photo.menu.expanded"),
                        systemImage: photo.uiState.displayMode == .expanded ? "checkmark.circle.fill" : "text.alignleft"
                    )
                }

                Button {
                    onAction(.setDisplayMode(.compact))
                } label: {
                    Label(
                        AppLocalization.text("news.photo.menu.compact"),
                        systemImage: photo.uiState.displayMode == .compact ? "checkmark.circle.fill" : "rectangle.compress.vertical"
                    )
                }

                Divider()

                Button {
                    onAction(.refreshContent)
                } label: {
                    Label(
                        AppLocalization.text("news.photo.menu.refresh"),
                        systemImage: "arrow.clockwise"
                    )
                }

                Button {
                    onAction(.runLongTask)
                } label: {
                    Label(
                        AppLocalization.text("news.photo.menu.update"),
                        systemImage: "wand.and.stars"
                    )
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppTheme.iconSecondary)
            }
            .disabled(photo.uiState.blocksActions)
            .accessibilityLabel(AppLocalization.text("accessibility.news.photoOptions"))
            .accessibilityHint(AppLocalization.text("accessibility.news.optionsHint"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func actionTitle(for action: PhotoActionItem) -> String {
        if action.kind == .like {
            return photo.uiState.isLiked
                ? AppLocalization.text("news.photo.action.liked")
                : action.title
        }

        return "\(photo.commentCount) " + AppLocalization.text("news.photo.action.comments")
    }

    private func handleActionTap(_ kind: PhotoActionKind) {
        switch kind {
        case .like:
            onAction(.toggleLike)
        case .comments:
            onAction(.addComment)
        }
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
#Preview("Photo Card") {
    PhotoCardView(
        photo: ViewPreviewSupport.samplePhotoCard,
        translationAction: nil,
        onTap: {},
        onAction: { _ in }
    )
    .padding()
    .background(AppTheme.canvasBackground)
}
#endif
