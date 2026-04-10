import SwiftUI

@main
struct TchopApp: App {
    private let container: AppDIContainer
    @StateObject private var appState: AppState

    init() {
        let container = AppDIContainer()
        self.container = container

        _appState = StateObject(
            wrappedValue: container.makeAppState()
        )
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(appState: appState)
                .environment(\.diContainer, container)
        }
    }
}
