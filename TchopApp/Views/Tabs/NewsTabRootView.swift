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
                onPhotoTap: openPhotoCard,
                onPhotoAction: handlePhotoAction,
                onTextTap: openTextCard,
                onLocalCardTap: openLocalCard,
                onTextAction: handleTextAction
            )
            .navigationDestination(for: NewsRoute.self) { route in
                NewsDestinationView(route: viewModel.translatedRoute(for: route))
            }
        }
    }

    private var pathBinding: Binding<[NewsRoute]> {
        $router.path
    }

    /// Opens featured article.
    private func openPhotoCard(_ article: PhotoCardModel) {
        router.push(article.detailRoute)
    }

    /// Handles card-level intents that either mutate local card state or open navigation.
    private func handlePhotoAction(
        _ article: PhotoCardModel,
        _ action: PhotoCardAction
    ) {
        viewModel.handlePhotoAction(articleID: article.id, action: action)
    }

    /// Handles discussion card intents and keeps the detail route on the main card tap only.
    private func handleTextAction(
        _ discussion: TextCardModel,
        _ action: TextCardAction
    ) {
        viewModel.handleTextAction(discussionID: discussion.id, action: action)
    }

    /// Opens discussion.
    private func openTextCard(_ discussion: TextCardModel) {
        router.push(discussion.detailRoute)
    }

    private func openLocalCard(_ route: NewsRoute) {
        router.push(route)
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
