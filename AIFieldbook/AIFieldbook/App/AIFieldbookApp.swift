import AppIntents
import SwiftData
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
        if #available(iOS 26.0, *) {
            AIFieldbookShortcuts.updateAppShortcutParameters()
        }
    }

    var body: some Scene {
        WindowGroup {
            PersistenceRootView()
        }
    }
}

/// Owns retryable process-local SwiftData bootstrap state without ever deleting the store.
private struct PersistenceRootView: View {
    @State private var persistence = PersistenceRootView.loadPersistence()

    @MainActor private static func loadPersistence() -> PersistenceBootstrap {
        #if DEBUG
        if ProcessInfo.processInfo.environment["AI_FIELDBOOK_KB_UI"] == "1" {
            do {
                let schema = Schema(AIFieldbookSchemaV3.models)
                let container = try ModelContainer(for: schema, configurations: [
                    ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                ])
                let repository = FieldbookRepository(context: container.mainContext)
                let workspace = try repository.createWorkspace(name: "KB UI Workspace")
                for title in ["Alpha Note", "Beta Note", "Failure Note"] {
                    _ = try repository.createTextNote(workspaceID: workspace, title: title, body: "Local UI fixture")
                }
                return .ready(container)
            } catch {
                return .failed(referenceID: "KB-UI-fixture")
            }
        }
        #endif
        return PersistenceBootstrap.load()
    }

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
