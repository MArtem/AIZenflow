import XCTest
import TchopErrors
import TchopUIConfiguration
@testable import TchopApp

@MainActor
/// Verifies shell state, bottom chrome, and UI configuration behavior.
final class AppShellViewModelTests: XCTestCase {
    /// Verifies shell view model applies cached uiconfiguration before refresh completes.
    func testShellViewModelAppliesCachedUIConfigurationBeforeRefreshCompletes() async {
        let uiConfigurationManager = TestUIConfigurationManager(
            currentSnapshot: UIConfigurationSnapshot(
                shell: ShellUIConfiguration(showsFloatingActionButton: false)
            ),
            refreshResult: .failure(TestUIConfigurationError.refreshFailed),
            refreshDelayNanoseconds: 200_000_000
        )

        let viewModel = makeShellViewModel(uiConfigurationManager: uiConfigurationManager)

        await waitUntil(viewModel.showsFloatingActionButton == false)

        XCTAssertFalse(viewModel.showsFloatingActionButton)
    }

    /// Verifies shell view model applies refreshed uiconfiguration when fetch succeeds.
    func testShellViewModelAppliesRefreshedUIConfigurationWhenFetchSucceeds() async {
        let uiConfigurationManager = TestUIConfigurationManager(
            currentSnapshot: UIConfigurationSnapshot(
                shell: ShellUIConfiguration(showsFloatingActionButton: false)
            ),
            refreshResult: .success(
                UIConfigurationSnapshot(
                    shell: ShellUIConfiguration(showsFloatingActionButton: true)
                )
            ),
            refreshDelayNanoseconds: 0
        )

        let viewModel = makeShellViewModel(uiConfigurationManager: uiConfigurationManager)

        await waitUntil(viewModel.showsFloatingActionButton == true)

        XCTAssertTrue(viewModel.showsFloatingActionButton)
    }

    /// Verifies shell only changes the near-top flag when the feed reports a real threshold transition.
    func testSetNewsFeedNearTopUpdatesShellState() {
        let viewModel = makeShellViewModel()

        viewModel.setNewsFeedNearTop(false)
        XCTAssertFalse(viewModel.isNewsFeedNearTop)

        viewModel.setNewsFeedNearTop(true)
        XCTAssertTrue(viewModel.isNewsFeedNearTop)
    }


    /// Verifies side-menu state is controlled only by explicit shell intents.
    func testMenuToggleAndCloseUpdateShellState() {
        let viewModel = makeShellViewModel(isMenuOpen: false)

        viewModel.toggleMenu()
        XCTAssertTrue(viewModel.isMenuOpen)

        viewModel.closeMenu()
        XCTAssertFalse(viewModel.isMenuOpen)
    }

    /// Verifies presenting composer uses the currently selected channel snapshot.
    func testPresentComposerUsesSelectedChannel() {
        let channelsStore = makeTestChannelsStore(selectedChannelID: AppChannel.community.id)
        let viewModel = makeShellViewModel(channelsStore: channelsStore)

        viewModel.presentComposer()

        XCTAssertEqual(viewModel.activeComposer?.selectedChannelID, AppChannel.community.id)
        XCTAssertEqual(viewModel.activeComposer?.selectedChannelTitle, AppChannel.community.title)
    }

    /// Verifies selecting a channel updates feed scope and syncs share-extension session context.
    func testSelectChannelRefreshesFeedScopeAndShareExtensionContext() throws {
        let channelsStore = makeTestChannelsStore(selectedChannelID: AppChannel.product.id)
        let feedCardStore = makeTestFeedCardStore(cards: [
            makeTextFeedCard(id: "product-card", channelID: AppChannel.product.id, text: "Product"),
            makeTextFeedCard(id: "community-card", channelID: AppChannel.community.id, text: "Community")
        ])
        let sessionContextManager = try makeShareExtensionSessionContextManager()
        let viewModel = makeShellViewModel(
            channelsStore: channelsStore,
            feedCardStore: feedCardStore,
            shareExtensionSessionContextManager: sessionContextManager
        )

        viewModel.selectChannel(id: AppChannel.community.id)

        XCTAssertEqual(viewModel.newsFeedViewModel.visibleContent.cards.map(\.id), ["community-card"])
        let context = try XCTUnwrap(sessionContextManager.loadContext())
        XCTAssertTrue(context.isAuthenticated)
        XCTAssertEqual(context.selectedChannelID, AppChannel.community.id)
        XCTAssertEqual(context.availableChannels, AppChannel.allKnown)
    }

    /// Verifies publishing composer content updates the feed and clears the active composer presentation.
    func testPublishComposerRefreshesFeedAndDismissesComposer() throws {
        let viewModel = makeShellViewModel()
        viewModel.presentComposer()
        let composer = try XCTUnwrap(viewModel.activeComposer)
        composer.updateText("Published card", for: .text)

        XCTAssertTrue(composer.publish())
        viewModel.publishComposer()

        XCTAssertNil(viewModel.activeComposer)
        XCTAssertEqual(viewModel.newsFeedViewModel.visibleContent.cards.map(\.serviceHeadline), ["Published card"])
    }
    /// Waits until until.
    private func waitUntil(
        _ condition: @autoclosure () -> Bool,
        timeoutNanoseconds: UInt64 = 3_000_000_000
    ) async {
        let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds

        while DispatchTime.now().uptimeNanoseconds < deadline {
            if condition() {
                return
            }

            try? await Task.sleep(nanoseconds: 20_000_000)
        }

        XCTFail("Timed out waiting for condition")
    }

