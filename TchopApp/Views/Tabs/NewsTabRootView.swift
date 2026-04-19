import SwiftUI
import TchopNavigation

/// Root news-tab container that binds feed and destination navigation.
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

    /// Opens featured article.
    private func openFeaturedArticle(_ article: FeaturedArticleCardModel) {
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

    /// Opens discussion.
    private func openDiscussion(_ discussion: DiscussionCardModel) {
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

}
