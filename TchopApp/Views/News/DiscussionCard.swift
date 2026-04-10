import SwiftUI

struct DiscussionCard: View {
    let discussion: DiscussionCardModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                Text(discussion.categoryTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.9))

                Text(discussion.headline)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineSpacing(2)

                HStack(spacing: 6) {
                    ForEach(discussion.participants) { participant in
                        Circle()
                            .fill(
                                participant.isHighlighted
                                    ? Color(red: 0.94, green: 0.61, blue: 0.46)
                                    : Color.white.opacity(0.85)
                            )
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(participant.initials)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(
                                        participant.isHighlighted
                                            ? .white
                                            : Color(red: 0.28, green: 0.29, blue: 0.40)
                                    )
                            )
                    }

                    Text(discussion.joinedText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.82))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(red: 0.28, green: 0.27, blue: 0.39))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 1)
        }
        .buttonStyle(.plain)
    }
}
