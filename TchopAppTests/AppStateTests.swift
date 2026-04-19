import XCTest
import TchopDatabase
import TchopUIConfiguration
@testable import TchopApp

/// Covers app session and navigation restore flows in root state.
@MainActor
final class AppStateTests: XCTestCase {
    func testSignInUpdatesCurrentUser() throws {
        let expectedUser = AppUser(id: "user-1", username: "alice", createdAt: Date())
        let sessionService = TestUserSessionService(
            signInResult: .success(expectedUser),
            restoreResult: .success(nil)
        )
        let coordinator = AppCoordinator()
        let shellViewModel = makeShellViewModel()
        let state = AppState(
            coordinator: coordinator,
            appShellViewModel: shellViewModel,
            sessionService: sessionService,
            userRepository: TestUserRepository(user: expectedUser),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge()
        )

        try state.signIn(username: "alice")

        XCTAssertEqual(state.currentUser, expectedUser)
    }

    func testInitRestoresPersistedSession() {
        let restoredUser = AppUser(id: "user-2", username: "restored", createdAt: Date())
        let sessionService = TestUserSessionService(
            signInResult: .failure(TestSessionError.signInUnavailable),
            restoreResult: .success(restoredUser)
        )
        let state = AppState(
            coordinator: AppCoordinator(),
            appShellViewModel: makeShellViewModel(),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge()
        )

        XCTAssertEqual(state.currentUser, restoredUser)
    }

