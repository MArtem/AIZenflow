import SwiftUI
import TchopDatabase

struct ChatTabRootView: View {
    @ObservedObject var router: TabRouter<ChatRoute>

    var body: some View {
        NavigationStack(path: pathBinding) {
            FeatureTabScaffoldView(
                content: FeatureTabFixtures.chat,
                onQuickActionTap: openQuickAction,
                onItemTap: openItem
            )
            .navigationDestination(for: ChatRoute.self) { route in
                StubTabDetailView(
                    title: route.title,
                    description: route.description
                )
            }
        }
    }

    private var pathBinding: Binding<[ChatRoute]> {
        Binding(
            get: { router.path },
            set: { router.replacePath(with: $0) }
        )
    }

    private func openQuickAction(_ action: FeatureQuickAction) {
        router.push(
            ChatRoute(
                title: action.title,
                description: "\(action.caption). This room is modeled as a fast-response collaboration surface around feed activity and team coordination."
            )
        )
    }

    private func openItem(_ item: FeatureTabItem) {
        router.push(
            ChatRoute(
                title: item.title,
                description: "\(item.summary)\n\n\(item.metadata)"
            )
        )
    }
}
