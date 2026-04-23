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
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.discussionTextPrimary.opacity(0.9))

                    Text(discussion.headline)
                        .font(.system(size: discussion.uiState.displayMode == .expanded ? 16 : 15, weight: .bold))
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
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(
                                            participant.isHighlighted
                                                ? AppTheme.discussionTextPrimary
                                                : AppTheme.discussionParticipantText
                                        )
                                )
                        }

                        Text(discussion.joinedText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.discussionTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .buttonStyle(.plain)

            Divider()
                .overlay(AppTheme.borderSubtle.opacity(0.25))

            HStack {
                Button {
                    onAction(.toggleParticipation)
                } label: {
                    actionLabel(
                        title: discussion.uiState.isParticipating
                            ? AppLocalization.text("news.discussion.action.joined", fallback: "Joined")
                            : AppLocalization.text("news.discussion.action.join", fallback: "Join"),
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
                        title: "\(discussion.replyCount) " + AppLocalization.text("news.discussion.action.replies", fallback: "Replies"),
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
                            AppLocalization.text("news.discussion.menu.expanded", fallback: "Expanded layout"),
                            systemImage: discussion.uiState.displayMode == .expanded ? "checkmark.circle.fill" : "text.alignleft"
                        )
                    }

                    Button {
                        onAction(.setDisplayMode(.compact))
                    } label: {
                        Label(
                            AppLocalization.text("news.discussion.menu.compact", fallback: "Compact layout"),
                            systemImage: discussion.uiState.displayMode == .compact ? "checkmark.circle.fill" : "rectangle.compress.vertical"
                        )
                    }

                    Divider()

                    Button {
                        onAction(.refreshContent)
                    } label: {
                        Label(
                            AppLocalization.text("news.discussion.menu.refresh", fallback: "Refresh discussion"),
                            systemImage: "arrow.clockwise"
                        )
                    }

                    Button {
                        onAction(.runLongTask)
                    } label: {
                        Label(
                            AppLocalization.text("news.discussion.menu.update", fallback: "Run update task"),
                            systemImage: "wand.and.stars"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.discussionTextSecondary)
                }
                .disabled(discussion.uiState.blocksActions)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.discussionCardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    .font(.system(size: 14, weight: .semibold))
            }

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(isActive ? AppTheme.accent : AppTheme.discussionTextSecondary)
    }
}
