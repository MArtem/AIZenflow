import Foundation
import SwiftUI

/// Runtime API environment describing transport configuration and diagnostics policy.
struct AppAPIEnvironment {
    enum Kind {
        case developmentStub
        case developmentExternalAuth
        case development
        case staging
        case production
    }

    let kind: Kind
    let apiConfiguration: APIConfiguration
    let authenticationAPIConfiguration: APIConfiguration
    let enablesNetworkLogging: Bool
    let loginScreenMode: LoginScreenMode
    let authenticationEndpointConfiguration: AuthenticationAPIEndpointConfiguration

    static let developmentStub = AppAPIEnvironment(
        kind: .developmentStub,
        apiConfiguration: .stub,
        authenticationAPIConfiguration: .stub,
        enablesNetworkLogging: false,
        loginScreenMode: .defaultAppAuth,
        authenticationEndpointConfiguration: .default
    )

    /// Development environment that keeps the app/feed runtime local but proxies login/register
    /// through ReqRes demo auth using an API key supplied from launch configuration.
    static func developmentExternalAuth(
        reqResAPIKey: String,
        enablesNetworkLogging: Bool = true
    ) -> AppAPIEnvironment {
        AppAPIEnvironment(
            kind: .developmentExternalAuth,
            apiConfiguration: .stub,
            authenticationAPIConfiguration: APIConfiguration(
                baseURL: URL(string: "https://reqres.in")!,
                defaultHeaders: makeAuthenticationHeaders(apiKey: reqResAPIKey),
                timeoutInterval: 30
            ),
            enablesNetworkLogging: enablesNetworkLogging,
            loginScreenMode: .reqResDemoExternalAuth,
            authenticationEndpointConfiguration: .reqResDemo
        )
    }

    static func remote(
        kind: Kind,
        baseURL: URL,
        enablesNetworkLogging: Bool,
        authenticationEndpointConfiguration: AuthenticationAPIEndpointConfiguration = .default
    ) -> AppAPIEnvironment {
        AppAPIEnvironment(
            kind: kind,
            apiConfiguration: APIConfiguration(
                baseURL: baseURL,
                defaultHeaders: makeDefaultHeaders(),
                timeoutInterval: 30
            ),
            authenticationAPIConfiguration: APIConfiguration(
                baseURL: baseURL,
                defaultHeaders: makeDefaultHeaders(),
                timeoutInterval: 30
            ),
            enablesNetworkLogging: enablesNetworkLogging,
            loginScreenMode: .defaultAppAuth,
            authenticationEndpointConfiguration: authenticationEndpointConfiguration
        )
    }

    private static func makeDefaultHeaders() -> [String: String] {
        var headers = [
            "Accept": "application/json",
            "X-Platform": "iOS",
            "Accept-Language": Locale.preferredLanguages.first ?? Locale.current.identifier
        ]

        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            headers["X-App-Version"] = bundleVersion
        }

        return headers
    }

    private static func makeAuthenticationHeaders(apiKey: String) -> [String: String] {
        var headers = makeDefaultHeaders()
        if !apiKey.isEmpty {
            headers["x-api-key"] = apiKey
        }
        return headers
    }
}

/// Composition root for the application.
///
/// The container owns app-wide infrastructure services and constructs feature-level
/// dependencies for the SwiftUI tree.
@MainActor
final class AppDIContainer {
    /// Shared in-memory analytics sink that app runtime integrations can reuse.
    private let analyticsCollector: ProductAnalyticsMemoryCollector

    /// Database backend adapter consumed by repositories and seeders.
    private let databaseManager: any DatabaseManaging

    /// Shared networking client used by feature-specific API managers.
    private let apiManager: any APIManaging

    /// Secure token storage used by auth-aware networking and session flows.
    private let authTokenStore: any AuthTokenStoring

    /// Auth API manager responsible for token refresh/session-auth calls.
    private let authenticationAPIManager: any AuthenticationAPIManaging

