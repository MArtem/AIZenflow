import SwiftUI

/// Process entry point for the local-only AI Fieldbook app.
///
/// Responsibilities:
/// - bootstraps the SwiftData container before the root UI appears;
/// - renders an explicit persistence failure surface when local storage cannot open;
/// - keeps app-level dependency composition inside `AppShellView` after persistence succeeds.
///
/// Ownership:
/// Created by the SwiftUI runtime once per app process.
@main
struct AIFieldbookApp: App {
    private let persistence = PersistenceBootstrap.load()

    var body: some Scene {
        WindowGroup {
            switch persistence {
            case let .ready(container):
                AppShellView(container: container)
                    .modelContainer(container)
            case .failed:
                PersistenceFailureView()
            }
        }
    }
}
