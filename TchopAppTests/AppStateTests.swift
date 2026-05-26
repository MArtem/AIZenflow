import XCTest
import TchopAppleAuthentication
import TchopErrors
import TchopNavigation
import TchopUIConfiguration
@testable import TchopApp

/// Covers app session and navigation restore flows in root state.
@MainActor
final class AppStateTests: XCTestCase {
    /// Verifies sign in updates current user.
    func testSignInUpdatesCurrentUser() async throws {
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
            sessionStore: SessionStore(),
            channelsStore: makeTestChannelsStore(),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: expectedUser),
            channelSettingsRepository: UserChannelSettingsRepository(),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge(),
            errorManager: AppErrorManager()
        )

        try await state.signIn(username: "alice")

        XCTAssertEqual(state.currentUser, expectedUser)
    }

    /// Verifies init restores persisted session.
    func testInitRestoresPersistedSession() async {
        let restoredUser = AppUser(id: "user-2", username: "restored", createdAt: Date())
        let sessionService = TestUserSessionService(
            signInResult: .failure(TestSessionError.signInUnavailable),
            restoreResult: .success(restoredUser)
        )
        let state = AppState(
            coordinator: AppCoordinator(),
            appShellViewModel: makeShellViewModel(),
            sessionStore: SessionStore(),
            channelsStore: makeTestChannelsStore(),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            channelSettingsRepository: UserChannelSettingsRepository(),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge(),
            errorManager: AppErrorManager()
        )

        await waitForAppStateRestore(state)

        XCTAssertEqual(state.currentUser, restoredUser)
    }

    /// Verifies sign out clears user and resets shell state.
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
            sessionStore: SessionStore(),
            channelsStore: makeTestChannelsStore(),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            channelSettingsRepository: UserChannelSettingsRepository(),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge(),
            errorManager: AppErrorManager()
        )

        state.signOut()

        XCTAssertNil(state.currentUser)
        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.newsRouter.path.isEmpty)
        XCTAssertFalse(shellViewModel.isMenuOpen)
        XCTAssertEqual(sessionService.signOutCallCount, 1)
    }

    /// Verifies sign out clears widget feed state alongside the in-app session reset.
    func testSignOutClearsWidgetFeed() {
        let restoredUser = AppUser(id: "user-widget-clear", username: "signed-in", createdAt: Date())
        let widgetContentSyncManager = RecordingWidgetContentSyncManager()
        let state = AppState(
            coordinator: AppCoordinator(),
            appShellViewModel: makeShellViewModel(),
            sessionStore: SessionStore(),
            channelsStore: makeTestChannelsStore(),
            sessionService: TestUserSessionService(
                signInResult: .success(restoredUser),
                restoreResult: .success(restoredUser)
            ),
            userRepository: TestUserRepository(user: restoredUser),
            channelSettingsRepository: UserChannelSettingsRepository(),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: widgetContentSyncManager,
            pushNotificationBridge: NoopPushNotificationBridge(),
            errorManager: AppErrorManager()
        )

        state.signOut()

        XCTAssertEqual(widgetContentSyncManager.clearCallCount, 1)
    }

    /// Verifies app state forwards explicit push authorization requests into the push bridge.
    func testRequestPushNotificationAuthorizationDelegatesToPushBridge() async {
        let pushBridge = RecordingPushNotificationBridge()
        let state = AppState(
            coordinator: AppCoordinator(),
            appShellViewModel: makeShellViewModel(),
            sessionStore: SessionStore(),
            channelsStore: makeTestChannelsStore(),
            sessionService: TestUserSessionService(
                signInResult: .failure(TestSessionError.signInUnavailable),
                restoreResult: .success(nil)
            ),
            userRepository: TestUserRepository(
                user: AppUser(id: "user-push-request", username: "push-user", createdAt: Date())
            ),
            channelSettingsRepository: UserChannelSettingsRepository(),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: pushBridge,
            errorManager: AppErrorManager()
        )

        state.requestPushNotificationAuthorization()
        try? await Task.sleep(for: .milliseconds(20))

        XCTAssertEqual(pushBridge.requestAuthorizationAndRegisterCallCount, 1)
    }

    /// Verifies init restores navigation snapshot when flag enabled.
    func testInitRestoresNavigationSnapshotWhenFlagEnabled() async {
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

        let state = AppState(
            coordinator: coordinator,
            appShellViewModel: makeShellViewModel(),
            sessionStore: SessionStore(),
            channelsStore: makeTestChannelsStore(),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            channelSettingsRepository: UserChannelSettingsRepository(),
            navigationStateManager: stateManager,
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge(),
            errorManager: AppErrorManager()
        )

        await waitForAppStateRestore(state)

        XCTAssertEqual(coordinator.selectedTab, .chat)
        XCTAssertEqual(coordinator.chatRouter.path.count, 1)
    }

    /// Verifies init does not restore snapshot when flag disabled.
    func testInitDoesNotRestoreSnapshotWhenFlagDisabled() async {
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

        let state = AppState(
            coordinator: coordinator,
            appShellViewModel: makeShellViewModel(),
            sessionStore: SessionStore(),
            channelsStore: makeTestChannelsStore(),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            channelSettingsRepository: UserChannelSettingsRepository(),
            navigationStateManager: stateManager,
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge(),
            errorManager: AppErrorManager()
        )

        await waitForAppStateRestore(state)

        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
    }

    /// Verifies sign in prioritizes pending deep link over snapshot restore.
    func testSignInPrioritizesPendingDeepLinkOverSnapshotRestore() async throws {
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
            sessionStore: SessionStore(),
            channelsStore: makeTestChannelsStore(),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: signedInUser),
            channelSettingsRepository: UserChannelSettingsRepository(),
            navigationStateManager: stateManager,
            deepLinkManager: DeepLinkManager(),
            navigationEventReporter: NavigationNoopEventReporter(),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge(),
            errorManager: AppErrorManager()
        )

        XCTAssertTrue(state.handleIncomingURL(URL(string: "tchop://chat?title=Support&description=Urgent")!))

        try await state.signIn(username: signedInUser.username)

        XCTAssertEqual(coordinator.selectedTab, .chat)
        XCTAssertEqual(coordinator.chatRouter.path.first?.title, "Support")
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
    }


    /// Verifies unauthenticated deep links are queued and replayed after successful sign-in.
    func testUnauthenticatedDeepLinkQueuesAndReplaysAfterSignIn() async throws {
        let signedInUser = AppUser(id: "user-pending-link", username: "pending", createdAt: Date())
        let deepLinkManager = RecordingDeepLinkManager()
        let state = makeAppState(
            user: signedInUser,
            sessionService: TestUserSessionService(
                signInResult: .success(signedInUser),
                restoreResult: .success(nil)
            ),
            deepLinkManager: deepLinkManager
        )
        let url = URL(string: "tchop://chat?title=Support")!

        XCTAssertTrue(state.handleIncomingURL(url))
        XCTAssertTrue(deepLinkManager.handledURLs.isEmpty)

        try await state.signIn(username: signedInUser.username)

        XCTAssertEqual(deepLinkManager.handledURLs, [url])
        XCTAssertEqual(state.currentUser, signedInUser)
    }

    /// Verifies only the latest unauthenticated deep link is kept before sign-in.
    func testUnauthenticatedDeepLinkKeepsLatestPendingInputOnly() async throws {
        let signedInUser = AppUser(id: "user-latest-link", username: "latest", createdAt: Date())
        let deepLinkManager = RecordingDeepLinkManager()
        let state = makeAppState(
            user: signedInUser,
            sessionService: TestUserSessionService(
                signInResult: .success(signedInUser),
                restoreResult: .success(nil)
            ),
            deepLinkManager: deepLinkManager
        )
        let firstURL = URL(string: "tchop://chat?title=First")!
        let secondURL = URL(string: "tchop://profile?title=Second")!

        XCTAssertTrue(state.handleIncomingURL(firstURL))
        XCTAssertTrue(state.handleIncomingURL(secondURL))
        try await state.signIn(username: signedInUser.username)

        XCTAssertEqual(deepLinkManager.handledURLs, [secondURL])
    }

    /// Verifies authenticated deep links resolve immediately instead of being queued.
    func testAuthenticatedDeepLinkResolvesImmediately() async throws {
        let signedInUser = AppUser(id: "user-auth-link", username: "auth-link", createdAt: Date())
        let deepLinkManager = RecordingDeepLinkManager()
        let state = makeAppState(
            user: signedInUser,
            sessionService: TestUserSessionService(
                signInResult: .success(signedInUser),
                restoreResult: .success(nil)
            ),
            deepLinkManager: deepLinkManager
        )
        try await state.signIn(username: signedInUser.username)
        let url = URL(string: "tchop://chat?title=Live")!

        XCTAssertTrue(state.handleIncomingURL(url))

        XCTAssertEqual(deepLinkManager.handledURLs, [url])
    }

    /// Verifies failed sign-in leaves session signed out and does not replay queued deep links.
    func testFailedSignInDoesNotReplayPendingDeepLink() async {
        let user = AppUser(id: "user-failed-link", username: "failed", createdAt: Date())
        let deepLinkManager = RecordingDeepLinkManager()
        let state = makeAppState(
            user: user,
            sessionService: TestUserSessionService(
                signInResult: .failure(TestSessionError.signInUnavailable),
                restoreResult: .success(nil)
            ),
            deepLinkManager: deepLinkManager
        )

        XCTAssertTrue(state.handleIncomingURL(URL(string: "tchop://chat?title=Queued")!))
        do {
            try await state.signIn(username: user.username)
            XCTFail("Expected sign-in to fail")
        } catch {
            XCTAssertNil(state.currentUser)
        }

        XCTAssertTrue(deepLinkManager.handledURLs.isEmpty)
    }

    /// Verifies restore failures fall back to signed-out root state.
    func testRestoreFailureFallsBackToSignedOutState() async {
        let user = AppUser(id: "user-restore-failure", username: "restore-failure", createdAt: Date())
        let state = makeAppState(
            user: user,
            sessionService: TestUserSessionService(
                signInResult: .success(user),
                restoreResult: .failure(TestSessionError.signInUnavailable)
            )
        )

        await waitForSignedOutState(state)

        XCTAssertEqual(state.sessionState, .signedOut)
        XCTAssertNil(state.currentUser)
    }

    /// Verifies opted-in users persist navigation snapshots after authenticated navigation changes.
    func testAuthenticatedNavigationChangePersistsSnapshotWhenRestoreEnabled() async throws {
        let signedInUser = AppUser(
            id: "user-nav-persist",
            username: "nav-persist",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: true
        )
        let stateManager = TestNavigationStateManager()
        let coordinator = AppCoordinator()
        let state = makeAppState(
            coordinator: coordinator,
            user: signedInUser,
            sessionService: TestUserSessionService(
                signInResult: .success(signedInUser),
                restoreResult: .success(nil)
            ),
            navigationStateManager: stateManager
        )

        try await state.signIn(username: signedInUser.username)
        coordinator.selectTab(.profile)

        XCTAssertEqual(stateManager.snapshot(for: signedInUser.id)?.selectedTab, .profile)
        XCTAssertGreaterThanOrEqual(stateManager.saveCallCount, 1)
    }

    /// Verifies clean snapshot restore does not immediately re-save from the coordinator callback.
    func testCleanSnapshotRestoreDoesNotCreatePersistenceFeedbackLoop() async {
        let restoredUser = AppUser(
            id: "user-clean-snapshot",
            username: "clean-snapshot",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: true
        )
        let snapshot = NavigationSnapshot(
            selectedTab: .profile,
            newsPath: [],
            mixesPath: [],
            pinnedPath: [],
            chatPath: [],
            profilePath: [ProfileRoute(title: "Profile", description: "Clean")]
        )
        let stateManager = TestNavigationStateManager(seed: [restoredUser.id: snapshot])
        let coordinator = AppCoordinator()
        let state = makeAppState(
            coordinator: coordinator,
            user: restoredUser,
            sessionService: TestUserSessionService(
                signInResult: .success(restoredUser),
                restoreResult: .success(restoredUser)
            ),
            navigationStateManager: stateManager
        )

        await waitForAppStateRestore(state)

        XCTAssertEqual(coordinator.selectedTab, .profile)
        XCTAssertEqual(coordinator.profileRouter.path.count, 1)
        XCTAssertEqual(stateManager.saveCallCount, 0)
    }

    /// Verifies disabling restore clears persisted snapshot and resets navigation immediately.
    func testSetNavigationRestoreDisabledClearsSnapshotAndResetsNavigation() async throws {
        let signedInUser = AppUser(
            id: "user-disable-restore",
            username: "disable-restore",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: true
        )
        let snapshot = NavigationSnapshot(
            selectedTab: .profile,
            newsPath: [],
            mixesPath: [],
            pinnedPath: [],
            chatPath: [],
            profilePath: [ProfileRoute(title: "Profile", description: "Saved")]
        )
        let stateManager = TestNavigationStateManager(seed: [signedInUser.id: snapshot])
        let coordinator = AppCoordinator(selectedTab: .profile)
        coordinator.profileRouter.push(ProfileRoute(title: "Current", description: "Current"))
        let state = makeAppState(
            coordinator: coordinator,
            user: signedInUser,
            sessionService: TestUserSessionService(
                signInResult: .success(signedInUser),
                restoreResult: .success(nil)
            ),
            navigationStateManager: stateManager
        )
        try await state.signIn(username: signedInUser.username)

        try state.setNavigationRestoreEnabled(false)

        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
        XCTAssertNil(stateManager.snapshot(for: signedInUser.id))
        XCTAssertEqual(stateManager.clearCallCount, 1)
    }

    /// Verifies init migrates and sanitizes snapshot before apply.
    func testInitMigratesAndSanitizesSnapshotBeforeApply() async {
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

        let state = AppState(
            coordinator: AppCoordinator(),
            appShellViewModel: makeShellViewModel(),
            sessionStore: SessionStore(),
            channelsStore: makeTestChannelsStore(),
            sessionService: TestUserSessionService(
                signInResult: .success(restoredUser),
                restoreResult: .success(restoredUser)
            ),
            userRepository: TestUserRepository(user: restoredUser),
            channelSettingsRepository: UserChannelSettingsRepository(),
            navigationStateManager: stateManager,
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: reporter,
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge(),
            errorManager: AppErrorManager()
        )

        await waitForAppStateRestore(state)

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

    /// Verifies init drops future snapshot version and resets navigation safely.
    func testInitDropsFutureSnapshotVersionAndResetsNavigationSafely() async {
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

        let state = AppState(
            coordinator: coordinator,
            appShellViewModel: makeShellViewModel(),
            sessionStore: SessionStore(),
            channelsStore: makeTestChannelsStore(),
            sessionService: TestUserSessionService(
                signInResult: .success(restoredUser),
                restoreResult: .success(restoredUser)
            ),
            userRepository: TestUserRepository(user: restoredUser),
            channelSettingsRepository: UserChannelSettingsRepository(),
            navigationStateManager: stateManager,
            deepLinkManager: TestDeepLinkManager(),
            navigationEventReporter: reporter,
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            pushNotificationBridge: NoopPushNotificationBridge(),
            errorManager: AppErrorManager()
        )

        await waitForAppStateRestore(state)

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
private func waitForAppStateRestore(_ state: AppState) async {
    for _ in 0..<50 {
        await Task.yield()
        if state.currentUser != nil {
            try? await Task.sleep(for: .milliseconds(100))
            return
        }
        try? await Task.sleep(for: .milliseconds(20))
    }
}


@MainActor
private func waitForSignedOutState(_ state: AppState) async {
    for _ in 0..<50 {
        await Task.yield()
        if state.sessionState == .signedOut {
            return
        }
        try? await Task.sleep(for: .milliseconds(20))
    }
}

@MainActor
private func makeAppState(
    coordinator: AppCoordinator = AppCoordinator(),
    shellViewModel: AppShellViewModel = makeShellViewModel(),
    sessionStore: SessionStore = SessionStore(),
    channelsStore: ChannelsStore = makeTestChannelsStore(),
    user: AppUser,
    sessionService: TestUserSessionService,
    navigationStateManager: TestNavigationStateManager = TestNavigationStateManager(),
    deepLinkManager: any DeepLinkManaging = TestDeepLinkManager(),
    widgetContentSyncManager: any WidgetContentSyncing = NoopWidgetContentSyncManager(),
    pushNotificationBridge: any AppPushNotificationBridging = NoopPushNotificationBridge(),
    errorManager: any AppErrorManaging = AppErrorManager()
) -> AppState {
    AppState(
        coordinator: coordinator,
        appShellViewModel: shellViewModel,
        sessionStore: sessionStore,
        channelsStore: channelsStore,
        sessionService: sessionService,
        userRepository: TestUserRepository(user: user),
        channelSettingsRepository: UserChannelSettingsRepository(),
        navigationStateManager: navigationStateManager,
        deepLinkManager: deepLinkManager,
        navigationEventReporter: NavigationNoopEventReporter(),
        widgetContentSyncManager: widgetContentSyncManager,
        pushNotificationBridge: pushNotificationBridge,
        errorManager: errorManager
    )
}

@MainActor
/// Creates shell view model.
private func makeShellViewModel(isMenuOpen: Bool = false) -> AppShellViewModel {
    let channelsStore = makeTestChannelsStore()
    let feedCardStore = makeTestFeedCardStore()
    let newsFeedViewModel = NewsFeedViewModel(
        channelsStore: channelsStore,
        widgetContentSyncManager: NoopWidgetContentSyncManager(),
        errorManager: AppErrorManager(),
        feedCardStore: feedCardStore
    )

    return AppShellViewModel(
        channelsStore: channelsStore,
        feedCardStore: feedCardStore,
        newsFeedViewModel: newsFeedViewModel,
        errorManager: AppErrorManager(),
        uiConfigurationManager: UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(delayNanoseconds: 0)
        ),
        isMenuOpen: isMenuOpen
    )
}

@MainActor
/// Verifies generic tab router stack operations.
final class TabRouterTests: XCTestCase {
    /// Verifies push append route to path.
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

    /// Verifies pop removes last route only.
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

    /// Verifies pop to root clears entire path.
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
    /// Verifies select tab does not reset other tab paths.
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

    /// Verifies show tab root selects tab and clears only that tab path.
    func testShowTabRootSelectsTabAndClearsOnlyThatTabPath() {
        let coordinator = AppCoordinator(selectedTab: .profile)
        coordinator.newsRouter.push(
            NewsRoute(
                destinationID: "article-1",
                title: "News",
                subtitle: "Subtitle",
                bodyText: "Body"
            )
        )
        coordinator.profileRouter.push(
            ProfileRoute(title: "Profile", description: "Current profile")
        )

        coordinator.showTabRoot(.profile)

        XCTAssertEqual(coordinator.selectedTab, .profile)
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
        XCTAssertEqual(coordinator.newsRouter.path.count, 1)
    }

    /// Verifies reset all navigation clears every tab path.
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

    /// Verifies push transition is idempotent for equivalent route.
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

    /// Verifies replace transition is idempotent for equivalent route.
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

    /// Verifies navigation change callback emits for selected tab and path changes.
    func testNavigationChangeCallbackEmitsForSelectedTabAndPathChanges() {
        let coordinator = AppCoordinator()
        var emissionCount = 0
        coordinator.onNavigationChange = {
            emissionCount += 1
        }

        coordinator.selectTab(.chat)
        coordinator.chatRouter.push(ChatRoute(title: "Support", description: "Room"))

        XCTAssertGreaterThanOrEqual(emissionCount, 2)
    }
}

@MainActor
/// Verifies deep/universal link routing into navigation destinations.
final class DeepLinkManagerTests: XCTestCase {
    /// Verifies custom scheme photo link routes to news photo.
    func testCustomSchemePhotoLinkRoutesToNewsPhoto() {
        let coordinator = AppCoordinator()
        let manager = DeepLinkManager()

        let handled = manager.handle(
            url: URL(string: "tchop://news/photo?title=Debate&subtitle=12+joined&body=Body")!,
            coordinator: coordinator
        )

        XCTAssertTrue(handled)
        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertEqual(coordinator.newsRouter.path.first?.destinationID, "photo-details")
        XCTAssertEqual(coordinator.newsRouter.path.first?.title, "Debate")
    }

    /// Verifies universal link routes to profile detail.
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

    /// Verifies invalid in app link falls back to news root.
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

    /// Verifies unsupported universal host is rejected.
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

    /// Verifies transition push adds stack entry for deep link.
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

    /// Verifies tab root deep link resets existing tab stack.
    func testTabRootDeepLinkResetsExistingTabStack() {
        let coordinator = AppCoordinator(selectedTab: .profile)
        coordinator.profileRouter.push(
            ProfileRoute(title: "Current", description: "Current profile")
        )
        let manager = DeepLinkManager()

        let handled = manager.handle(
            url: URL(string: "https://example.com/profile")!,
            coordinator: coordinator
        )

        XCTAssertTrue(handled)
        XCTAssertEqual(coordinator.selectedTab, .profile)
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
    }
}

/// Verifies launch-time environment parsing stays centralized and deterministic.
@MainActor
final class AppLaunchConfigurationTests: XCTestCase {
    /// Verifies UI-test launches use in-memory SwiftData storage.
    func testUITestLaunchUsesInMemorySwiftDataConfiguration() {
        let configuration = AppLaunchConfiguration(environment: [
            "TCHOP_UI_TEST_MODE": "1",
            "TCHOP_DATABASE_BACKEND": "coreData"
        ])

        XCTAssertTrue(configuration.isUITesting)
        XCTAssertEqual(configuration.databaseConfiguration.backendSelectionPolicy, .swiftData)
        XCTAssertTrue(configuration.databaseConfiguration.isStoredInMemoryOnly)
    }

    /// Verifies external auth launch environment resolves ReqRes login mode and headers.
    func testReqResEnvironmentResolvesExternalAuthConfiguration() throws {
        let configuration = AppLaunchConfiguration(environment: [
            "TCHOP_API_ENV": "reqres_demo_auth",
            "TCHOP_REQRES_API_KEY": "test-api-key",
            "TCHOP_NETWORK_LOGGING": "1",
            "TCHOP_UI_TEST_INITIAL_URL": "tchop://profile"
        ])

        XCTAssertEqual(configuration.initialURL, URL(string: "tchop://profile"))
        XCTAssertEqual(configuration.apiEnvironment.kind, .developmentExternalAuth)
        XCTAssertEqual(configuration.apiEnvironment.loginScreenMode, .reqResDemoExternalAuth)
        XCTAssertTrue(configuration.apiEnvironment.enablesNetworkLogging)
        XCTAssertEqual(configuration.apiEnvironment.authenticationAPIConfiguration.defaultHeaders["x-api-key"], "test-api-key")
    }
}

/// Verifies the explicit root session store transitions used by app root composition.
@MainActor
final class SessionStoreTests: XCTestCase {
    /// Verifies session store exposes authenticated user only for authenticated state.
    func testSessionStoreTransitionsExposeCurrentUserOnlyWhenAuthenticated() {
        let store = SessionStore()
        let user = AppUser(id: "user-1", username: "alice", createdAt: Date(timeIntervalSince1970: 1))

        store.setSignedOut()
        XCTAssertEqual(store.sessionState, .signedOut)
        XCTAssertNil(store.currentUser)

        store.setAuthenticatedUser(user)
        XCTAssertEqual(store.currentUser, user)

        store.setRestoring()
        XCTAssertEqual(store.sessionState, .restoring)
        XCTAssertNil(store.currentUser)
    }
}

@MainActor
final class ChannelsStoreTests: XCTestCase {
    /// Verifies available channels are normalized into the product-defined order before selection.
    func testSetAvailableChannelsSortsKnownChannelsBeforeCustomChannels() {
        let store = makeChannelsStore()
        let customChannel = AppChannel(id: "z-custom", title: "Custom", subtitle: "Custom subtitle")

        store.setAvailableChannels([
            customChannel,
            .leadership,
            .community,
            .product
        ])

        XCTAssertEqual(
            store.channels.map(\.id),
            [
                AppChannel.product.id,
                AppChannel.community.id,
                AppChannel.leadership.id,
                customChannel.id
            ]
        )
        XCTAssertEqual(store.selectedChannelID, AppChannel.product.id)
    }

    /// Verifies activation prefers a valid persisted channel over the backend-preselected channel.
    func testActivateUsesPersistedSelectionBeforePreferredSelection() {
        let suiteName = "ChannelsStoreTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let selectionStore = UserDefaultsChannelSelectionStore(userDefaults: userDefaults)
        selectionStore.saveSelectedChannelID(AppChannel.community.id, for: "user-1")

        let store = ChannelsStore(selectionStore: selectionStore)
        store.setAvailableChannels([.product, .community, .leadership])

        let didChange = store.activate(
            for: "user-1",
            preferredSelectedChannelID: AppChannel.product.id
        )

        XCTAssertTrue(didChange)
        XCTAssertEqual(store.selectedChannelID, AppChannel.community.id)
    }

    /// Verifies invalid persisted and preferred channels fall back to the first available channel.
    func testActivateFallsBackToFirstAvailableChannelWhenStoredInputsAreInvalid() {
        let suiteName = "ChannelsStoreTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let selectionStore = UserDefaultsChannelSelectionStore(userDefaults: userDefaults)
        selectionStore.saveSelectedChannelID("missing-channel", for: "user-1")

        let store = ChannelsStore(selectionStore: selectionStore)
        store.setAvailableChannels([.community, .leadership])

        _ = store.activate(
            for: "user-1",
            preferredSelectedChannelID: "also-missing"
        )

        XCTAssertEqual(store.selectedChannelID, AppChannel.community.id)
        XCTAssertEqual(selectionStore.loadSelectedChannelID(for: "user-1"), AppChannel.community.id)
    }

    /// Verifies user-driven selection rejects unknown channels without corrupting the previous selection.
    func testSelectChannelRejectsUnknownIdentifierAndKeepsExistingSelection() {
        let store = makeChannelsStore()
        store.setAvailableChannels([.product, .community])
        _ = store.activate(for: "user-1", preferredSelectedChannelID: AppChannel.product.id)

        let didChange = store.selectChannel(id: "unknown")

        XCTAssertFalse(didChange)
        XCTAssertEqual(store.selectedChannelID, AppChannel.product.id)
    }

    /// Verifies resetting the store clears user-scoped selection context without destroying available channels.
    func testResetClearsUserAndSelectionButKeepsAvailableChannelsSnapshot() {
        let store = makeChannelsStore()
        store.setAvailableChannels([.product, .community])
        _ = store.activate(for: "user-1", preferredSelectedChannelID: AppChannel.community.id)

        store.reset()

        XCTAssertNil(store.selectionSnapshot.userID)
        XCTAssertNil(store.selectedChannelID)
        XCTAssertEqual(store.channels.map(\.id), [AppChannel.product.id, AppChannel.community.id])
    }

    private func makeChannelsStore() -> ChannelsStore {
        let suiteName = "ChannelsStoreTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        return ChannelsStore(
            selectionStore: UserDefaultsChannelSelectionStore(
                userDefaults: userDefaults,
                keyPrefix: suiteName
            )
        )
    }
}

