import SwiftUI
import UIKit

/// Application entry point that wires DI container and root app state.
@main
struct TchopApp: App {
    @UIApplicationDelegateAdaptor(TchopApplicationDelegate.self) private var applicationDelegate
    private let container: AppDIContainer
    @StateObject private var appState: AppState

    init() {
        let container = AppDIContainer()
        self.container = container
        applicationDelegate.pushNotificationBridge = container.pushNotificationBridge

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
