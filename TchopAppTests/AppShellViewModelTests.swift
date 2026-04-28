import XCTest
import TchopErrors
import TchopUIConfiguration
@testable import TchopApp

@MainActor
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

        let viewModel = AppShellViewModel(
            channelInfo: ChannelHeaderInfo(title: "Tchop", subtitle: "New channel name"),
            newsFeedViewModel: makeTestNewsFeedViewModel(),
            errorManager: AppErrorManager(),
            uiConfigurationManager: uiConfigurationManager,
        )

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

        let viewModel = AppShellViewModel(
            channelInfo: ChannelHeaderInfo(title: "Tchop", subtitle: "New channel name"),
            newsFeedViewModel: makeTestNewsFeedViewModel(),
            errorManager: AppErrorManager(),
            uiConfigurationManager: uiConfigurationManager,
        )

        await waitUntil(viewModel.showsFloatingActionButton == true)

        XCTAssertTrue(viewModel.showsFloatingActionButton)
    }

    /// Waits until until.
    private func waitUntil(
        _ condition: @autoclosure () -> Bool,
        timeoutNanoseconds: UInt64 = 1_000_000_000
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

    /// Creates a lightweight feed view model for shell tests.
    private func makeTestNewsFeedViewModel() -> NewsFeedViewModel {
        NewsFeedViewModel(
            repository: TestNewsFeedRepository(result: .success(NewsFeedContent(cards: [], availability: .live))),
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            errorManager: AppErrorManager(),
            initialContent: NewsFeedContent(cards: [], availability: .live),
            loadFailureContent: NewsFeedFixtures.fallbackContent,
            loadFailureMessage: "Failed to load"
        )
    }
}