@MainActor
final class UserChannelSettingsRepositoryTests: XCTestCase {
    /// Verifies known ReqRes users resolve their product-defined default channel settings.
    func testKnownReqResUsersResolveExpectedPreselectedChannels() throws {
        let repository = UserChannelSettingsRepository()

        let eveSettings = try repository.loadChannelSettings(
            for: AppUser(id: "eve", username: "  EVE.HOLT@REQRES.IN  ", createdAt: Date())
        )
        let janetSettings = try repository.loadChannelSettings(
            for: AppUser(id: "janet", username: "janet.weaver@reqres.in", createdAt: Date())
        )

        XCTAssertEqual(eveSettings.preselectedChannelID, AppChannel.product.id)
        XCTAssertEqual(janetSettings.preselectedChannelID, AppChannel.community.id)
        XCTAssertEqual(eveSettings.availableChannels.map(\.id), AppChannel.allKnown.map(\.id))
        XCTAssertEqual(
            janetSettings.availableChannels.map(\.id),
            [
                AppChannel.community.id,
                AppChannel.product.id,
                AppChannel.leadership.id
            ]
        )
    }

    /// Verifies unknown users receive the canonical default channel configuration.
    func testUnknownUserReceivesDefaultChannelSettings() throws {
        let repository = UserChannelSettingsRepository()

        let settings = try repository.loadChannelSettings(
            for: AppUser(id: "unknown", username: "unknown@example.com", createdAt: Date())
        )

        XCTAssertEqual(settings.preselectedChannelID, AppChannel.defaultChannel.id)
        XCTAssertEqual(settings.availableChannels.map(\.id), AppChannel.allKnown.map(\.id))
    }
}

