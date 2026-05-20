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
                onLocalCardTap: openLocalCard
            )
            .navigationDestination(for: NewsRoute.self) { route in
                NewsDestinationView(route: viewModel.translatedRoute(for: route))
            }
        }
    }

    private var pathBinding: Binding<[NewsRoute]> {
        $router.path
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
