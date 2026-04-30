import SwiftUI

/// Card rendering a highlighted discussion preview in the news feed.
struct DiscussionCard: View {
    let discussion: DiscussionCardModel
    let onTap: () -> Void
    let onAction: (DiscussionCardAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 10) {
                    if let pendingOperation = discussion.uiState.pendingOperation {
                        FeedCardStatusBadge(
                            title: pendingOperation.statusText,
                            showsProgress: true
                        )
                    } else if let inlineStatusMessage = discussion.uiState.inlineStatusMessage {
                        FeedCardStatusBadge(
                            title: inlineStatusMessage,
                            showsProgress: false
                        )
                    }

                    Text(discussion.categoryTitle)
                        .font(AppTypography.captionSemibold)
                        .foregroundStyle(AppTheme.discussionTextPrimary.opacity(0.9))

                    Text(discussion.headline)
                        .font(AppTypography.discussionHeadline(isExpanded: discussion.uiState.displayMode == .expanded))
                        .foregroundStyle(AppTheme.discussionTextPrimary)
                        .lineSpacing(2)
                        .lineLimit(discussion.uiState.displayMode == .expanded ? nil : 2)

                    HStack(spacing: 6) {
                        ForEach(visibleParticipants) { participant in
                            Circle()
                                .fill(
                                    participant.isHighlighted
                                        ? AppTheme.accent
                                        : AppTheme.discussionParticipantFill
                                )
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text(participant.initials)
                                        .font(AppTypography.eyebrowStrong)
                                        .foregroundStyle(
                                            participant.isHighlighted
                                                ? AppTheme.discussionTextPrimary
                                                : AppTheme.discussionParticipantText
                                        )
                                )
                        }
                        .accessibilityHidden(true)

                        Text(discussion.joinedText)
                            .font(AppTypography.label)
                            .foregroundStyle(AppTheme.discussionTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                AppLocalization.text(
                    "accessibility.news.discussionCard",
                    discussion.categoryTitle,
                    discussion.headline,
                    String(discussion.replyCount),
                    discussion.joinedText
                )
            )
            .accessibilityHint(AppLocalization.text("accessibility.news.discussionCardHint"))

            Divider()
                .overlay(AppTheme.borderSubtle.opacity(0.25))

            HStack {
                Button {
                    onAction(.toggleParticipation)
                } label: {
                    actionLabel(
                        title: discussion.uiState.isParticipating
                            ? AppLocalization.text("news.discussion.action.joined")
                            : AppLocalization.text("news.discussion.action.join"),
                        systemName: "person.2.fill",
                        isActive: discussion.uiState.isParticipating,
                        isLoading: discussion.uiState.pendingOperation == .togglingParticipation
                    )
                }
                .buttonStyle(.plain)
                .disabled(discussion.uiState.blocksActions && discussion.uiState.pendingOperation != .togglingParticipation)

                Spacer()

                Button {
                    onAction(.addReply)
                } label: {
                    actionLabel(
                        title: "\(discussion.replyCount) " + AppLocalization.text("news.discussion.action.replies"),
                        systemName: "bubble.left.and.bubble.right.fill",
                        isActive: false,
                        isLoading: discussion.uiState.pendingOperation == .addingReply
                    )
                }
                .buttonStyle(.plain)
                .disabled(discussion.uiState.blocksActions && discussion.uiState.pendingOperation != .addingReply)

                Spacer()

                Menu {
                    Button {
                        onAction(.setDisplayMode(.expanded))
                    } label: {
                        Label(
                            AppLocalization.text("news.discussion.menu.expanded"),
                            systemImage: discussion.uiState.displayMode == .expanded ? "checkmark.circle.fill" : "text.alignleft"
                        )
                    }

                    Button {
                        onAction(.setDisplayMode(.compact))
                    } label: {
                        Label(
                            AppLocalization.text("news.discussion.menu.compact"),
                            systemImage: discussion.uiState.displayMode == .compact ? "checkmark.circle.fill" : "rectangle.compress.vertical"
                        )
                    }

                    Divider()

                    Button {
                        onAction(.refreshContent)
                    } label: {
                        Label(
                            AppLocalization.text("news.discussion.menu.refresh"),
                            systemImage: "arrow.clockwise"
                        )
                    }

                    Button {
                        onAction(.runLongTask)
                    } label: {
                        Label(
                            AppLocalization.text("news.discussion.menu.update"),
                            systemImage: "wand.and.stars"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppTheme.discussionTextSecondary)
                }
                .disabled(discussion.uiState.blocksActions)
                .accessibilityLabel(AppLocalization.text("accessibility.news.discussionOptions"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.discussionCardSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.compactCard))
        .shadow(color: AppTheme.shadow.opacity(0.5), radius: 6, y: 1)
    }

    private var visibleParticipants: [DiscussionParticipant] {
        if discussion.uiState.displayMode == .expanded {
            return discussion.participants
        }

        return Array(discussion.participants.prefix(2))
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
        .foregroundStyle(isActive ? AppTheme.accent : AppTheme.discussionTextSecondary)
    }
}

#if DEBUG
#Preview("Discussion Card") {
    DiscussionCard(
        discussion: ViewPreviewSupport.sampleDiscussion,
        onTap: {},
        onAction: { _ in }
    )
    .padding()
    .background(AppTheme.canvasBackground)
}
#endif