@MainActor
final class UserSessionServiceTests: XCTestCase {
    /// Verifies token-backed email sign-in persists secure credentials before marking the local session active.
    func testTokenBackedEmailSignInPersistsTokenAndRestoresUser() async throws {
        let user = AppUser(id: "user-token-login", username: "alice@example.com", createdAt: Date())
        let tokenStore = RecordingAuthTokenStore()
        let authManager = RecordingAuthenticationAPIManager(
            signInEmailToken: makeToken(accessToken: "access-1", refreshToken: "refresh-1")
        )
        let service = makeSessionService(
            user: user,
            tokenStore: tokenStore,
            authenticationAPIManager: authManager
        )

        let signedInUser = try await service.signIn(email: user.username, password: "Password1")
        let restoredUser = try service.restoreSession()

        XCTAssertEqual(signedInUser, user)
        XCTAssertEqual(restoredUser, user)
        XCTAssertEqual(tokenStore.savedTokenSets.last?.accessToken, "access-1")
        XCTAssertEqual(authManager.signInEmailRequests.first?.email, user.username)
    }

    /// Verifies token-backed sign-in rolls back secure credentials when local user persistence fails.
    func testTokenBackedSignInClearsTokenWhenLocalUserResolutionFails() async {
        let tokenStore = RecordingAuthTokenStore()
        let authManager = RecordingAuthenticationAPIManager(
            signInEmailToken: makeToken(accessToken: "access-rollback", refreshToken: "refresh-rollback")
        )
        let service = makeSessionService(
            userRepository: ThrowingUserRepository(),
            tokenStore: tokenStore,
            authenticationAPIManager: authManager
        )

        do {
            _ = try await service.signIn(email: "broken@example.com", password: "Password1")
            XCTFail("Expected token-backed sign-in to fail when user persistence fails")
        } catch {
            XCTAssertNil(try? tokenStore.loadTokenSet())
            XCTAssertEqual(tokenStore.clearCallCount, 1)
        }
    }