    /// Shared app error manager used by UI/session flows for normalization and reporting.
    let errorManager: any AppErrorManaging

    /// Login UI mode selected by the active auth environment.
    let loginScreenMode: LoginScreenMode


    /// Repository serving shell and feed content.
    private let contentRepository: any AppContentRepository

    /// Repository serving persisted users.
    private let userRepository: any UserRepository

    /// Service responsible for sign-in and session restoration.
    private let sessionService: any UserSessionManaging

    /// App-wide runtime snapshot of the authenticated session.
    let sessionStore: SessionStore

    /// App-wide runtime snapshot of available channels and current selection.
    let channelsStore: ChannelsStore

    /// App-wide runtime store for locally published feed-native cards.
    let feedCardStore: FeedCardStore

    /// App-group-backed bridge that syncs extension-published feed cards into app runtime.
    let sharedFeedCardSyncManager: SharedFeedCardSyncManager?

    /// App-group-backed bridge that exposes the current auth/channel snapshot to the share extension.
    let shareExtensionSessionContextManager: ShareExtensionSessionContextManager?

    /// User-scoped channel settings source resolved during session bootstrap.
    private let channelSettingsRepository: UserChannelSettingsRepository

    /// Apple auth adapter used by the login UI flow.
    let appleAuthenticationManager: any AppleAuthenticationManaging

    /// Remote UI configuration manager used for server-driven shell tweaks.
    private let uiConfigurationManager: any UIConfigurationManaging<ShellUIConfiguration>

    /// Manager that persists/restores per-user navigation snapshots.
    private let navigationStateManager: any NavigationStateManaging

    /// Manager that handles deep and universal links for app navigation.
    private let deepLinkManager: any DeepLinkManaging

    /// Reporter for navigation restore/deep-link diagnostics.
    private let navigationEventReporter: any NavigationEventReporting

    /// Bridge that syncs app content into shared widget storage.
    private let widgetContentSyncManager: any WidgetContentSyncing

    /// Bridge that adapts system APNs callbacks into package-backed push state handling.
    let pushNotificationBridge: any AppPushNotificationBridging

    /// Creates the root dependency container and eagerly wires the initial graph.
    init(
        databaseConfiguration: DatabaseConfiguration = .persistent,
        apiEnvironment: AppAPIEnvironment = .developmentStub,
        isUITesting: Bool = false
    ) {
        let analyticsCollector = ProductAnalyticsMemoryCollector()
        self.analyticsCollector = analyticsCollector

        let databaseManager = Self.makeSeededDatabaseManager(
            configuration: databaseConfiguration
        )
        self.databaseManager = databaseManager

        let contentServices = Self.makeContentServices(
            databaseManager: databaseManager,
            analyticsCollector: analyticsCollector,
            apiEnvironment: apiEnvironment,
            isUITesting: isUITesting
        )
        self.apiManager = contentServices.apiManager
        self.authTokenStore = contentServices.authTokenStore
        self.authenticationAPIManager = contentServices.authenticationAPIManager
        self.errorManager = contentServices.errorManager
        self.loginScreenMode = apiEnvironment.loginScreenMode
        self.contentRepository = contentServices.contentRepository
        self.userRepository = contentServices.userRepository
        self.sessionService = contentServices.sessionService
        self.sessionStore = SessionStore()
        self.channelsStore = ChannelsStore(
            selectionStore: UserDefaultsChannelSelectionStore()
        )
        self.feedCardStore = FeedCardStore(
            repository: FeedCardRepository(databaseManager: databaseManager)
        )
        self.sharedFeedCardSyncManager = Self.makeSharedFeedCardSyncManager(
            errorManager: errorManager
        )
        self.shareExtensionSessionContextManager = Self.makeShareExtensionSessionContextManager(
            errorManager: errorManager
        )
        self.channelSettingsRepository = UserChannelSettingsRepository()
        self.appleAuthenticationManager = AppleAuthenticationManager()

        self.uiConfigurationManager = Self.makeAppUIConfigurationManager(isUITesting: isUITesting)
        self.widgetContentSyncManager = Self.makeWidgetContentSyncManager(
            errorManager: errorManager
        )
        self.pushNotificationBridge = Self.makePushNotificationBridge(
            analyticsCollector: analyticsCollector,
            errorManager: errorManager
        )

        let navigationServices = Self.makeNavigationServices(
            analyticsCollector: analyticsCollector
        )
        self.navigationStateManager = navigationServices.navigationStateManager
        self.navigationEventReporter = navigationServices.navigationEventReporter
        self.deepLinkManager = navigationServices.deepLinkManager

        channelsStore.setAvailableChannels([.product, .community, .leadership])
    }

