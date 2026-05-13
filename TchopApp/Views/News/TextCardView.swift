import SwiftUI

/// Card rendering a text preview in the news feed.
struct TextCardView: View {
    let text: TextCardModel
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onAction: (TextCardAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                TextCardContentView(text: text, visibleParticipants: visibleParticipants)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                AppLocalization.text(
                    "accessibility.news.textCard",
                    text.categoryTitle,
                    text.headline,
                    String(text.replyCount),
                    text.joinedText
                )
            )
            .accessibilityHint(AppLocalization.text("accessibility.news.textCardHint"))

            if let translationAction {
                FeedCardTranslationButton(action: translationAction)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
            }

            Divider()
                .overlay(AppTheme.borderSubtle.opacity(0.25))

            TextCardActionBar(text: text, onAction: onAction)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.textCardSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.compactCard))
        .shadow(color: AppTheme.shadow.opacity(0.5), radius: 6, y: 1)
    }

    private var visibleParticipants: [TextCardParticipant] {
        if text.uiState.displayMode == .expanded {
            return text.participants
        }

        return Array(text.participants.prefix(2))
    }
}

private struct TextCardContentView: View {
    let text: TextCardModel
    let visibleParticipants: [TextCardParticipant]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextCardStatusView(text: text)

            Text(text.categoryTitle)
                .font(AppTypography.captionSemibold)
                .foregroundStyle(AppTheme.textCardTextPrimary.opacity(0.9))

            Text(text.headline)
                .font(AppTypography.textHeadline(isExpanded: text.uiState.displayMode == .expanded))
                .foregroundStyle(AppTheme.textCardTextPrimary)
                .lineSpacing(2)
                .lineLimit(text.uiState.displayMode == .expanded ? nil : 2)

            TextCardParticipantsRow(
                participants: visibleParticipants,
                joinedText: text.joinedText
            )
        }
    }
}

private struct TextCardStatusView: View {
    let text: TextCardModel

    var body: some View {
        if let pendingOperation = text.uiState.pendingOperation {
            FeedCardStatusBadge(
                title: pendingOperation.statusText,
                showsProgress: true
            )
        } else if let inlineStatusMessage = text.uiState.inlineStatusMessage {
            FeedCardStatusBadge(
                title: inlineStatusMessage,
                showsProgress: false
            )
        }
    }
}

private struct TextCardParticipantsRow: View {
    let participants: [TextCardParticipant]
    let joinedText: String

    var body: some View {
        HStack(spacing: 6) {
            ForEach(participants) { participant in
                Circle()
                    .fill(
                        participant.isHighlighted
                            ? AppTheme.accent
                            : AppTheme.textCardParticipantFill
                    )
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(participant.initials)
                            .font(AppTypography.eyebrowStrong)
                            .foregroundStyle(
                                participant.isHighlighted
                                    ? AppTheme.textCardTextPrimary
                                    : AppTheme.textCardParticipantText
                            )
                    )
            }
            .accessibilityHidden(true)

            Text(joinedText)
                .font(AppTypography.label)
                .foregroundStyle(AppTheme.textCardTextSecondary)
        }
    }
}

private struct TextCardActionBar: View {
    let text: TextCardModel
    let onAction: (TextCardAction) -> Void

    var body: some View {
        HStack {
            participationButton

            Spacer()

            repliesButton

            Spacer()

            optionsMenu
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var participationButton: some View {
        Button {
            onAction(.toggleParticipation)
        } label: {
            actionLabel(
                title: text.uiState.isParticipating
                    ? AppLocalization.text("news.text.action.joined")
                    : AppLocalization.text("news.text.action.join"),
                systemName: "person.2.fill",
                isActive: text.uiState.isParticipating,
                isLoading: text.uiState.pendingOperation == .togglingParticipation
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            text.uiState.isParticipating
                ? AppLocalization.text("news.text.action.joined")
                : AppLocalization.text("news.text.action.join")
        )
        .accessibilityHint(AppLocalization.text("accessibility.news.cardActionHint"))
        .accessibilityValue(
            text.uiState.pendingOperation == .togglingParticipation
                ? AppLocalization.text("accessibility.news.cardActionLoading")
                : (
                    text.uiState.isParticipating
                        ? AppLocalization.text("accessibility.news.cardActionActive")
                        : ""
                )
        )
        .disabled(text.uiState.blocksActions && text.uiState.pendingOperation != .togglingParticipation)
    }

    private var repliesButton: some View {
        Button {
            onAction(.addReply)
        } label: {
            actionLabel(
                title: "\(text.replyCount) " + AppLocalization.text("news.text.action.replies"),
                systemName: "bubble.left.and.bubble.right.fill",
                isActive: false,
                isLoading: text.uiState.pendingOperation == .addingReply
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(text.replyCount) " + AppLocalization.text("news.text.action.replies"))
        .accessibilityHint(AppLocalization.text("accessibility.news.cardActionHint"))
        .accessibilityValue(
            text.uiState.pendingOperation == .addingReply
                ? AppLocalization.text("accessibility.news.cardActionLoading")
                : ""
        )
        .disabled(text.uiState.blocksActions && text.uiState.pendingOperation != .addingReply)
    }

    private var optionsMenu: some View {
        Menu {
            Button {
                onAction(.setDisplayMode(.expanded))
            } label: {
                Label(
                    AppLocalization.text("news.text.menu.expanded"),
                    systemImage: text.uiState.displayMode == .expanded ? "checkmark.circle.fill" : "text.alignleft"
                )
            }

            Button {
                onAction(.setDisplayMode(.compact))
            } label: {
                Label(
                    AppLocalization.text("news.text.menu.compact"),
                    systemImage: text.uiState.displayMode == .compact ? "checkmark.circle.fill" : "rectangle.compress.vertical"
                )
            }

            Divider()

            Button {
                onAction(.refreshContent)
            } label: {
                Label(
                    AppLocalization.text("news.text.menu.refresh"),
                    systemImage: "arrow.clockwise"
                )
            }

            Button {
                onAction(.runLongTask)
            } label: {
                Label(
                    AppLocalization.text("news.text.menu.update"),
                    systemImage: "wand.and.stars"
                )
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppTheme.textCardTextSecondary)
        }
        .disabled(text.uiState.blocksActions)
        .accessibilityLabel(AppLocalization.text("accessibility.news.textOptions"))
        .accessibilityHint(AppLocalization.text("accessibility.news.optionsHint"))
    }

    @ViewBuilder
    private func actionLabel(
        title: String,
        systemName: String,
        isActive: Bool,
        isLoading: Bool
    ) -> some View {
        HStack(spacing: 6) {
            if isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: systemName)
                    .font(AppTypography.detailSemibold)
            }

            Text(title)
                .font(AppTypography.captionSemibold)
                .lineLimit(1)
        }
        .foregroundStyle(isActive ? AppTheme.accent : AppTheme.textCardTextSecondary)
    }
}

#if DEBUG
#Preview("Text Card") {
    TextCardView(
        text: ViewPreviewSupport.sampleTextCard,
        translationAction: nil,
        onTap: {},
        onAction: { _ in }
    )
    .padding()
    .background(AppTheme.canvasBackground)
}
#endif
