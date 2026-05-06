import TchopUIConfiguration

/// Test-only UI configuration error cases.
enum TestUIConfigurationError: Error {
    case refreshFailed
}

/// In-memory UI configuration manager used by shell tests.
actor TestUIConfigurationManager: UIConfigurationManaging {
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

    /// Returns the currently cached configuration snapshot.
    func currentConfiguration() async -> UIConfigurationSnapshot {
        currentSnapshotValue
    }

    /// Returns whether the current snapshot should be treated as stale in tests.
    func isCurrentConfigurationStale() async -> Bool {
        false
    }

    /// Returns the configured refresh result after the optional delay.
    func refreshConfiguration() async throws -> UIConfigurationSnapshot {
        if refreshDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: refreshDelayNanoseconds)
        }

        return try refreshResult.get()
    }
}
