import Foundation
import SwiftUI
import TchopAnalytics
import TchopAppleAuthentication
import TchopDatabase
import TchopErrors
import TchopNavigation
import TchopNetworking
import TchopPushNotifications
import TchopUIConfiguration
import TchopWidgets
import TchopShareSupport

/// Runtime API environment describing transport configuration and diagnostics policy.
struct AppAPIEnvironment {
    enum Kind {
        case localStub
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

    static let localStub = AppAPIEnvironment(
        kind: .localStub,
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

    /// Feed-specific API abstraction currently backed by stub data.
    private let feedAPIManager: any FeedAPIManaging

    /// Lightweight connectivity monitor used by repository runtime decisions.
    private let networkAvailabilityMonitor: any NetworkAvailabilityChecking

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
    let localFeedCardStore: LocalFeedCardStore

    /// App-group-backed bridge that syncs extension-published local cards into app runtime.
    let sharedLocalFeedCardSyncManager: SharedLocalFeedCardSyncManager?

    /// App-group-backed bridge that exposes the current auth/channel snapshot to the share extension.
    let shareExtensionSessionContextManager: ShareExtensionSessionContextManager?

    /// User-scoped channel settings source resolved during session bootstrap.
    private let channelSettingsRepository: LocalUserChannelSettingsRepository

    /// Apple auth adapter used by the login UI flow.
    let appleAuthenticationManager: any AppleAuthenticationManaging

    /// Remote UI configuration manager used for server-driven shell tweaks.
    private let uiConfigurationManager: any UIConfigurationManaging

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
        apiEnvironment: AppAPIEnvironment = .localStub,
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
        self.feedAPIManager = contentServices.feedAPIManager
        self.networkAvailabilityMonitor = contentServices.networkAvailabilityMonitor
        self.contentRepository = contentServices.contentRepository
        self.userRepository = contentServices.userRepository
        self.sessionService = contentServices.sessionService
        self.sessionStore = SessionStore()
        self.channelsStore = ChannelsStore(
            selectionStore: UserDefaultsChannelSelectionStore()
        )
        self.localFeedCardStore = LocalFeedCardStore(
            repository: LocalFeedCardRepository(databaseManager: databaseManager)
        )
        self.sharedLocalFeedCardSyncManager = Self.makeSharedLocalFeedCardSyncManager(
            errorManager: errorManager
        )
        self.shareExtensionSessionContextManager = Self.makeShareExtensionSessionContextManager(
            errorManager: errorManager
        )
        self.channelSettingsRepository = LocalUserChannelSettingsRepository()
        self.appleAuthenticationManager = AppleAuthenticationManager()

        self.uiConfigurationManager = Self.makeUIConfigurationManager()
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
            repository: contentRepository,
            channelsStore: channelsStore,
            widgetContentSyncManager: widgetContentSyncManager,
            errorManager: errorManager,
            localFeedCardStore: localFeedCardStore,
            sharedLocalFeedCardSyncManager: sharedLocalFeedCardSyncManager
        )

        return AppShellViewModel(
            channelsStore: channelsStore,
            localFeedCardStore: localFeedCardStore,
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

        seedLocalDataIfNeeded(using: databaseManager)
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
        feedAPIManager: any FeedAPIManaging,
        networkAvailabilityMonitor: any NetworkAvailabilityChecking,
        contentRepository: any AppContentRepository,
        userRepository: any UserRepository,
        sessionService: any UserSessionManaging
    ) {
        let authTokenStore = makeAuthTokenStore(isUITesting: isUITesting)
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
        let feedAPIManager = makeFeedAPIManager(apiManager: apiManager)
        let networkAvailabilityMonitor = NetworkAvailabilityMonitor()
        let repositories = makeRepositories(
            databaseManager: databaseManager,
            feedAPIManager: feedAPIManager,
            networkAvailabilityChecker: networkAvailabilityMonitor
        )

        return (
            apiManager: apiManager,
            authTokenStore: authTokenStore,
            authenticationAPIManager: authenticationAPIManager,
            errorManager: errorManager,
            feedAPIManager: feedAPIManager,
            networkAvailabilityMonitor: networkAvailabilityMonitor,
            contentRepository: repositories.contentRepository,
            userRepository: repositories.userRepository,
            sessionService: UserSessionService(
                userRepository: repositories.userRepository,
                tokenStore: authTokenStore,
                authenticationAPIManager: authenticationAPIManager
            )
        )
    }

    private static func seedLocalDataIfNeeded(using databaseManager: any DatabaseManaging) {
        do {
            try AppDataSeeder.seedIfNeeded(in: databaseManager)
        } catch {
            let bootstrapError = AppRuntimeErrorMapper().map(
                error,
                context: AppErrorContext(
                    operation: "seedLocalDataIfNeeded",
                    feature: "bootstrap"
                )
            )
            assertionFailure("Failed to seed local data: \(bootstrapError.debugDescription)")
        }
    }