    /// Verifies restore clears orphaned secure credentials when no local app user session exists.
    func testRestoreAuthenticatedSessionClearsTokenWhenNoLocalUserIsPersisted() async throws {
        let tokenStore = RecordingAuthTokenStore(initialTokenSet: makeToken(accessToken: "orphan"))
        let service = makeSessionService(tokenStore: tokenStore)

        let restoredUser = try await service.restoreAuthenticatedSession()

        XCTAssertNil(restoredUser)
        XCTAssertNil(try tokenStore.loadTokenSet())
        XCTAssertEqual(tokenStore.clearCallCount, 1)
    }

    /// Verifies expired access tokens are refreshed during authenticated session restore.
    func testRestoreAuthenticatedSessionRefreshesExpiredAccessToken() async throws {
        let user = AppUser(id: "user-refresh", username: "refresh@example.com", createdAt: Date())
        let expiredToken = makeToken(
            accessToken: "expired-access",
            refreshToken: "refresh-token",
            expiresAt: Date(timeIntervalSinceNow: -60)
        )
        let refreshedToken = makeToken(
            accessToken: "fresh-access",
            refreshToken: "fresh-refresh",
            expiresAt: Date(timeIntervalSinceNow: 3600)
        )
        let tokenStore = RecordingAuthTokenStore(initialTokenSet: expiredToken)
        let authManager = RecordingAuthenticationAPIManager(refreshTokenResult: .success(refreshedToken))
        let service = makeSessionService(
            user: user,
            tokenStore: tokenStore,
            authenticationAPIManager: authManager
        )
        _ = try await service.signIn(username: user.username)
        try tokenStore.saveTokenSet(expiredToken)

        let restoredUser = try await service.restoreAuthenticatedSession()

        XCTAssertEqual(restoredUser, user)
        XCTAssertEqual(authManager.refreshTokenRequests, ["refresh-token"])
        XCTAssertEqual(try tokenStore.loadTokenSet(), refreshedToken)
    }

