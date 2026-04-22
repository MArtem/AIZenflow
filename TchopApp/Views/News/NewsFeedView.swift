import SwiftUI

/// Main feed list rendering heterogeneous card content.
struct NewsFeedView: View {
    @ObservedObject var viewModel: NewsFeedViewModel
    let onFeaturedArticleTap: (FeaturedArticleCardModel) -> Void
    let onDiscussionTap: (DiscussionCardModel) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                if let cachedStatusText {
                    Text(cachedStatusText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.orange.opacity(0.92))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("news.feed.cached-status")
                }

                if case let .failed(_, errorMessage) = viewModel.state {
                    HStack(alignment: .top, spacing: 12) {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.red.opacity(0.82))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button("Retry") {
                            viewModel.retry()
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .buttonStyle(.plain)
                        .foregroundStyle(.primary)
                        .accessibilityIdentifier("news.feed.retry")
                    }
                }

                ForEach(viewModel.state.content.cards) { card in
                    switch card {
                    case let .featuredArticle(article):
                        FeaturedArticleCard(
                            article: article,
                            onTap: { onFeaturedArticleTap(article) }
                        )
                    case let .discussion(discussion):
                        DiscussionCard(
                            discussion: discussion,
                            onTap: { onDiscussionTap(discussion) }
                        )
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .accessibilityIdentifier("news.feed")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .refreshable {
            viewModel.refresh()
        }
    }

    private var cachedStatusText: String? {
        guard case let .cached(lastSyncedAt, reason) = viewModel.state.content.availability else {
            return nil
        }

        let baseText: String
        switch reason {
        case .bootstrap:
            baseText = AppLocalization.text(
                "news.feed.cached.bootstrap",
                fallback: "Showing saved feed."
            )
        case .offline:
            baseText = AppLocalization.text(
                "news.feed.cached.offline",
                fallback: "Offline mode. Showing saved feed."
            )
        }

        guard let lastSyncedAt else {
            return baseText
        }

        let timestampPrefix = AppLocalization.text(
            "news.feed.cached.updatedAt",
            fallback: "Last updated"
        )
        return "\(baseText) \(timestampPrefix): \(Self.cachedStatusDateFormatter.string(from: lastSyncedAt))"
    }

    private static let cachedStatusDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