    func testSignOutClearsUserAndResetsShellState() {
        let restoredUser = AppUser(id: "user-3", username: "signed-in", createdAt: Date())
        let sessionService = TestUserSessionService(
            signInResult: .success(restoredUser),
            restoreResult: .success(restoredUser)
        )
        let coordinator = AppCoordinator()
        coordinator.selectTab(.profile)
        coordinator.newsRouter.push(
            NewsRoute(
                destinationID: "news-detail",
                title: "News",
                subtitle: "Subtitle",
                bodyText: "Body"
            )
        )

        let shellViewModel = makeShellViewModel(isMenuOpen: true)
        let state = AppState(
            coordinator: coordinator,
            appShellViewModel: shellViewModel,
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge()
        )

        state.signOut()

        XCTAssertNil(state.currentUser)
        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.newsRouter.path.isEmpty)
        XCTAssertFalse(shellViewModel.isMenuOpen)
        XCTAssertEqual(sessionService.signOutCallCount, 1)
    }

    func testInitRestoresNavigationSnapshotWhenFlagEnabled() {
        let restoredUser = AppUser(
            id: "user-snapshot-enabled",
            username: "snapshot-on",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: true
        )
        let snapshot = NavigationSnapshot(
            selectedTab: .chat,
            newsPath: [],
            mixesPath: [],
            pinnedPath: [],
            chatPath: [ChatRoute(title: "Room", description: "From snapshot")],
            profilePath: []
        )
        let stateManager = TestNavigationStateManager(seed: [restoredUser.id: snapshot])
        let sessionService = TestUserSessionService(
            signInResult: .success(restoredUser),
            restoreResult: .success(restoredUser)
        )
        let coordinator = AppCoordinator()

        _ = AppState(
            coordinator: coordinator,
            appShellViewModel: makeShellViewModel(),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            navigationStateManager: stateManager,
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge()
        )

        XCTAssertEqual(coordinator.selectedTab, .chat)
        XCTAssertEqual(coordinator.chatRouter.path.count, 1)
    }

    func testInitDoesNotRestoreSnapshotWhenFlagDisabled() {
        let restoredUser = AppUser(
            id: "user-snapshot-disabled",
            username: "snapshot-off",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: false
        )
        let snapshot = NavigationSnapshot(
            selectedTab: .profile,
            newsPath: [],
            mixesPath: [],
            pinnedPath: [],
            chatPath: [],
            profilePath: [ProfileRoute(title: "Saved", description: "Saved")]
        )
        let stateManager = TestNavigationStateManager(seed: [restoredUser.id: snapshot])
        let sessionService = TestUserSessionService(
            signInResult: .success(restoredUser),
            restoreResult: .success(restoredUser)
        )
        let coordinator = AppCoordinator(selectedTab: .mixes)

        _ = AppState(
            coordinator: coordinator,
            appShellViewModel: makeShellViewModel(),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            navigationStateManager: stateManager,
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge()
        )

        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
    }

    func testSignInPrioritizesPendingDeepLinkOverSnapshotRestore() throws {
        let signedInUser = AppUser(
            id: "user-priority",
            username: "priority-user",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: true
        )
        let snapshot = NavigationSnapshot(
            selectedTab: .profile,
            newsPath: [],
            mixesPath: [],
            pinnedPath: [],
            chatPath: [],
            profilePath: [ProfileRoute(title: "Snapshot", description: "Should be skipped")]
        )
        let stateManager = TestNavigationStateManager(seed: [signedInUser.id: snapshot])
        let sessionService = TestUserSessionService(
            signInResult: .success(signedInUser),
            restoreResult: .success(nil)
        )
        let coordinator = AppCoordinator()
        let state = AppState(
            coordinator: coordinator,
            appShellViewModel: makeShellViewModel(),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: signedInUser),
            navigationStateManager: stateManager,
            deepLinkManager: DeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge()
        )

        XCTAssertTrue(state.handleIncomingURL(URL(string: "tchop://chat?title=Support&description=Urgent")!))

        try state.signIn(username: signedInUser.username)

        XCTAssertEqual(coordinator.selectedTab, .chat)
        XCTAssertEqual(coordinator.chatRouter.path.first?.title, "Support")
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
    }

    func testInitMigratesAndSanitizesSnapshotBeforeApply() {
        let restoredUser = AppUser(
            id: "user-snapshot-migrate",
            username: "snapshot-migrate",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: true
        )

        let oversizedChatPath = (0..<25).map { index in
            ChatRoute(title: "Room \(index)", description: "Description \(index)")
        }
        let legacySnapshot = NavigationSnapshot(
            version: 1,
            selectedTab: .chat,
            newsPath: [],
            mixesPath: [],
            pinnedPath: [],
            chatPath: oversizedChatPath,
            profilePath: []
        )
        let stateManager = TestNavigationStateManager(seed: [restoredUser.id: legacySnapshot])
        let reporter = NavigationMemoryEventReporter()

        _ = AppState(
            coordinator: AppCoordinator(),
            appShellViewModel: makeShellViewModel(),
            sessionService: TestUserSessionService(
                signInResult: .success(restoredUser),
                restoreResult: .success(restoredUser)
            ),
            userRepository: TestUserRepository(user: restoredUser),
            navigationStateManager: stateManager,
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: reporter,
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge()
        )

        let savedSnapshot = stateManager.snapshot(for: restoredUser.id)
        XCTAssertEqual(savedSnapshot?.version, NavigationSnapshot.supportedVersion)
        XCTAssertEqual(savedSnapshot?.chatPath.count, NavigationSnapshot.maxRoutesPerTab)
        XCTAssertTrue(
            reporter.events.contains(
                .snapshotRestoreCompleted(
                    userID: restoredUser.id,
                    appliedVersion: NavigationSnapshot.supportedVersion,
                    wasSanitized: true,
                    wasMigrated: true
                )
            )
        )
    }

    func testInitDropsFutureSnapshotVersionAndResetsNavigationSafely() {
        let restoredUser = AppUser(
            id: "user-snapshot-future",
            username: "snapshot-future",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: true
        )
        let futureSnapshot = NavigationSnapshot(
            version: NavigationSnapshot.supportedVersion + 1,
            selectedTab: .profile,
            newsPath: [],
            mixesPath: [],
            pinnedPath: [],
            chatPath: [],
            profilePath: [ProfileRoute(title: "Future", description: "Unsupported")]
        )
        let stateManager = TestNavigationStateManager(seed: [restoredUser.id: futureSnapshot])
        let coordinator = AppCoordinator(selectedTab: .chat)
        let reporter = NavigationMemoryEventReporter()

        _ = AppState(
            coordinator: coordinator,
            appShellViewModel: makeShellViewModel(),
            sessionService: TestUserSessionService(
                signInResult: .success(restoredUser),
                restoreResult: .success(restoredUser)
            ),
            userRepository: TestUserRepository(user: restoredUser),
            navigationStateManager: stateManager,
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: reporter,
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge()
        )

        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
        XCTAssertNil(stateManager.snapshot(for: restoredUser.id))
        XCTAssertTrue(
            reporter.events.contains(
                .snapshotRestoreFailed(
                    userID: restoredUser.id,
                    reason: "unsupported-future-version-\(futureSnapshot.version)"
                )
            )
        )
    }
}

@MainActor
private func makeShellViewModel(isMenuOpen: Bool = false) -> AppShellViewModel {
    AppShellViewModel(
        contentRepository: TestAppContentRepository(),
        uiConfigurationManager: UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(delayNanoseconds: 0)
        ),
        widgetContentSyncManager: NoopWidgetContentSyncManager(),
        isMenuOpen: isMenuOpen
    )
}

