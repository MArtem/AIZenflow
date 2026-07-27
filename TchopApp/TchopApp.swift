import SwiftUI
import UIKit

/// Application entry point that wires DI container and root app state.
@main
struct TchopApp: App {
    @UIApplicationDelegateAdaptor(TchopApplicationDelegate.self) private var applicationDelegate
    @Environment(\.scenePhase) private var scenePhase
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
                .onChange(of: scenePhase) { _, newPhase in
                    appState.handleLifecyclePhaseChange(
                        newPhase.appLifecyclePhase,
                        reason: newPhase.appLifecycleEventKind
                    )
                }
        }
    }
}

private extension ScenePhase {
    /// Maps SwiftUI scene phase values into the product-neutral lifecycle package contract.
    var appLifecyclePhase: AppLifecyclePhase {
        switch self {
        case .active:
            return .active
        case .inactive:
            return .inactive
        case .background:
            return .background
        @unknown default:
            return .unknown
        }
    }

    /// Preserves the system transition reason while keeping package code SwiftUI-independent.
    var appLifecycleEventKind: AppLifecycleEventKind {
        switch self {
        case .active:
            return .didBecomeActive
        case .inactive:
            return .willResignActive
        case .background:
            return .didEnterBackground
        @unknown default:
            return .custom
        }
    }
}
