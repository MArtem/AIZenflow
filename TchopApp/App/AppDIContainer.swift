import Foundation
import SwiftUI
import TchopNetworking
/// AppDIContainer!!!
/// Composition root for the application.
///
/// The container owns app-wide infrastructure services and constructs feature-level
/// dependencies for the SwiftUI tree.
@MainActor
final class AppDIContainer: ObservableObject {
    /// Database backend adapter consumed by repositories and seeders.
    let databaseManager: any AppDatabaseManaging

    /// Shared networking client used by feature-specific API managers.
    let apiManager: any APIManaging

    /// Feed-specific API abstraction currently backed by stub data.
    let feedAPIManager: any FeedAPIManaging

    /// Repository serving shell and feed content.
    let contentRepository: any AppContentRepository

    /// Repository serving persisted users.
    let userRepository: any UserRepository

    /// Service responsible for sign-in and session restoration.
    let sessionService: any UserSessionManaging

    /// Active persistence backend chosen for the current app runtime.
    let databaseBackendKind: AppDatabaseBackendKind

    /// Creates the root dependency container and eagerly wires the initial graph.
    init(databaseConfiguration: AppDatabaseConfiguration = .default) {
        let databaseManager = AppDatabase.makeDatabaseManager(configuration: databaseConfiguration)
        self.databaseManager = databaseManager
        self.databaseBackendKind = databaseManager.backendKind

        do {
            try AppDataSeeder.seedIfNeeded(in: databaseManager)
        } catch {
            assertionFailure("Failed to seed local data: \(error)")
        }

        let apiManager = APIManager(configuration: .stub)
        self.apiManager = apiManager

        let feedAPIManager = StubFeedAPIManager(apiManager: apiManager)
        self.feedAPIManager = feedAPIManager

        let contentRepository = DefaultAppContentRepository(
            databaseManager: databaseManager,
            feedAPIManager: feedAPIManager
        )
        self.contentRepository = contentRepository

        let userRepository = DefaultUserRepository(databaseManager: databaseManager)
        self.userRepository = userRepository

        self.sessionService = UserSessionService(userRepository: userRepository)
    }

    /// Creates the shell view model used by the authenticated part of the app.
    func makeAppShellViewModel() -> AppShellViewModel {
        AppShellViewModel(contentRepository: contentRepository)
    }

    /// Creates the root app state object used by the app entry point.
    func makeAppState() -> AppState {
        AppState(
            coordinator: AppCoordinator(),
            appShellViewModel: makeAppShellViewModel(),
            sessionService: sessionService
        )
    }
}

private struct DIContainerKey: EnvironmentKey {
    static let defaultValue: AppDIContainer? = nil
}

extension EnvironmentValues {
    /// Shared dependency container exposed to the SwiftUI environment.
    var diContainer: AppDIContainer? {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
