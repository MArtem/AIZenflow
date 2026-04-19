import Foundation

/// Launch-time configuration derived from process environment for local testing flows.
struct AppLaunchConfiguration {
    let isUITesting: Bool
    let launchesAuthenticatedSession: Bool
    let uiTestUsername: String
    let initialURL: URL?

    /// Creates a new AppLaunchConfiguration instance.
    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        self.isUITesting = environment["TCHOP_UI_TEST_MODE"] == "1"
        self.launchesAuthenticatedSession = environment["TCHOP_UI_TEST_AUTHENTICATED"] == "1"
        self.uiTestUsername = environment["TCHOP_UI_TEST_USERNAME"] ?? "ui-test-user"
        self.initialURL = Self.makeInitialURL(environment: environment)
    }

    /// Returns the database configuration appropriate for the current launch mode.
    var databaseConfiguration: AppDatabaseConfiguration {
        if isUITesting {
            return AppDatabaseConfiguration(
                backendSelectionPolicy: .automatic,
                isStoredInMemoryOnly: true
            )
        }

        return .persistent
    }

    /// Builds the optional initial URL used by deterministic launch-driven UI tests.
    private static func makeInitialURL(environment: [String: String]) -> URL? {
        guard let rawValue = environment["TCHOP_UI_TEST_INITIAL_URL"] else {
            return nil
        }

        return URL(string: rawValue)
    }
}
