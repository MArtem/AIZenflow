import SwiftUI
import UIKit

/// Application entry point that wires DI container and root app state.
@main
struct TchopApp: App {
    @UIApplicationDelegateAdaptor(TchopApplicationDelegate.self) private var applicationDelegate
    private let container: AppDIContainer
    @StateObject private var appState: AppState

    /// Creates a new TchopApp instance.
    init() {
        let launchConfiguration = AppLaunchConfiguration()
        let container = AppDIContainer(
            databaseConfiguration: launchConfiguration.databaseConfiguration
        )
        let appState = container.makeAppState()

        if launchConfiguration.launchesAuthenticatedSession {
            try? appState.signIn(username: launchConfiguration.uiTestUsername)
        }

        self.container = container

        _appState = StateObject(
            wrappedValue: appState
        )

        applicationDelegate.pushNotificationBridge = container.pushNotificationBridge
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
