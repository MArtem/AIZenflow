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

/// Runtime API environment describing transport configuration and diagnostics policy.
struct AppAPIEnvironment {
    enum Kind {
        case localStub
        case development
        case staging
        case production
    }

    let kind: Kind
    let apiConfiguration: APIConfiguration
    let enablesNetworkLogging: Bool
    let authenticationEndpointConfiguration: AuthenticationAPIEndpointConfiguration

    static let localStub = AppAPIEnvironment(
        kind: .localStub,
        apiConfiguration: .stub,
        enablesNetworkLogging: false,
        authenticationEndpointConfiguration: .default
    )

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
            enablesNetworkLogging: enablesNetworkLogging,
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
}

/// App-local error mapper layered on top of the shared infrastructure mapper.
///
/// `TchopErrors` intentionally knows only generic infrastructure failures. This mapper keeps
/// feature-specific semantics in the app target so repository/session errors can carry stable
/// categories, retry policy, and recovery hints before a real backend is connected.
private struct AppRuntimeErrorMapper: AppErrorMapping {
    private let fallbackMapper: any AppErrorMapping

    init(fallbackMapper: any AppErrorMapping = DefaultAppErrorMapper()) {
        self.fallbackMapper = fallbackMapper
    }

    func map(_ error: Error, context: AppErrorContext?) -> AppError {
        if let databaseError = error as? DatabaseError {
            return mapDatabaseError(databaseError, context: context)
        }

        if let authenticationError = error as? AuthenticationSessionError {
            return mapAuthenticationError(authenticationError, context: context)
        }

        if let userRepositoryError = error as? UserRepositoryError {
            return mapUserRepositoryError(userRepositoryError, context: context)
        }

        if let repositoryError = error as? RepositoryError {
            return mapRepositoryError(repositoryError, context: context)
        }

        let secureStorageError = error as NSError
        if secureStorageError.domain == NSOSStatusErrorDomain {
            return AppError(
                category: .persistence,
                severity: .critical,
                suggestion: .reauthenticate,
                isRetryable: false,
                isSessionRecoveryRequired: true,
                messageKey: "error.persistence.secureStorage",
                debugDescription: "Secure storage failure: \(secureStorageError.code).",
                context: context
            )
        }

        return fallbackMapper.map(error, context: context)
    }

    private func mapDatabaseError(
        _ error: DatabaseError,
        context: AppErrorContext?
    ) -> AppError {
        switch error {
        case .backendInitializationFailed(let reason), .migrationFailed(let reason):
            return AppError(
                category: .persistence,
                severity: .critical,
                suggestion: .restartFlow,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.databaseBootstrap",
                debugDescription: reason,
                context: context
            )
        case .transactionFailed(let reason), .saveFailed(let reason), .deleteFailed(let reason):
            return AppError(
                category: .persistence,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.databaseWrite",
                debugDescription: reason,
                context: context
            )
        case .fetchFailed(let reason):
            return AppError(
                category: .persistence,
                severity: .warning,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.databaseRead",
                debugDescription: reason,
                context: context
            )
        case .unsupportedOperation(let reason):
            return AppError(
                category: .client,
                severity: .error,
                suggestion: .none,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.client.unsupportedOperation",
                debugDescription: reason,
                context: context
            )
        }
    }

    private func mapAuthenticationError(
        _ error: AuthenticationSessionError,
        context: AppErrorContext?
    ) -> AppError {
        switch error {
        case .missingRefreshToken:
            return AppError(
                category: .authentication,
                severity: .error,
                suggestion: .reauthenticate,
                isRetryable: false,
                isSessionRecoveryRequired: true,
                messageKey: "error.auth.refreshMissing",
                debugDescription: "Refresh was requested without a persisted refresh token.",
                context: context
            )
        }
    }

    private func mapRepositoryError(
        _ error: RepositoryError,
        context: AppErrorContext?
    ) -> AppError {
        switch error {
        case .offlineCardAction:
            return AppError(
                category: .network,
                severity: .warning,
                suggestion: .checkConnection,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.network.offline",
                debugDescription: "Card action requires connectivity but the device is offline.",
                context: context
            )
        case .missingPersistedFeed:
            return AppError(
                category: .persistence,
                severity: .warning,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.feedMissing",
                debugDescription: "Persisted feed snapshot is unavailable.",
                context: context
            )
        case .missingPersistedFeedCard:
            return AppError(
                category: .persistence,
                severity: .warning,
                suggestion: .restartFlow,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.feedCardMissing",
                debugDescription: "Persisted feed card is unavailable for the requested action.",
                context: context
            )
        case .missingChannel:
            return AppError(
                category: .persistence,
                severity: .error,
                suggestion: .restartFlow,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.channelMissing",
                debugDescription: "Persisted channel bootstrap data is unavailable.",
                context: context
            )
        }
    }

