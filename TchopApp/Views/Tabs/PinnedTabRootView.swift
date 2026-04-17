import SwiftUI
import TchopDatabase

struct PinnedTabRootView: View {
    @ObservedObject var router: TabRouter<PinnedRoute>

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
        Binding(
            get: { router.path },
            set: { router.replacePath(with: $0) }
        )
    }

    private func openQuickAction(_ action: FeatureQuickAction) {
        router.push(
            PinnedRoute(
                title: action.title,
                description: "\(action.caption). This pinned collection keeps durable references visible beyond the transient feed."
            )
        )
    }

    private func openItem(_ item: FeatureTabItem) {
        router.push(
            PinnedRoute(
                title: item.title,
                description: "\(item.summary)\n\n\(item.metadata)"
            )
        )
    }
}
