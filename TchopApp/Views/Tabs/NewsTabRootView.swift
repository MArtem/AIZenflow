import Observation
import SwiftUI
import TchopNavigation

/// Root news-tab container that binds feed and destination navigation.
struct NewsTabRootView: View {
    let viewModel: NewsFeedViewModel
    @Bindable var router: TabRouter<NewsRoute>
    /// Forwards list scroll proximity to the shell so it can gate the floating action button.
    let onFeedScrollProximityChange: (Bool) -> Void

    var body: some View {
        NavigationStack(path: pathBinding) {
            NewsFeedView(
                viewModel: viewModel,
                onScrollProximityChange: onFeedScrollProximityChange,
                onFeaturedArticleTap: openFeaturedArticle,
                onFeaturedArticleAction: handleFeaturedArticleAction,
                onDiscussionTap: openDiscussion,
                onDiscussionAction: handleDiscussionAction
            )
            .navigationDestination(for: NewsRoute.self) { route in
                NewsDestinationView(route: route)
            }
        }
    }

    private var pathBinding: Binding<[NewsRoute]> {
        $router.path
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
        viewModel.handleFeaturedArticleAction(articleID: article.id, action: action)
    }

    /// Handles discussion card intents and keeps the detail route on the main card tap only.
    private func handleDiscussionAction(
        _ discussion: DiscussionCardModel,
        _ action: DiscussionCardAction
    ) {
        viewModel.handleDiscussionAction(discussionID: discussion.id, action: action)
    }

    /// Opens discussion.
    private func openDiscussion(_ discussion: DiscussionCardModel) {
        router.push(discussion.detailRoute)
    }
}

#if DEBUG
#Preview("News Tab Root") {
    NewsTabRootView(
        viewModel: ViewPreviewSupport.makeNewsFeedViewModel(),
        router: TabRouter<NewsRoute>(),
        onFeedScrollProximityChange: { _ in }
    )
}
#endif