    private func mapUserRepositoryError(
        _ error: UserRepositoryError,
        context: AppErrorContext?
    ) -> AppError {
        switch error {
        case .invalidUsername:
            return AppError(
                category: .validation,
                severity: .warning,
                suggestion: .none,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.validation.username",
                debugDescription: "The provided username is invalid after normalization.",
                context: context
            )
        case .unableToResolveUniqueUsername:
            return AppError(
                category: .client,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.client.usernameResolution",
                debugDescription: "Unable to resolve a unique local username for the account.",
                context: context
            )
        case .userNotFound:
            return AppError(
                category: .persistence,
                severity: .warning,
                suggestion: .restartFlow,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.userMissing",
                debugDescription: "Expected persisted user record is missing.",
                context: context
            )
        }
    }
}

/// App-local message catalog that keeps user text for domain-specific app failures near the
/// composition root while still delegating infrastructure keys to the shared package defaults.
private struct AppRuntimeErrorMessageCatalog: AppErrorMessageCatalog {
    private let fallbackCatalog: any AppErrorMessageCatalog

    init(fallbackCatalog: any AppErrorMessageCatalog = DefaultAppErrorMessageCatalog()) {
        self.fallbackCatalog = fallbackCatalog
    }

    func userMessage(for error: AppError) -> String {
        switch error.messageKey {
        case "error.auth.refreshMissing":
            return AppLocalization.text(
                "auth.error.refreshMissing",
                fallback: "Session expired. Please sign in again."
            )
        case "error.persistence.secureStorage":
            return AppLocalization.text(
                "auth.error.secureStorage",
                fallback: "Secure session data is unavailable. Please sign in again."
            )
        case "error.persistence.feedMissing":
            return AppLocalization.text(
                "news.error.savedFeedMissing",
                fallback: "Saved feed is unavailable. Try refreshing again."
            )
        case "error.persistence.feedCardMissing":
            return AppLocalization.text(
                "news.error.savedCardMissing",
                fallback: "Saved card state is unavailable. Refresh the feed."
            )
        case "error.persistence.channelMissing":
            return AppLocalization.text(
                "shell.error.channelMissing",
                fallback: "Channel data is unavailable. Restart the app or try again."
            )
        case "error.persistence.databaseBootstrap":
            return AppLocalization.text(
                "app.error.databaseBootstrap",
                fallback: "App data is unavailable. Restart the app and try again."
            )
        case "error.persistence.databaseWrite":
            return AppLocalization.text(
                "app.error.databaseWrite",
                fallback: "Unable to save local data right now. Try again."
            )
        case "error.persistence.databaseRead":
            return AppLocalization.text(
                "app.error.databaseRead",
                fallback: "Unable to read local data right now. Try again."
            )
        case "error.validation.username":
            return AppLocalization.text(
                "login.error.invalidUsername",
                fallback: "Enter a valid username."
            )
        case "error.client.usernameResolution":
            return AppLocalization.text(
                "login.apple.error.usernameResolution",
                fallback: "Unable to prepare a local account right now. Please try again."
            )
        case "error.persistence.userMissing":
            return AppLocalization.text(
                "profile.error.userMissing",
                fallback: "Account data is unavailable. Sign in again."
            )
        default:
            return fallbackCatalog.userMessage(for: error)
        }
    }
}

/// Composition root for the application.
///
/// The container owns app-wide infrastructure services and constructs feature-level
/// dependencies for the SwiftUI tree.
@MainActor
final class AppDIContainer: ObservableObject {
    /// Shared in-memory analytics sink that app runtime integrations can reuse.
    let analyticsCollector: ProductAnalyticsMemoryCollector

    /// Database backend adapter consumed by repositories and seeders.
    let databaseManager: any DatabaseManaging

    /// Shared networking client used by feature-specific API managers.
    let apiManager: any APIManaging

    /// Secure token storage used by auth-aware networking and session flows.
    let authTokenStore: any AuthTokenStoring

    /// Auth API manager responsible for token refresh/session-auth calls.
    let authenticationAPIManager: any AuthenticationAPIManaging

    /// Shared app error manager used by UI/session flows for normalization and reporting.
    let errorManager: any AppErrorManaging

    /// Feed-specific API abstraction currently backed by stub data.
    let feedAPIManager: any FeedAPIManaging

    /// Lightweight connectivity monitor used by repository runtime decisions.
    let networkAvailabilityMonitor: any NetworkAvailabilityChecking

    /// Repository serving shell and feed content.
    let contentRepository: any AppContentRepository

    /// Repository serving persisted users.
    let userRepository: any UserRepository

    /// Service responsible for sign-in and session restoration.
    let sessionService: any UserSessionManaging

    /// Apple auth adapter used by the login UI flow.
    let appleAuthenticationManager: any AppleAuthenticationManaging

    /// Remote UI configuration manager used for server-driven shell tweaks.
    let uiConfigurationManager: any UIConfigurationManaging

    /// Manager that persists/restores per-user navigation snapshots.
    let navigationStateManager: any NavigationStateManaging

    /// Manager that handles deep and universal links for app navigation.
    let deepLinkManager: any DeepLinkManaging

    /// Reporter for navigation restore/deep-link diagnostics.
    let navigationEventReporter: any NavigationEventReporting

    /// Bridge that syncs app content into shared widget storage.
    let widgetContentSyncManager: any WidgetContentSyncing

