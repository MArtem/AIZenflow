import SwiftUI

/// Application entry point that wires DI container and root app state.
@main
struct TchopApp: App {
    private let container: AppDIContainer
    @StateObject private var appState: AppState

    init() {
        let container = AppDIContainer()
        self.container = container

        _appState = StateObject(
            wrappedValue: container.makeAppState()
        )
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                appState: appState,
                onOpenURL: { url in
                    _ = appState.handleIncomingURL(url)
                },
                onContinueUserActivity: { userActivity in
                    _ = appState.handleIncomingUserActivity(userActivity)
                }
            )
                .environment(\.diContainer, container)
        }
    }
}
