import Observation
import SwiftUI
import AppNavigation

/// Root pinned-tab screen bound to its dedicated navigation router.
struct PinnedTabRootView: View {
    @Bindable var router: TabRouter<PinnedRoute>

    var body: some View {
        FeatureTabNavigationRootView(
            content: FeatureTabFixtures.pinned,
            router: router,
            makeQuickActionRoute: makeQuickActionRoute,
            makeItemRoute: makeItemRoute,
            destinationBuilder: destinationView
        )
    }

    private func makeQuickActionRoute(_ action: FeatureQuickAction) -> PinnedRoute {
        PinnedRoute(
            title: action.title,
            description: AppLocalization.text(
                "pinned.route.quickAction.descriptionFormat",
                action.caption
            )
        )
    }

    private func makeItemRoute(_ item: FeatureTabItem) -> PinnedRoute {
        PinnedRoute(
            title: item.title,
            description: AppLocalization.text(
                "route.item.descriptionFormat",
                item.summary,
                item.metadata
            )
        )
    }

    private func destinationView(_ route: PinnedRoute) -> FeatureTabDetailView {
        FeatureTabDetailView(
            title: route.title,
            description: route.description
        )
    }
}

#if DEBUG
#Preview("Pinned Tab Root") {
    PinnedTabRootView(
        router: TabRouter<PinnedRoute>()
    )
}
#endif