    /// Creates the shell view model used by the authenticated part of the app.
    func makeAppShellViewModel() -> AppShellViewModel {
        let newsFeedViewModel = Self.makeNewsFeedViewModel(
            channelsStore: channelsStore,
            widgetContentSyncManager: widgetContentSyncManager,
            errorManager: errorManager,
            feedCardStore: feedCardStore,
            sharedFeedCardSyncManager: sharedFeedCardSyncManager
        )

        return AppShellViewModel(
            channelsStore: channelsStore,
            feedCardStore: feedCardStore,
            newsFeedViewModel: newsFeedViewModel,
            errorManager: errorManager,
            uiConfigurationManager: uiConfigurationManager,
            shareExtensionSessionContextManager: shareExtensionSessionContextManager,
        )
    }

    /// Creates the root app state object used by the app entry point.
    func makeAppState() -> AppState {
        let coordinator = AppCoordinator()
        let appShellViewModel = makeAppShellViewModel()

        return AppState(
            coordinator: coordinator,
            appShellViewModel: appShellViewModel,
            sessionStore: sessionStore,
            channelsStore: channelsStore,
            sessionService: sessionService,
            userRepository: userRepository,
            channelSettingsRepository: channelSettingsRepository,
            navigationStateManager: navigationStateManager,
            deepLinkManager: deepLinkManager,
            navigationEventReporter: navigationEventReporter,
            widgetContentSyncManager: widgetContentSyncManager,
            pushNotificationBridge: pushNotificationBridge,
            errorManager: errorManager,
            shareExtensionSessionContextManager: shareExtensionSessionContextManager
        )
    }

    /// Creates the injected login view model so the login screen never owns view-model construction.
    func makeLoginViewModel(appState: AppState) -> LoginViewModel {
        LoginViewModel(
            mode: loginScreenMode,
            onCredentialLogin: appState.signIn(email:password:),
            onRegister: appState.register(email:password:),
            onAppleLogin: appState.signInWithApple(identity:),
            appleAuthenticationManager: appleAuthenticationManager,
            errorManager: errorManager
        )
    }

    /// Creates the shared database manager and performs local seeding before the graph is assembled.
    private static func makeSeededDatabaseManager(
        configuration: DatabaseConfiguration
    ) -> any DatabaseManaging {
        let databaseManager: any DatabaseManaging
        do {
            databaseManager = try AppDatabase.makeDatabaseManagerOrThrow(configuration: configuration)
        } catch {
            let bootstrapError = AppRuntimeErrorMapper().map(
                error,
                context: AppErrorContext(
                    operation: "makeSeededDatabaseManager",
                    feature: "bootstrap"
                )
            )
            fatalError("Database bootstrap failed: \(bootstrapError.debugDescription)")
        }

        seedAppDataIfNeeded(using: databaseManager)
        return databaseManager
    }

