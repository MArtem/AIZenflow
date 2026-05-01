import SwiftUI
import UIKit

/// Application entry point that wires DI container and root app state.
@main
struct TchopApp: App {
    @UIApplicationDelegateAdaptor(TchopApplicationDelegate.self) private var applicationDelegate
    private let container: AppDIContainer
    private let loginViewModel: LoginViewModel
    @State private var appState: AppState

    /// Creates a new TchopApp instance.
    init() {
        let launchConfiguration = AppLaunchConfiguration()
        let container = AppDIContainer(
            databaseConfiguration: launchConfiguration.databaseConfiguration,
            apiEnvironment: launchConfiguration.apiEnvironment,
            isUITesting: launchConfiguration.isUITesting
        )
        let appState = container.makeAppState()
        let loginViewModel = container.makeLoginViewModel(appState: appState)

        if launchConfiguration.launchesAuthenticatedSession {
            Task { @MainActor in
                try? await appState.signIn(username: launchConfiguration.uiTestUsername)
            }
        }

        if let initialURL = launchConfiguration.initialURL {
            _ = appState.handleIncomingURL(initialURL)
        }

        self.container = container
        self.loginViewModel = loginViewModel

        _appState = State(initialValue: appState)

        applicationDelegate.pushNotificationBridge = container.pushNotificationBridge
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                appState: appState,
                loginViewModel: loginViewModel,
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
