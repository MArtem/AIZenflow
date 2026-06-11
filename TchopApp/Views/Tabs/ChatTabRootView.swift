import Observation
import SwiftUI

/// Root chat-tab screen bound to its dedicated navigation router.
struct ChatTabRootView: View {
    @Bindable var router: TabRouter<ChatRoute>

    var body: some View {
        FeatureTabNavigationRootView(
            content: FeatureTabFixtures.chat,
            router: router,
            makeQuickActionRoute: makeQuickActionRoute,
            makeItemRoute: makeItemRoute,
            destinationBuilder: destinationView
        )
    }

    private func makeQuickActionRoute(_ action: FeatureQuickAction) -> ChatRoute {
        ChatRoute(
            title: action.title,
            description: AppLocalization.text(
                "chat.route.quickAction.descriptionFormat",
                action.caption
            )
        )
    }

    private func makeItemRoute(_ item: FeatureTabItem) -> ChatRoute {
        ChatRoute(
            title: item.title,
            description: AppLocalization.text(
                "route.item.descriptionFormat",
                item.summary,
                item.metadata
            )
        )
    }

    private func destinationView(_ route: ChatRoute) -> FeatureTabDetailView {
        FeatureTabDetailView(
            title: route.title,
            description: route.description
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
