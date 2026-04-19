import Foundation

/// Launch-time configuration derived from process environment for local testing flows.
struct AppLaunchConfiguration {
    let isUITesting: Bool
    let launchesAuthenticatedSession: Bool
    let uiTestUsername: String

    /// Creates a new AppLaunchConfiguration instance.
    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        self.isUITesting = environment["TCHOP_UI_TEST_MODE"] == "1"
        self.launchesAuthenticatedSession = environment["TCHOP_UI_TEST_AUTHENTICATED"] == "1"
        self.uiTestUsername = environment["TCHOP_UI_TEST_USERNAME"] ?? "ui-test-user"
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
}