    /// Creates a shell view model with local feed runtime dependencies.
    private func makeShellViewModel(
        channelsStore: ChannelsStore = makeTestChannelsStore(),
        feedCardStore: FeedCardStore? = nil,
        uiConfigurationManager: any UIConfigurationManaging = TestUIConfigurationManager(
            currentSnapshot: UIConfigurationSnapshot(shell: ShellUIConfiguration(showsFloatingActionButton: true)),
            refreshResult: .success(UIConfigurationSnapshot(shell: ShellUIConfiguration(showsFloatingActionButton: true))),
            refreshDelayNanoseconds: 0
        ),
        shareExtensionSessionContextManager: ShareExtensionSessionContextManager? = nil,
        isMenuOpen: Bool = false
    ) -> AppShellViewModel {
        let resolvedFeedCardStore = feedCardStore ?? makeTestFeedCardStore()
        let newsFeedViewModel = NewsFeedViewModel(
            channelsStore: channelsStore,
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            errorManager: AppErrorManager(),
            feedCardStore: resolvedFeedCardStore
        )

        return AppShellViewModel(
            channelsStore: channelsStore,
            feedCardStore: resolvedFeedCardStore,
            newsFeedViewModel: newsFeedViewModel,
            errorManager: AppErrorManager(),
            uiConfigurationManager: uiConfigurationManager,
            shareExtensionSessionContextManager: shareExtensionSessionContextManager,
            isMenuOpen: isMenuOpen
        )
    }

    /// Creates a share-extension session context manager backed by a temporary test app-group container.
    private func makeShareExtensionSessionContextManager() throws -> ShareExtensionSessionContextManager {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        return try ShareExtensionSessionContextManager(
            groupIdentifier: "group.test.shell-session",
            fileManager: ShellTestAppGroupFileManager(containerURL: rootURL)
        )
    }
}

/// Verifies profile-tab preference state and optimistic rollback behavior.
@MainActor
final class ProfileTabViewModelTests: XCTestCase {
    /// Verifies profile view model syncs updated user snapshots into presentation state.
    func testSyncCurrentUserUpdatesAccountSummaryAndPreference() {
        let viewModel = ProfileTabViewModel(
            currentUser: AppUser(id: "user-1", username: "alice", createdAt: Date(timeIntervalSince1970: 1)),
            errorManager: AppErrorManager(),
            onNavigationRestoreChange: { _ in }
        )

        viewModel.syncCurrentUser(
            AppUser(
                id: "user-1",
                username: "alice",
                createdAt: Date(timeIntervalSince1970: 1),
                isNavigationStateRestoreEnabled: false
            )
        )

        XCTAssertEqual(viewModel.accountSummary.displayName, "alice")
        XCTAssertFalse(viewModel.isNavigationRestoreEnabled)
    }

    /// Verifies preference update success keeps optimistic state and clears stale errors.
    func testSetNavigationRestoreEnabledPersistsOptimisticStateOnSuccess() {
        var receivedValue: Bool?
        let viewModel = ProfileTabViewModel(
            currentUser: AppUser(
                id: "user-1",
                username: "alice",
                createdAt: Date(timeIntervalSince1970: 1),
                isNavigationStateRestoreEnabled: false
            ),
            errorManager: AppErrorManager(),
            onNavigationRestoreChange: { receivedValue = $0 }
        )

        viewModel.setNavigationRestoreEnabled(true)

        XCTAssertEqual(receivedValue, true)
        XCTAssertTrue(viewModel.isNavigationRestoreEnabled)
        XCTAssertNil(viewModel.errorMessage)
    }

    /// Verifies failed preference persistence rolls back optimistic state and presents an error.
    func testSetNavigationRestoreEnabledRollsBackOnFailure() async {
        let viewModel = ProfileTabViewModel(
            currentUser: AppUser(
                id: "user-1",
                username: "alice",
                createdAt: Date(timeIntervalSince1970: 1),
                isNavigationStateRestoreEnabled: false
            ),
            errorManager: ProfileTestErrorManager(),
            onNavigationRestoreChange: { _ in throw ProfileTestError.persistenceFailed }
        )

        viewModel.setNavigationRestoreEnabled(true)
        await waitUntil(viewModel.errorMessage != nil)

        XCTAssertFalse(viewModel.isNavigationRestoreEnabled)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    /// Waits until an async UI-state side effect is visible.
    private func waitUntil(
        _ condition: @autoclosure () -> Bool,
        timeoutNanoseconds: UInt64 = 3_000_000_000
    ) async {
        let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds

        while DispatchTime.now().uptimeNanoseconds < deadline {
            if condition() {
                return
            }

            try? await Task.sleep(nanoseconds: 20_000_000)
        }

        XCTFail("Timed out waiting for condition")
    }
}

private enum ProfileTestError: Error {
    case persistenceFailed
}

private struct ProfileTestErrorManager: AppErrorManaging {
    func presentableError(
        from error: Error,
        context: AppErrorContext?
    ) async -> AppErrorPresentation {
        AppErrorPresentation(
            error: AppError(
                category: .persistence,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "profile.test.error",
                debugDescription: String(describing: error),
                context: context
            ),
            userMessage: "Profile preference update failed"
        )
    }
}

private final class ShellTestAppGroupFileManager: FileManager, @unchecked Sendable {
    private let sharedContainerURL: URL

    init(containerURL: URL) {
        self.sharedContainerURL = containerURL
        super.init()
    }

    override func containerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL? {
        sharedContainerURL
    }
}
