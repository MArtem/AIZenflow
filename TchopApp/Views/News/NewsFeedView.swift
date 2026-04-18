import SwiftUI

/// Main feed list rendering heterogeneous card content.
struct NewsFeedView: View {
    @ObservedObject var viewModel: NewsFeedViewModel
    let onFeaturedArticleTap: () -> Void
    let onDiscussionTap: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.red.opacity(0.82))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                ForEach(viewModel.content.cards) { card in
                    switch card {
                    case let .featuredArticle(article):
                        FeaturedArticleCard(
                            article: article,
                            onTap: onFeaturedArticleTap
                        )
                    case let .discussion(discussion):
                        DiscussionCard(
                            discussion: discussion,
                            onTap: onDiscussionTap
                        )
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .refreshable {
            viewModel.reload()
        }
    }
}
