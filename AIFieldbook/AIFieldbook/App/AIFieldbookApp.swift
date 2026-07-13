import SwiftUI

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
