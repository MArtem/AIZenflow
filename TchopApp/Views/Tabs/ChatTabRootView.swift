import SwiftUI
import TchopNavigation

/// Root chat-tab screen bound to its dedicated navigation router.
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

    /// Opens quick action.
    private func openQuickAction(_ action: FeatureQuickAction) {
        router.push(
            ChatRoute(
                title: action.title,
                description: AppLocalization.text(
                    "chat.route.quickAction.descriptionFormat",
                    fallback: "%@. This room is modeled as a fast-response collaboration surface around feed activity and team coordination.",
                    action.caption
                )
            )
        )
    }

    /// Opens item.
    private func openItem(_ item: FeatureTabItem) {
        router.push(
            ChatRoute(
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

#if DEBUG
#Preview("Chat Tab Root") {
    ChatTabRootView(
        router: TabRouter<ChatRoute>()
    )
}
#endif
