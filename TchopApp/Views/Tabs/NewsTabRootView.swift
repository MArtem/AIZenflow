import SwiftUI
import TchopDatabase

struct NewsTabRootView: View {
    @ObservedObject var viewModel: NewsFeedViewModel
    @ObservedObject var router: TabRouter<NewsRoute>

    var body: some View {
        NavigationStack(path: pathBinding) {
            NewsFeedView(
                viewModel: viewModel,
                onFeaturedArticleTap: openFeaturedArticle,
                onDiscussionTap: openDiscussion
            )
            .navigationDestination(for: NewsRoute.self) { route in
                NewsDestinationView(route: route)
            }
        }
    }

    private var pathBinding: Binding<[NewsRoute]> {
        Binding(
            get: { router.path },
            set: { router.replacePath(with: $0) }
        )
    }

    private func openFeaturedArticle() {
        guard let article else {
            return
        }

        router.push(
            NewsRoute(
                destinationID: "article-details",
                title: article.headline.replacingOccurrences(of: "\n", with: " "),
                subtitle: article.sourceTitle,
                bodyText: article.summary,
                accentLabel: article.translationLabel
            )
        )
    }

    private func openDiscussion() {
        guard let discussion else {
            return
        }

        router.push(
            NewsRoute(
                destinationID: "discussion-details",
                title: discussion.categoryTitle,
                subtitle: discussion.joinedText,
                bodyText: discussion.headline.replacingOccurrences(of: "\n", with: " "),
                accentLabel: nil
            )
        )
    }

    private var article: FeaturedArticleCardModel? {
        for card in viewModel.content.cards {
            if case let .featuredArticle(article) = card {
                return article
            }
        }

        return nil
    }

    private var discussion: DiscussionCardModel? {
        for card in viewModel.content.cards {
            if case let .discussion(discussion) = card {
                return discussion
            }
        }

        return nil
    }
}