@MainActor
private final class TestUserSessionService: UserSessionManaging {
    private let signInResult: Result<AppUser, Error>
    private let restoreResult: Result<AppUser?, Error>

    private(set) var signOutCallCount = 0

    init(
        signInResult: Result<AppUser, Error>,
        restoreResult: Result<AppUser?, Error>
    ) {
        self.signInResult = signInResult
        self.restoreResult = restoreResult
    }

    func signIn(username: String) throws -> AppUser {
        try signInResult.get()
    }

    func restoreSession() throws -> AppUser? {
        try restoreResult.get()
    }

    func signOut() {
        signOutCallCount += 1
    }
}

private enum TestSessionError: Error {
    case signInUnavailable
}

@MainActor
private final class TestUserRepository: UserRepository {
    private let user: AppUser

    init(user: AppUser) {
        self.user = user
    }

    func findUser(username: String) throws -> AppUser? {
        user.username == username ? user : nil
    }

    func findOrCreateUser(username: String) throws -> AppUser {
        user
    }

    func updateNavigationStateRestoreEnabled(
        userID: String,
        isEnabled: Bool
    ) throws -> AppUser {
        AppUser(
            id: user.id,
            username: user.username,
            createdAt: user.createdAt,
            isNavigationStateRestoreEnabled: isEnabled
        )
    }
}

@MainActor
private final class TestNavigationStateManager: NavigationStateManaging {
    private var snapshots: [String: NavigationSnapshot] = [:]
    private(set) var clearCallCount = 0

    init(seed: [String: NavigationSnapshot] = [:]) {
        self.snapshots = seed
    }

    func saveSnapshot<Snapshot: Codable>(_ snapshot: Snapshot, for userID: String) {
        guard let typedSnapshot = snapshot as? NavigationSnapshot else {
            return
        }

        snapshots[userID] = typedSnapshot
    }

    func restoreSnapshot<Snapshot: Codable>(for userID: String, as snapshotType: Snapshot.Type) -> Snapshot? {
        guard let snapshot = snapshots[userID] else {
            return nil
        }

        return snapshot as? Snapshot
    }

    func clearSnapshot(for userID: String) {
        clearCallCount += 1
        snapshots[userID] = nil
    }

    func snapshot(for userID: String) -> NavigationSnapshot? {
        snapshots[userID]
    }
}

@MainActor
private final class TestDeepLinkManager: DeepLinkManaging {
    func handle(url: URL, coordinator: AppCoordinator) -> Bool {
        false
    }

    func handle(userActivity: NSUserActivity, coordinator: AppCoordinator) -> Bool {
        false
    }
}

@MainActor
/// Verifies generic tab router stack operations.
final class TabRouterTests: XCTestCase {
    func testPushAppendRouteToPath() {
        let router = TabRouter<NewsRoute>()

        router.push(
            NewsRoute(
                destinationID: "article-1",
                title: "Article",
                subtitle: "Subtitle",
                bodyText: "Body"
            )
        )

        XCTAssertEqual(router.path.count, 1)
    }

    func testPopRemovesLastRouteOnly() {
        let router = TabRouter<NewsRoute>()
        let firstRoute = NewsRoute(
            destinationID: "article-1",
            title: "First",
            subtitle: "Subtitle",
            bodyText: "Body"
        )
        let secondRoute = NewsRoute(
            destinationID: "article-2",
            title: "Second",
            subtitle: "Subtitle",
            bodyText: "Body"
        )

        router.replacePath(with: [firstRoute, secondRoute])
        router.pop()

        XCTAssertEqual(router.path, [firstRoute])
    }

    func testPopToRootClearsEntirePath() {
        let router = TabRouter<MixesRoute>()
        router.replacePath(
            with: [
                MixesRoute(title: "One", description: "First"),
                MixesRoute(title: "Two", description: "Second")
            ]
        )

        router.popToRoot()

        XCTAssertTrue(router.path.isEmpty)
    }
}

@MainActor
/// Verifies coordinator-level tab and stack orchestration behavior.
final class AppCoordinatorTests: XCTestCase {
    func testSelectTabDoesNotResetOtherTabPaths() {
        let coordinator = AppCoordinator()
        coordinator.newsRouter.push(
            NewsRoute(
                destinationID: "article-1",
                title: "News",
                subtitle: "Subtitle",
                bodyText: "Body"
            )
        )
        coordinator.chatRouter.push(
            ChatRoute(title: "Chat", description: "Room")
        )

        coordinator.selectTab(.chat)

        XCTAssertEqual(coordinator.selectedTab, .chat)
        XCTAssertEqual(coordinator.newsRouter.path.count, 1)
        XCTAssertEqual(coordinator.chatRouter.path.count, 1)
    }

