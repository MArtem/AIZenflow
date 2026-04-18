import SwiftUI

/// Card rendering a highlighted discussion preview in the news feed.
struct DiscussionCard: View {
    let discussion: DiscussionCardModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                Text(discussion.categoryTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.discussionTextPrimary.opacity(0.9))

                Text(discussion.headline)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.discussionTextPrimary)
                    .lineSpacing(2)

                HStack(spacing: 6) {
                    ForEach(discussion.participants) { participant in
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
            .background(AppTheme.discussionCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: AppTheme.shadow.opacity(0.5), radius: 6, y: 1)
        }
        .buttonStyle(.plain)
    }
}