    /// Creates the content-facing stack from networking through repositories and session service.
    private static func makeContentServices(
        databaseManager: any DatabaseManaging,
        analyticsCollector: ProductAnalyticsMemoryCollector,
        apiEnvironment: AppAPIEnvironment,
        isUITesting: Bool
    ) -> (
        apiManager: any APIManaging,
        authTokenStore: any AuthTokenStoring,
        authenticationAPIManager: any AuthenticationAPIManaging,
        errorManager: any AppErrorManaging,
        contentRepository: any AppContentRepository,
        userRepository: any UserRepository,
        sessionService: any UserSessionManaging
    ) {
        let authTokenStore = makeAuthTokenStore(
            isUITesting: isUITesting,
            apiEnvironment: apiEnvironment
        )
        let authenticationAPIManager = makeAuthenticationAPIManager(
            analyticsCollector: analyticsCollector,
            apiEnvironment: apiEnvironment
        )
        let errorManager = makeErrorManager()
        let authenticationProvider = SessionAuthenticationProvider(
            tokenStore: authTokenStore,
            authenticationAPIManager: authenticationAPIManager
        )
        let apiManager = makeAPIManager(
            analyticsCollector: analyticsCollector,
            authenticationProvider: authenticationProvider,
            apiEnvironment: apiEnvironment
        )
        let repositories = makeRepositories(databaseManager: databaseManager)

        return (
            apiManager: apiManager,
            authTokenStore: authTokenStore,
            authenticationAPIManager: authenticationAPIManager,
            errorManager: errorManager,
            contentRepository: repositories.contentRepository,
            userRepository: repositories.userRepository,
            sessionService: UserSessionService(
                userRepository: repositories.userRepository,
                tokenStore: authTokenStore,
                authenticationAPIManager: authenticationAPIManager
            )
        )
    }

    private static func seedAppDataIfNeeded(using databaseManager: any DatabaseManaging) {
        do {
            try AppDataSeeder.seedIfNeeded(in: databaseManager)
        } catch {
            let bootstrapError = AppRuntimeErrorMapper().map(
                error,
                context: AppErrorContext(
                    operation: "seedAppDataIfNeeded",
                    feature: "bootstrap"
                )
            )
            assertionFailure("Failed to seed local data: \(bootstrapError.debugDescription)")
        }
    }

    /// Creates app repositories that sit on top of the shared database and API layer.
    private static func makeRepositories(
        databaseManager: any DatabaseManaging
    ) -> (
        contentRepository: any AppContentRepository,
        userRepository: any UserRepository
    ) {
        (
            contentRepository: DefaultAppContentRepository(
                databaseManager: databaseManager
            ),
            userRepository: DefaultUserRepository(databaseManager: databaseManager)
        )
    }

    private static func makeAPIManager(
        analyticsCollector: ProductAnalyticsMemoryCollector,
        authenticationProvider: any APIAuthenticationRefreshing,
        apiEnvironment: AppAPIEnvironment
    ) -> any APIManaging {
        var interceptors: [any APIRequestIntercepting] = [
            APIAuthenticationInterceptor(
                provider: authenticationProvider
            ),
            APIAuthorizationRefreshInterceptor(
                provider: authenticationProvider
            ),
            APIRetryInterceptor(),
            APIMetricsInterceptor(
                collector: APIAnalyticsMetricsCollector(
                    collector: analyticsCollector
                )
            )
        ]

        if apiEnvironment.enablesNetworkLogging {
            interceptors.insert(
                APILoggingInterceptor(level: .requestAndResponse),
                at: 0
            )
        }

        return APIManager(
            configuration: apiEnvironment.apiConfiguration,
            interceptors: interceptors
        )
    }

    private static func makeAuthTokenStore(
        isUITesting: Bool,
        apiEnvironment: AppAPIEnvironment
    ) -> any AuthTokenStoring {
        if isUITesting {
            return InMemoryAuthTokenStore()
        }

        switch apiEnvironment.kind {
        case .developmentStub:
            return InMemoryAuthTokenStore()
        case .developmentExternalAuth, .development, .staging, .production:
            return KeychainAuthTokenStore()
        }
    }

