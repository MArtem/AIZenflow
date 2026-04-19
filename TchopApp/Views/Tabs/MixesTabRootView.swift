import SwiftUI
import TchopNavigation

/// Root mixes-tab screen bound to its dedicated navigation router.
struct MixesTabRootView: View {
    @ObservedObject var router: TabRouter<MixesRoute>

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
        Binding(
            get: { router.path },
            set: { router.replacePath(with: $0) }
        )
    }

    private func openQuickAction(_ action: FeatureQuickAction) {
        router.push(
            MixesRoute(
                title: action.title,
                description: AppLocalization.text(
                    "mixes.route.quickAction.descriptionFormat",
                    fallback: "%@. This mix is positioned as a curated entry point that bundles related stories into one navigable stream.",
                    action.caption
                )
            )
        )
    }

    private func openItem(_ item: FeatureTabItem) {
        router.push(
            MixesRoute(
                title: item.title,
                description: AppLocalization.text(
                    "route.item.descriptionFormat",
                    fallback: "%@\n\n%@",
                    item.summary,
                    item.metadata
                )
            )
        )
    }
}
