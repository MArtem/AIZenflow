import Foundation

/// Launch-time configuration derived from process environment for local testing flows.
struct AppLaunchConfiguration {
    let isUITesting: Bool
    let launchesAuthenticatedSession: Bool
    let uiTestUsername: String
    let initialURL: URL?
    let apiEnvironment: AppAPIEnvironment

    /// Creates a new AppLaunchConfiguration instance.
    ///
    /// This is also the single place where development-only external runtime switches are read
    /// from launch environment variables so the rest of the app can stay declarative.
    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        self.isUITesting = environment["TCHOP_UI_TEST_MODE"] == "1"
        self.launchesAuthenticatedSession = environment["TCHOP_UI_TEST_AUTHENTICATED"] == "1"
        self.uiTestUsername = environment["TCHOP_UI_TEST_USERNAME"] ?? "ui-test-user"
        self.initialURL = Self.makeInitialURL(environment: environment)
        self.apiEnvironment = Self.makeAPIEnvironment(environment: environment)
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

    /// Resolves the API environment used for the current launch.
    ///
    /// `TCHOP_API_ENV=reqres_demo_auth` enables the external login/register screen backed by ReqRes.
    /// The corresponding API key is read from `TCHOP_REQRES_API_KEY`.
    private static func makeAPIEnvironment(environment: [String: String]) -> AppAPIEnvironment {
        switch environment["TCHOP_API_ENV"] {
        case "reqres_demo_auth":
            return .developmentExternalAuth(
                reqResAPIKey: environment["TCHOP_REQRES_API_KEY"] ?? "",
                enablesNetworkLogging: environment["TCHOP_NETWORK_LOGGING"] == "1"
            )
        default:
            return .localStub
        }
    }
}