    /// Creates the auth-specific API manager on a dedicated unauthenticated transport pipeline.
    ///
    /// Auth endpoints should not depend on the main auth-refresh interceptor chain or they risk
    /// recursive refresh behavior. This client keeps diagnostics and generic retries, but does not
    /// inject auth headers automatically.
    private static func makeAuthenticationAPIManager(
        analyticsCollector: ProductAnalyticsMemoryCollector,
        apiEnvironment: AppAPIEnvironment
    ) -> any AuthenticationAPIManaging {
        let authAPIManager = APIManager(
            configuration: apiEnvironment.authenticationAPIConfiguration,
            interceptors: makeAuthenticationInterceptors(
                analyticsCollector: analyticsCollector,
                apiEnvironment: apiEnvironment
            )
        )

        switch apiEnvironment.kind {
        case .developmentStub:
            return DefaultAuthenticationAPIManager(
                apiManager: authAPIManager,
                endpointConfiguration: apiEnvironment.authenticationEndpointConfiguration,
                mode: .developmentSynthetic
            )
        case .developmentExternalAuth:
            return DefaultAuthenticationAPIManager(
                apiManager: authAPIManager,
                endpointConfiguration: apiEnvironment.authenticationEndpointConfiguration,
                mode: .reqResDemo
            )
        case .development, .staging, .production:
            return DefaultAuthenticationAPIManager(
                apiManager: authAPIManager,
                endpointConfiguration: apiEnvironment.authenticationEndpointConfiguration,
                mode: .remoteBackend
            )
        }
    }

    /// Builds the auth-endpoint interceptor pipeline without auth-header injection or refresh recursion.
    private static func makeAuthenticationInterceptors(
        analyticsCollector: ProductAnalyticsMemoryCollector,
        apiEnvironment: AppAPIEnvironment
    ) -> [any APIRequestIntercepting] {
        var interceptors: [any APIRequestIntercepting] = [
            APIRetryInterceptor(),
            APIMetricsInterceptor(
                collector: APIAnalyticsMetricsCollector(
                    collector: analyticsCollector
                )
            )
        ]

        if apiEnvironment.enablesNetworkLogging {
            interceptors.insert(
                APILoggingInterceptor(level: .requestAndResponse),
                at: 0
            )
        }

        return interceptors
    }

    private static func makeErrorManager() -> any AppErrorManaging {
        AppErrorManager(
            mapper: AppRuntimeErrorMapper(),
            messageCatalog: AppRuntimeErrorMessageCatalog()
        )
    }

    /// Creates the feed view model for the local-created card runtime.
    private static func makeNewsFeedViewModel(
        channelsStore: ChannelsStore,
        widgetContentSyncManager: any WidgetContentSyncing,
        errorManager: any AppErrorManaging,
        feedCardStore: FeedCardStore,
        sharedFeedCardSyncManager: SharedFeedCardSyncManager?
    ) -> NewsFeedViewModel {
        return NewsFeedViewModel(
            channelsStore: channelsStore,
            widgetContentSyncManager: widgetContentSyncManager,
            errorManager: errorManager,
            feedCardStore: feedCardStore,
            sharedFeedCardSyncManager: sharedFeedCardSyncManager
        )
    }

    private static func makeSharedFeedCardSyncManager(
        errorManager: any AppErrorManaging
    ) -> SharedFeedCardSyncManager? {
        do {
            return try SharedFeedCardSyncManager(
                groupIdentifier: AppGroupConfiguration.sharedContainerIdentifier
            )
        } catch {
            Task {
                _ = await errorManager.presentableError(
                    from: error,
                    context: AppErrorContext(
                        operation: "makeSharedFeedCardSyncManager",
                        feature: "shareExtension"
                    )
                )
            }
            return nil
        }
    }

    private static func makeShareExtensionSessionContextManager(
        errorManager: any AppErrorManaging
    ) -> ShareExtensionSessionContextManager? {
        do {
            return try ShareExtensionSessionContextManager(
                groupIdentifier: AppGroupConfiguration.sharedContainerIdentifier
            )
        } catch {
            Task {
                _ = await errorManager.presentableError(
                    from: error,
                    context: AppErrorContext(
                        operation: "makeShareExtensionSessionContextManager",
                        feature: "shareExtension"
                    )
                )
            }
            return nil
        }
    }

