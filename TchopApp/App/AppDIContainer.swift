import Foundation
import SwiftUI
import TchopAnalytics
import TchopAppleAuthentication
import TchopDatabase
import TchopNavigation
import TchopNetworking
import TchopPushNotifications
import TchopUIConfiguration
import TchopWidgets

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

    /// Feed-specific API abstraction currently backed by stub data.
    let feedAPIManager: any FeedAPIManaging

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
    init(databaseConfiguration: AppDatabaseConfiguration = .persistent) {
        let analyticsCollector = ProductAnalyticsMemoryCollector()
        self.analyticsCollector = analyticsCollector

        let databaseManager = Self.makeSeededDatabaseManager(
            configuration: databaseConfiguration
        )
        self.databaseManager = databaseManager
        self.databaseBackendKind = databaseManager.backendKind

        let contentServices = Self.makeContentServices(
            databaseManager: databaseManager,
            analyticsCollector: analyticsCollector
        )
        self.apiManager = contentServices.apiManager
        self.feedAPIManager = contentServices.feedAPIManager
        self.contentRepository = contentServices.contentRepository
        self.userRepository = contentServices.userRepository
        self.sessionService = contentServices.sessionService
        self.appleAuthenticationManager = AppleAuthenticationManager()

        self.uiConfigurationManager = Self.makeUIConfigurationManager()
        self.widgetContentSyncManager = Self.makeWidgetContentSyncManager()
        self.pushNotificationBridge = Self.makePushNotificationBridge(
            analyticsCollector: analyticsCollector
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
            widgetContentSyncManager: widgetContentSyncManager
        )

        return AppShellViewModel(
            channelInfo: Self.resolveChannelInfo(from: contentRepository),
            newsFeedViewModel: newsFeedViewModel,
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
            pushNotificationBridge: pushNotificationBridge
        )
    }

    /// Creates the shared database manager and performs local seeding before the graph is assembled.
    private static func makeSeededDatabaseManager(
        configuration: AppDatabaseConfiguration
    ) -> any DatabaseManaging {
        let databaseManager = AppDatabase.makeDatabaseManager(configuration: configuration)
        seedLocalDataIfNeeded(using: databaseManager)
        return databaseManager
    }

    /// Creates the content-facing stack from networking through repositories and session service.
    private static func makeContentServices(
        databaseManager: any DatabaseManaging,
        analyticsCollector: ProductAnalyticsMemoryCollector
    ) -> (
        apiManager: any APIManaging,
        feedAPIManager: any FeedAPIManaging,
        contentRepository: any AppContentRepository,
        userRepository: any UserRepository,
        sessionService: any UserSessionManaging
    ) {
        let apiManager = makeAPIManager(analyticsCollector: analyticsCollector)
        let feedAPIManager = makeFeedAPIManager(apiManager: apiManager)
        let repositories = makeRepositories(
            databaseManager: databaseManager,
            feedAPIManager: feedAPIManager
        )

        return (
            apiManager: apiManager,
            feedAPIManager: feedAPIManager,
            contentRepository: repositories.contentRepository,
            userRepository: repositories.userRepository,
            sessionService: UserSessionService(userRepository: repositories.userRepository)
        )
    }

    private static func seedLocalDataIfNeeded(using databaseManager: any DatabaseManaging) {
        do {
            try AppDataSeeder.seedIfNeeded(in: databaseManager)
        } catch {
            assertionFailure("Failed to seed local data: \(error)")
        }
    }

    /// Creates app repositories that sit on top of the shared database and API layer.
    private static func makeRepositories(
        databaseManager: any DatabaseManaging,
        feedAPIManager: any FeedAPIManaging
    ) -> (
        contentRepository: any AppContentRepository,
        userRepository: any UserRepository
    ) {
        (
            contentRepository: DefaultAppContentRepository(
                databaseManager: databaseManager,
                feedAPIManager: feedAPIManager
            ),
            userRepository: DefaultUserRepository(databaseManager: databaseManager)
        )
    }

    private static func makeAPIManager(
        analyticsCollector: ProductAnalyticsMemoryCollector
    ) -> any APIManaging {
        APIManager(
            configuration: .stub,
            interceptors: [
                APIMetricsInterceptor(
                    collector: APIAnalyticsMetricsCollector(
                        collector: analyticsCollector
                    )
                )
            ]
        )
    }

    private static func makeFeedAPIManager(apiManager: any APIManaging) -> any FeedAPIManaging {
        StubFeedAPIManager(apiManager: apiManager)
    }

    /// Creates the feed view model with app-level bootstrap and fallback content.
    private static func makeNewsFeedViewModel(
        repository: any NewsFeedRepository,
        widgetContentSyncManager: any WidgetContentSyncing
    ) -> NewsFeedViewModel {
        NewsFeedViewModel(
            repository: repository,
            widgetContentSyncManager: widgetContentSyncManager,
            initialContent: NewsFeedFixtures.fallbackContent,
            loadFailureContent: NewsFeedFixtures.fallbackContent,
            loadFailureMessage: AppLocalization.text(
                "news.error.loadFailed",
                fallback: "Failed to load feed."
            )
        )
    }

    /// Resolves repository-backed channel info or falls back to local defaults.
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

    private static func makeWidgetContentSyncManager() -> any WidgetContentSyncing {
        let widgetSnapshotManager = try? UserDefaultsFeedHeadlineWidgetSnapshotManager(
            suiteName: AppGroupConfiguration.widgetsSuiteName
        )
        return widgetSnapshotManager.map {
            FeedHeadlineWidgetSyncManager(snapshotManager: $0)
        } ?? NoopWidgetContentSyncManager()
    }

    private static func makePushNotificationBridge(
        analyticsCollector: ProductAnalyticsMemoryCollector
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
        return AppPushNotificationBridge(manager: pushNotificationManager)
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
