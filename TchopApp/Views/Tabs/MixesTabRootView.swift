import Observation
import SwiftUI

/// Root mixes-tab screen bound to its dedicated navigation router.
struct MixesTabRootView: View {
    @Bindable var router: TabRouter<MixesRoute>

    var body: some View {
        FeatureTabNavigationRootView(
            content: FeatureTabFixtures.mixes,
            router: router,
            makeQuickActionRoute: makeQuickActionRoute,
            makeItemRoute: makeItemRoute,
            destinationBuilder: destinationView
        )
    }

    private func makeQuickActionRoute(_ action: FeatureQuickAction) -> MixesRoute {
        MixesRoute(
            title: action.title,
            description: AppLocalization.text(
                "mixes.route.quickAction.descriptionFormat",
                action.caption
            )
        )
    }

    private func makeItemRoute(_ item: FeatureTabItem) -> MixesRoute {
        MixesRoute(
            title: item.title,
            description: AppLocalization.text(
                "route.item.descriptionFormat",
                item.summary,
                item.metadata
            )
        )
    }

    private func destinationView(_ route: MixesRoute) -> FeatureTabDetailView {
        FeatureTabDetailView(
            title: route.title,
            description: route.description
        )
    }
}

#if DEBUG
#Preview("Mixes Tab Root") {
    MixesTabRootView(
        router: TabRouter<MixesRoute>()
    )
}
#endif