    /// Verifies expired token restore clears persisted state when no refresh token is available.
    func testRestoreAuthenticatedSessionClearsSessionWhenRefreshTokenIsMissing() async throws {
        let user = AppUser(id: "user-missing-refresh", username: "missing-refresh@example.com", createdAt: Date())
        let tokenStore = RecordingAuthTokenStore(
            initialTokenSet: makeToken(
                accessToken: "expired-access",
                refreshToken: "",
                expiresAt: Date(timeIntervalSinceNow: -60)
            )
        )
        let service = makeSessionService(user: user, tokenStore: tokenStore)
        _ = try await service.signIn(username: user.username)
        try tokenStore.saveTokenSet(
            makeToken(
                accessToken: "expired-access",
                refreshToken: "",
                expiresAt: Date(timeIntervalSinceNow: -60)
            )
        )

        let restoredUser = try await service.restoreAuthenticatedSession()

        XCTAssertNil(restoredUser)
        XCTAssertNil(try service.restoreSession())
        XCTAssertNil(try tokenStore.loadTokenSet())
    }

    /// Verifies sign out clears local and secure session state and attempts backend revocation with the old token.
    func testSignOutClearsSessionAndRequestsBackendRevocation() async throws {
        let user = AppUser(id: "user-signout", username: "signout@example.com", createdAt: Date())
        let tokenStore = RecordingAuthTokenStore(
            initialTokenSet: makeToken(accessToken: "access-to-revoke", refreshToken: "refresh")
        )
        let authManager = RecordingAuthenticationAPIManager()
        let service = makeSessionService(
            user: user,
            tokenStore: tokenStore,
            authenticationAPIManager: authManager
        )
        _ = try await service.signIn(username: user.username)
        try tokenStore.saveTokenSet(makeToken(accessToken: "access-to-revoke", refreshToken: "refresh"))

        service.signOut()
        await waitForCondition { authManager.revokeSessionRequests.count == 1 }

        XCTAssertNil(try service.restoreSession())
        XCTAssertNil(try tokenStore.loadTokenSet())
        XCTAssertEqual(authManager.revokeSessionRequests, ["access-to-revoke"])
    }

