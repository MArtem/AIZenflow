import Observation
import SwiftUI
import TchopNavigation

/// Root mixes-tab screen bound to its dedicated navigation router.
struct MixesTabRootView: View {
    @Bindable var router: TabRouter<MixesRoute>

    var body: some View {
        NavigationStack(path: pathBinding) {
            FeatureTabScaffoldView(
                content: FeatureTabFixtures.mixes,
                onQuickActionTap: openQuickAction,
                onItemTap: openItem
            )
            .navigationDestination(for: MixesRoute.self) { route in
                StubTabDetailView(
                    title: route.title,
                    description: route.description
                )
            }
        }
    }

    private var pathBinding: Binding<[MixesRoute]> {
        $router.path
    }

    /// Opens quick action.
    private func openQuickAction(_ action: FeatureQuickAction) {
        router.push(
            MixesRoute(
                title: action.title,
                description: AppLocalization.text(
                    "mixes.route.quickAction.descriptionFormat",
                    action.caption
                )
            )
        )
    }

    /// Opens item.
    private func openItem(_ item: FeatureTabItem) {
        router.push(
            MixesRoute(
                title: item.title,
                description: AppLocalization.text(
                    "route.item.descriptionFormat",
                    item.summary,
                    item.metadata
                )
            )
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
