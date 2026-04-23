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
                onFeaturedArticleAction: handleFeaturedArticleAction,
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
        router.push(article.detailRoute)
    }

    /// Handles card-level intents that either mutate local card state or open navigation.
    private func handleFeaturedArticleAction(
        _ article: FeaturedArticleCardModel,
        _ action: FeaturedArticleCardAction
    ) {
        switch action {
        case .openComments:
            router.push(article.detailRoute)
        default:
            viewModel.handleFeaturedArticleAction(articleID: article.id, action: action)
        }
    }

    /// Opens discussion.
    private func openDiscussion(_ discussion: DiscussionCardModel) {
        router.push(discussion.detailRoute)
    }
}
