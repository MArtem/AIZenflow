import Observation
import SwiftUI
import TchopNavigation

/// Root pinned-tab screen bound to its dedicated navigation router.
struct PinnedTabRootView: View {
    @Bindable var router: TabRouter<PinnedRoute>

    var body: some View {
        NavigationStack(path: pathBinding) {
            FeatureTabScaffoldView(
                content: FeatureTabFixtures.pinned,
                onQuickActionTap: openQuickAction,
                onItemTap: openItem
            )
            .navigationDestination(for: PinnedRoute.self) { route in
                StubTabDetailView(
                    title: route.title,
                    description: route.description
                )
            }
        }
    }

    private var pathBinding: Binding<[PinnedRoute]> {
        $router.path
    }

    /// Opens quick action.
    private func openQuickAction(_ action: FeatureQuickAction) {
        router.push(
            PinnedRoute(
                title: action.title,
                description: AppLocalization.text(
                    "pinned.route.quickAction.descriptionFormat",
                    action.caption
                )
            )
        )
    }

    /// Opens item.
    private func openItem(_ item: FeatureTabItem) {
        router.push(
            PinnedRoute(
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
#Preview("Pinned Tab Root") {
    PinnedTabRootView(
        router: TabRouter<PinnedRoute>()
    )
}
#endif