    private static func makeAppUIConfigurationManager(isUITesting: Bool) -> any UIConfigurationManaging<ShellUIConfiguration> {
        let store: (any UIConfigurationSnapshotStoring<ShellUIConfiguration>)? = isUITesting
            ? nil
            : AppUIConfigurationSnapshotStore(userDefaults: .standard)
        let fallbackSnapshot = AppUIConfigurationSnapshot(
            payload: ShellUIConfiguration(showsFloatingActionButton: true)
        )

        return AppUIConfigurationManager(
            remoteProvider: StaticUIConfigurationProvider(snapshot: fallbackSnapshot),
            store: store,
            stalenessPolicy: .after(300),
            refreshThrottling: .minimumInterval(30),
            fallbackSnapshot: fallbackSnapshot
        )
    }

    private static func makeWidgetContentSyncManager(
        errorManager: any AppErrorManaging
    ) -> any WidgetContentSyncing {
        do {
            let widgetSnapshotManager = try UserDefaultsWidgetSnapshotStore<FeedHeadlineWidgetSnapshot>(
                suiteName: AppGroupConfiguration.widgetsSuiteName,
                snapshotKey: FeedHeadlineWidgetConstants.snapshotKey
            )
            return FeedHeadlineWidgetSyncManager(
                snapshotManager: widgetSnapshotManager,
                errorManager: errorManager
            )
        } catch {
            Task {
                _ = await errorManager.presentableError(
                    from: error,
                    context: AppErrorContext(
                        operation: "makeWidgetContentSyncManager",
                        feature: "widgetSync"
                    )
                )
            }
            return NoopWidgetContentSyncManager()
        }
    }

    private static func makePushNotificationBridge(
        analyticsCollector: ProductAnalyticsMemoryCollector,
        errorManager: any AppErrorManaging
    ) -> any AppPushNotificationBridging {
        let pushNotificationStateStore = UserDefaultsPushNotificationStateStore(
            userDefaults: .standard
        )
        let pushNotificationManager = PushNotificationManager(
            store: pushNotificationStateStore,
            eventCollector: PushNotificationAnalyticsCollector(
                collector: analyticsCollector
            )
        )
        return AppPushNotificationBridge(
            manager: pushNotificationManager,
            errorManager: errorManager
        )
    }

    /// Creates navigation persistence and diagnostics services used by app state.
    private static func makeNavigationServices(
        analyticsCollector: ProductAnalyticsMemoryCollector
    ) -> (
        navigationStateManager: any NavigationStateManaging,
        navigationEventReporter: any NavigationEventReporting,
        deepLinkManager: any DeepLinkManaging
    ) {
        let navigationStateManager = NavigationStateManager()
        let navigationEventReporter = NavigationAnalyticsEventReporter(
            collector: analyticsCollector
        )

        return (
            navigationStateManager: navigationStateManager,
            navigationEventReporter: navigationEventReporter,
            deepLinkManager: DeepLinkManager(eventReporter: navigationEventReporter)
        )
    }
}


private struct DIContainerKey: EnvironmentKey {
    static let defaultValue: AppDIContainer? = nil
}

extension EnvironmentValues {
    /// Shared dependency container exposed to the SwiftUI environment.
    var diContainer: AppDIContainer? {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
/// App-owned shell configuration payload consumed by the generic package configuration manager.
struct ShellUIConfiguration: Codable, Equatable, Sendable {
    let showsFloatingActionButton: Bool
}

typealias AppUIConfigurationSnapshot = UIConfigurationSnapshot<ShellUIConfiguration>
typealias AppUIConfigurationManager = UIConfigurationManager<ShellUIConfiguration>
typealias AppUIConfigurationSnapshotStore = UserDefaultsUIConfigurationSnapshotStore<ShellUIConfiguration>