    /// Creates app repositories that sit on top of the shared database and API layer.
    private static func makeRepositories(
        databaseManager: any DatabaseManaging,
        feedAPIManager: any FeedAPIManaging,
        networkAvailabilityChecker: any NetworkAvailabilityChecking
    ) -> (
        contentRepository: any AppContentRepository,
        userRepository: any UserRepository
    ) {
        (
            contentRepository: DefaultAppContentRepository(
                databaseManager: databaseManager,
                feedAPIManager: feedAPIManager,
                networkAvailabilityChecker: networkAvailabilityChecker
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

    private static func makeAuthTokenStore(isUITesting: Bool) -> any AuthTokenStoring {
        if isUITesting {
            return InMemoryAuthTokenStore()
        }

        return KeychainAuthTokenStore()
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
        case .localStub:
            return DefaultAuthenticationAPIManager(
                apiManager: authAPIManager,
                endpointConfiguration: apiEnvironment.authenticationEndpointConfiguration,
                mode: .localStub
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

    private static func makeFeedAPIManager(apiManager: any APIManaging) -> any FeedAPIManaging {
        StubFeedAPIManager(apiManager: apiManager)
    }

    /// Creates the feed view model with app-level bootstrap and fallback content.
    ///
    /// The view model starts from the best local snapshot available. Fixtures are only used as
    /// an emergency fallback when the persisted feed has not been seeded yet or cannot be read.
    private static func makeNewsFeedViewModel(
        repository: any NewsFeedRepository,
        channelsStore: ChannelsStore,
        widgetContentSyncManager: any WidgetContentSyncing,
        errorManager: any AppErrorManaging,
        localFeedCardStore: LocalFeedCardStore,
        sharedLocalFeedCardSyncManager: SharedLocalFeedCardSyncManager?
    ) -> NewsFeedViewModel {
        let initialContent = resolveInitialNewsFeedContent(
            from: repository,
            channelsStore: channelsStore
        )

        return NewsFeedViewModel(
            repository: repository,
            channelsStore: channelsStore,
            widgetContentSyncManager: widgetContentSyncManager,
            errorManager: errorManager,
            localFeedCardStore: localFeedCardStore,
            sharedLocalFeedCardSyncManager: sharedLocalFeedCardSyncManager,
            initialContent: initialContent,
            loadFailureContent: initialContent,
            loadFailureMessage: AppLocalization.text("news.error.loadFailed")
        )
    }

    private static func makeSharedLocalFeedCardSyncManager(
        errorManager: any AppErrorManaging
    ) -> SharedLocalFeedCardSyncManager? {
        do {
            return try SharedLocalFeedCardSyncManager(
                groupIdentifier: AppGroupConfiguration.sharedContainerIdentifier
            )
        } catch {
            Task {
                let presentation = await errorManager.presentableError(
                    from: error,
                    context: AppErrorContext(
                        operation: "makeSharedLocalFeedCardSyncManager",
                        feature: "shareExtension"
                    )
                )
                assertionFailure("Failed to create shared local feed card sync manager: \(presentation.error.debugDescription)")
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
                let presentation = await errorManager.presentableError(
                    from: error,
                    context: AppErrorContext(
                        operation: "makeShareExtensionSessionContextManager",
                        feature: "shareExtension"
                    )
                )
                assertionFailure("Failed to create share extension session context manager: \(presentation.error.debugDescription)")
            }
            return nil
        }
    }

    /// Resolves the best local feed snapshot for bootstrap and falls back to fixtures only when storage is empty.
    ///
    /// This keeps the home screen aligned with the repository contract: the UI should prefer a
    /// persisted snapshot over hard-coded content whenever possible.
    private static func resolveInitialNewsFeedContent(
        from repository: any NewsFeedRepository,
        channelsStore: ChannelsStore
    ) -> NewsFeedContent {
        let channelID = channelsStore.selectedChannelID ?? channelsStore.selectedChannel?.id ?? AppChannel.defaultChannel.id
        if let localContent = (try? repository.currentNewsFeedContent(channelID: channelID)) ?? nil {
            return localContent
        }

        return NewsFeedFixtures.makeFallbackContent(channelID: channelID)
    }

    private static func makeUIConfigurationManager() -> any UIConfigurationManaging {
        UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(),
            store: UserDefaultsUIConfigurationSnapshotStore(userDefaults: .standard),
            stalenessPolicy: .after(300),
            refreshThrottling: .minimumInterval(30)
        )
    }

    private static func makeWidgetContentSyncManager(
        errorManager: any AppErrorManaging
    ) -> any WidgetContentSyncing {
        do {
            let widgetSnapshotManager = try UserDefaultsFeedHeadlineWidgetSnapshotManager(
                suiteName: AppGroupConfiguration.widgetsSuiteName
            )
            return FeedHeadlineWidgetSyncManager(
                snapshotManager: widgetSnapshotManager,
                errorManager: errorManager
            )
        } catch {
            Task {
                let presentation = await errorManager.presentableError(
                    from: error,
                    context: AppErrorContext(
                        operation: "makeWidgetContentSyncManager",
                        feature: "widgetSync"
                    )
                )
                assertionFailure("Failed to create widget sync manager: \(presentation.error.debugDescription)")
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