    func testResetAllNavigationClearsEveryTabPath() {
        let coordinator = AppCoordinator(selectedTab: .profile)
        coordinator.newsRouter.push(
            NewsRoute(
                destinationID: "article-1",
                title: "News",
                subtitle: "Subtitle",
                bodyText: "Body"
            )
        )
        coordinator.mixesRouter.push(MixesRoute(title: "Mix", description: "Mix"))
        coordinator.pinnedRouter.push(PinnedRoute(title: "Pinned", description: "Pinned"))
        coordinator.chatRouter.push(ChatRoute(title: "Chat", description: "Chat"))
        coordinator.profileRouter.push(ProfileRoute(title: "Profile", description: "Profile"))

        coordinator.resetAllNavigation()

        XCTAssertTrue(coordinator.newsRouter.path.isEmpty)
        XCTAssertTrue(coordinator.mixesRouter.path.isEmpty)
        XCTAssertTrue(coordinator.pinnedRouter.path.isEmpty)
        XCTAssertTrue(coordinator.chatRouter.path.isEmpty)
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
        XCTAssertEqual(coordinator.selectedTab, .profile)
    }

    func testPushTransitionIsIdempotentForEquivalentRoute() {
        let coordinator = AppCoordinator()
        let route = ChatRoute(title: "Support", description: "Room")

        coordinator.navigateToChat(route, policy: .push)
        coordinator.navigateToChat(
            ChatRoute(title: "Support", description: "Room"),
            policy: .push
        )

        XCTAssertEqual(coordinator.chatRouter.path.count, 1)
    }

    func testReplaceTransitionIsIdempotentForEquivalentRoute() {
        let coordinator = AppCoordinator()
        coordinator.navigateToProfile(
            ProfileRoute(title: "Settings", description: "Manage"),
            policy: .replace
        )

        coordinator.navigateToProfile(
            ProfileRoute(title: "Settings", description: "Manage"),
            policy: .replace
        )

        XCTAssertEqual(coordinator.profileRouter.path.count, 1)
    }
}

@MainActor
/// Verifies deep/universal link routing into navigation destinations.
final class DeepLinkManagerTests: XCTestCase {
    func testCustomSchemeDiscussionLinkRoutesToNewsDiscussion() {
        let coordinator = AppCoordinator()
        let manager = DeepLinkManager()

        let handled = manager.handle(
            url: URL(string: "tchop://news/discussion?title=Debate&subtitle=12+joined&body=Body")!,
            coordinator: coordinator
        )

        XCTAssertTrue(handled)
        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertEqual(coordinator.newsRouter.path.first?.destinationID, "discussion-details")
        XCTAssertEqual(coordinator.newsRouter.path.first?.title, "Debate")
    }

    func testUniversalLinkRoutesToProfileDetail() {
        let coordinator = AppCoordinator()
        let manager = DeepLinkManager()

        let handled = manager.handle(
            url: URL(string: "https://example.com/profile?title=Settings&description=Manage+profile")!,
            coordinator: coordinator
        )

        XCTAssertTrue(handled)
        XCTAssertEqual(coordinator.selectedTab, .profile)
        XCTAssertEqual(coordinator.profileRouter.path.first?.title, "Settings")
    }

    func testInvalidInAppLinkFallsBackToNewsRoot() {
        let coordinator = AppCoordinator(selectedTab: .profile)
        coordinator.profileRouter.push(
            ProfileRoute(title: "Current", description: "Current profile")
        )
        let manager = DeepLinkManager()

        let handled = manager.handle(
            url: URL(string: "tchop://news/discussion?subtitle=MissingTitle")!,
            coordinator: coordinator
        )

        XCTAssertTrue(handled)
        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.newsRouter.path.isEmpty)
    }

    func testUnsupportedUniversalHostIsRejected() {
        let coordinator = AppCoordinator()
        let manager = DeepLinkManager()

        let handled = manager.handle(
            url: URL(string: "https://unknown.example.org/profile?title=Settings")!,
            coordinator: coordinator
        )

        XCTAssertFalse(handled)
        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
    }

    func testTransitionPushAddsStackEntryForDeepLink() {
        let coordinator = AppCoordinator()
        let manager = DeepLinkManager()

        _ = manager.handle(
            url: URL(string: "tchop://chat?title=Room1&description=One&transition=push")!,
            coordinator: coordinator
        )
        _ = manager.handle(
            url: URL(string: "tchop://chat?title=Room2&description=Two&transition=push")!,
            coordinator: coordinator
        )

        XCTAssertEqual(coordinator.chatRouter.path.count, 2)
    }
}