    private func makeSessionService(
        user: AppUser = AppUser(id: "user-default", username: "default@example.com", createdAt: Date()),
        userRepository: (any UserRepository)? = nil,
        tokenStore: (any AuthTokenStoring)? = nil,
        authenticationAPIManager: (any AuthenticationAPIManaging)? = nil
    ) -> UserSessionService {
        let suiteName = "UserSessionServiceTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        return UserSessionService(
            userRepository: userRepository ?? TestUserRepository(user: user),
            userDefaults: userDefaults,
            tokenStore: tokenStore,
            authenticationAPIManager: authenticationAPIManager
        )
    }

    private func makeToken(
        accessToken: String = "access",
        refreshToken: String = "refresh",
        expiresAt: Date = Date(timeIntervalSinceNow: 3600)
    ) -> AuthTokenSet {
        AuthTokenSet(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }

    private func waitForCondition(_ condition: @MainActor () -> Bool) async {
        for _ in 0..<200 {
            if condition() {
                return
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
    }
}

private final class RecordingAuthTokenStore: AuthTokenStoring, @unchecked Sendable {
    private var tokenSet: AuthTokenSet?
    private(set) var savedTokenSets: [AuthTokenSet] = []
    private(set) var clearCallCount = 0

    init(initialTokenSet: AuthTokenSet? = nil) {
        self.tokenSet = initialTokenSet
    }

    func loadTokenSet() throws -> AuthTokenSet? {
        tokenSet
    }

    func saveTokenSet(_ tokenSet: AuthTokenSet) throws {
        self.tokenSet = tokenSet
        savedTokenSets.append(tokenSet)
    }

    func clearTokenSet() throws {
        tokenSet = nil
        clearCallCount += 1
    }
}

private final class RecordingAuthenticationAPIManager: AuthenticationAPIManaging, @unchecked Sendable {
    private let signInUsernameToken: AuthTokenSet
    private let signInEmailToken: AuthTokenSet
    private let registerToken: AuthTokenSet
    private let appleToken: AuthTokenSet
    private let refreshTokenResult: Result<AuthTokenSet, Error>

    private(set) var signInUsernameRequests: [String] = []
    private(set) var signInEmailRequests: [(email: String, password: String)] = []
    private(set) var registerRequests: [(email: String, password: String)] = []
    private(set) var appleRequests: [AppleAuthenticationIdentity] = []
    private(set) var refreshTokenRequests: [String] = []
    private(set) var revokeSessionRequests: [String?] = []

    init(
        signInUsernameToken: AuthTokenSet = AuthTokenSet(
            accessToken: "username-access",
            refreshToken: "username-refresh",
            expiresAt: Date(timeIntervalSinceNow: 3600)
        ),
        signInEmailToken: AuthTokenSet = AuthTokenSet(
            accessToken: "email-access",
            refreshToken: "email-refresh",
            expiresAt: Date(timeIntervalSinceNow: 3600)
        ),
        registerToken: AuthTokenSet = AuthTokenSet(
            accessToken: "register-access",
            refreshToken: "register-refresh",
            expiresAt: Date(timeIntervalSinceNow: 3600)
        ),
        appleToken: AuthTokenSet = AuthTokenSet(
            accessToken: "apple-access",
            refreshToken: "apple-refresh",
            expiresAt: Date(timeIntervalSinceNow: 3600)
        ),
        refreshTokenResult: Result<AuthTokenSet, Error> = .success(
            AuthTokenSet(
                accessToken: "refreshed-access",
                refreshToken: "refreshed-refresh",
                expiresAt: Date(timeIntervalSinceNow: 3600)
            )
        )
    ) {
        self.signInUsernameToken = signInUsernameToken
        self.signInEmailToken = signInEmailToken
        self.registerToken = registerToken
        self.appleToken = appleToken
        self.refreshTokenResult = refreshTokenResult
    }

    func signIn(username: String) async throws -> AuthTokenSet {
        signInUsernameRequests.append(username)
        return signInUsernameToken
    }

    func signIn(email: String, password: String) async throws -> AuthTokenSet {
        signInEmailRequests.append((email, password))
        return signInEmailToken
    }

    func register(email: String, password: String) async throws -> AuthTokenSet {
        registerRequests.append((email, password))
        return registerToken
    }

    func signInWithApple(identity: AppleAuthenticationIdentity) async throws -> AuthTokenSet {
        appleRequests.append(identity)
        return appleToken
    }

    func refreshToken(using refreshToken: String) async throws -> AuthTokenSet {
        refreshTokenRequests.append(refreshToken)
        return try refreshTokenResult.get()
    }

    func revokeSession(accessToken: String?) async throws {
        revokeSessionRequests.append(accessToken)
    }
}

private struct ThrowingUserRepository: UserRepository {
    func findUser(id: String) throws -> AppUser? {
        nil
    }

    func findUser(username: String) throws -> AppUser? {
        nil
    }

    func findOrCreateUser(username: String) throws -> AppUser {
        throw TestSessionError.signInUnavailable
    }

    func updateNavigationStateRestoreEnabled(userID: String, isEnabled: Bool) throws -> AppUser {
        throw TestSessionError.signInUnavailable
    }

    func findOrCreateAppleUser(appleUserID: String, preferredUsername: String?) throws -> AppUser {
        throw TestSessionError.signInUnavailable
    }
}
