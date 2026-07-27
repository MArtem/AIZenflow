import AppIntents
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
    init() {
        AIFieldbookShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            PersistenceRootView()
        }
    }
}

/// Owns retryable process-local SwiftData bootstrap state without ever deleting the store.
private struct PersistenceRootView: View {
    @State private var persistence = PersistenceBootstrap.load()

    var body: some View {
        switch persistence {
        case let .ready(container):
            AppShellView(container: container)
                .modelContainer(container)
        case let .failed(referenceID):
            PersistenceFailureView(referenceID: referenceID) {
                persistence = PersistenceBootstrap.load()
            }
        }
    }
}