    /// Bridge that adapts system APNs callbacks into package-backed push state handling.
    let pushNotificationBridge: any AppPushNotificationBridging

    /// Active persistence backend chosen for the current app runtime.
    let databaseBackendKind: AppDatabaseBackendKind

    /// Creates the root dependency container and eagerly wires the initial graph.
    init(
        databaseConfiguration: AppDatabaseConfiguration = .persistent,
        apiEnvironment: AppAPIEnvironment = .localStub
    ) {
        let analyticsCollector = ProductAnalyticsMemoryCollector()
        self.analyticsCollector = analyticsCollector

        let databaseManager = Self.makeSeededDatabaseManager(
            configuration: databaseConfiguration
        )
        self.databaseManager = databaseManager
        self.databaseBackendKind = databaseManager.backendKind

        let contentServices = Self.makeContentServices(
            databaseManager: databaseManager,
            analyticsCollector: analyticsCollector,
            apiEnvironment: apiEnvironment
        )
        self.apiManager = contentServices.apiManager
        self.authTokenStore = contentServices.authTokenStore
        self.authenticationAPIManager = contentServices.authenticationAPIManager
        self.errorManager = contentServices.errorManager
        self.feedAPIManager = contentServices.feedAPIManager
        self.networkAvailabilityMonitor = contentServices.networkAvailabilityMonitor
        self.contentRepository = contentServices.contentRepository
        self.userRepository = contentServices.userRepository
        self.sessionService = contentServices.sessionService
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
    }

    /// Creates the shell view model used by the authenticated part of the app.
    func makeAppShellViewModel() -> AppShellViewModel {
        let newsFeedViewModel = Self.makeNewsFeedViewModel(
            repository: contentRepository,
            widgetContentSyncManager: widgetContentSyncManager,
            errorManager: errorManager
        )

        return AppShellViewModel(
            channelInfo: Self.resolveChannelInfo(from: contentRepository),
            newsFeedViewModel: newsFeedViewModel,
            errorManager: errorManager,
            uiConfigurationManager: uiConfigurationManager,
        )
    }

    /// Creates the root app state object used by the app entry point.
    func makeAppState() -> AppState {
        let coordinator = AppCoordinator()
        let appShellViewModel = makeAppShellViewModel()

        return AppState(
            coordinator: coordinator,
            appShellViewModel: appShellViewModel,
            sessionService: sessionService,
            userRepository: userRepository,
            navigationStateManager: navigationStateManager,
            deepLinkManager: deepLinkManager,
            navigationEventReporter: navigationEventReporter,
            widgetContentSyncManager: widgetContentSyncManager,
            pushNotificationBridge: pushNotificationBridge,
            errorManager: errorManager
        )
    }

    /// Creates the shared database manager and performs local seeding before the graph is assembled.
    private static func makeSeededDatabaseManager(
        configuration: AppDatabaseConfiguration
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
        apiEnvironment: AppAPIEnvironment
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
        let authTokenStore = makeAuthTokenStore()
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

    private static func makeAuthTokenStore() -> any AuthTokenStoring {
        KeychainAuthTokenStore()
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
            configuration: apiEnvironment.apiConfiguration,
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
        case .development, .staging, .production:
            return DefaultAuthenticationAPIManager(
                apiManager: authAPIManager,
                endpointConfiguration: apiEnvironment.authenticationEndpointConfiguration,
                mode: .remote
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
        widgetContentSyncManager: any WidgetContentSyncing,
        errorManager: any AppErrorManaging
    ) -> NewsFeedViewModel {
        let initialContent = resolveInitialNewsFeedContent(from: repository)

        return NewsFeedViewModel(
            repository: repository,
            widgetContentSyncManager: widgetContentSyncManager,
            errorManager: errorManager,
            initialContent: initialContent,
            loadFailureContent: initialContent,
            loadFailureMessage: AppLocalization.text(
                "news.error.loadFailed",
                fallback: "Failed to load feed."
            )
        )
    }

    /// Resolves the best local feed snapshot for bootstrap and falls back to fixtures only when storage is empty.
    ///
    /// This keeps the home screen aligned with the repository contract: the UI should prefer a
    /// persisted snapshot over hard-coded content whenever possible.
    private static func resolveInitialNewsFeedContent(
        from repository: any NewsFeedRepository
    ) -> NewsFeedContent {
        if let localContent = try? repository.currentNewsFeedContent() ?? nil {
            return localContent
        }

        return NewsFeedFixtures.fallbackContent
    }

    /// Resolves repository-backed channel info or falls back to local defaults.
    ///
    /// Channel metadata is expected to exist locally after seeding, but the shell still keeps
    /// a defensive fallback so bootstrap failures do not break the authenticated UI.
    private static func resolveChannelInfo(from repository: any AppContentRepository) -> ChannelHeaderInfo {
        if let channelInfo = try? repository.fetchChannelInfo() {
            return channelInfo
        }

        return ChannelHeaderInfo(
            title: AppLocalization.text("channel.default.title", fallback: "Tchop"),
            subtitle: AppLocalization.text("channel.default.subtitle", fallback: "New channel name")
        )
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
