import Foundation
import AppDatabase

/// Launch-time database mode used to steer the app between automatic resolution and
/// explicit single-backend runs for local development and debugging.
private enum AppLaunchDatabaseMode {
    case swiftDataOnly
    /*
     Legacy cases kept commented for quick rollback if Core Data / iOS 16 support must return.
     case automatic
     case coreDataOnly
     */

    /// Maps the launch mode to the backend selection policy consumed by the shared
    /// database bootstrap contract.
    var backendSelectionPolicy: DatabaseBackendSelectionPolicy {
        .swiftData
    }

    /// Parses development launch values while keeping the active SwiftData-only baseline.
    static func make(from rawValue: String?) -> Self {
        let normalizedValue = rawValue?.lowercased()
        if normalizedValue == "swiftdata" || normalizedValue == "swift_data" || normalizedValue == "swiftdataonly" {
            return .swiftDataOnly
        }

        /*
         Legacy parser kept commented for quick rollback if Core Data / automatic selection return.
         switch rawValue?.lowercased() {
         case "swiftdata", "swift_data", "swiftdataonly":
             return .swiftDataOnly
         case "coredata", "core_data", "coredataonly":
             return .coreDataOnly
         default:
             return .automatic
         }
         */
        return .swiftDataOnly
    }
}

/// Launch-time configuration derived from process environment for local testing flows.
///
/// This keeps development-only runtime switches centralized in one place so entry points and
/// composition do not grow ad-hoc environment parsing logic.
struct AppLaunchConfiguration {
    let isUITesting: Bool
    let launchesAuthenticatedSession: Bool
    let uiTestUsername: String
    let initialURL: URL?
    let apiEnvironment: AppAPIEnvironment
    private let databaseMode: AppLaunchDatabaseMode

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
        self.databaseMode = AppLaunchDatabaseMode.make(
            from: environment["TCHOP_DATABASE_BACKEND"] ?? "swiftData"
        )
    }

    /// Returns the database configuration appropriate for the current launch mode.
    ///
    /// `TCHOP_DATABASE_BACKEND` currently keeps only the SwiftData path active.
    ///
    /// Legacy `automatic` / `coreData` launch overrides are intentionally commented in the
    /// implementation so the old runtime-selection path can be restored quickly if needed.
    var databaseConfiguration: DatabaseConfiguration {
        if isUITesting {
            return DatabaseConfiguration(
                backendSelectionPolicy: databaseMode.backendSelectionPolicy,
                isStoredInMemoryOnly: true
            )
        }

        return DatabaseConfiguration(
            backendSelectionPolicy: databaseMode.backendSelectionPolicy,
            isStoredInMemoryOnly: false
        )
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
                reqResAPIKey: environment["TCHOP_REQRES_API_KEY"] ?? "free_user_3Co5h4PffK0RHil0TjwChhqMETj",
                enablesNetworkLogging: environment["TCHOP_NETWORK_LOGGING"] == "1"
            )
        default:
            return .developmentStub
        }
    }
}
