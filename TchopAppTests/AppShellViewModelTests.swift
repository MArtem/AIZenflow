import XCTest
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
            contentRepository: TestAppContentRepository(),
            uiConfigurationManager: uiConfigurationManager,
            widgetContentSyncManager: NoopWidgetContentSyncManager()
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
            contentRepository: TestAppContentRepository(),
            uiConfigurationManager: uiConfigurationManager,
            widgetContentSyncManager: NoopWidgetContentSyncManager()
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
}

private enum TestUIConfigurationError: Error {
    case refreshFailed
}

private actor TestUIConfigurationManager: UIConfigurationManaging {
    private let currentSnapshotValue: UIConfigurationSnapshot
    private let refreshResult: Result<UIConfigurationSnapshot, Error>
    private let refreshDelayNanoseconds: UInt64

    /// Creates a new TestUIConfigurationManager instance.
    init(
        currentSnapshot: UIConfigurationSnapshot,
        refreshResult: Result<UIConfigurationSnapshot, Error>,
        refreshDelayNanoseconds: UInt64
    ) {
        self.currentSnapshotValue = currentSnapshot
        self.refreshResult = refreshResult
        self.refreshDelayNanoseconds = refreshDelayNanoseconds
    }

    /// Returns configuration.
    func currentConfiguration() async -> UIConfigurationSnapshot {
        currentSnapshotValue
    }

    /// Handles refresh configuration.
    func refreshConfiguration() async throws -> UIConfigurationSnapshot {
        if refreshDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: refreshDelayNanoseconds)
        }

        return try refreshResult.get()
    }
}
