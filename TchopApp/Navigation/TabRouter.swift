import Foundation

/// Generic router that stores a typed navigation path for a single tab.
@MainActor
final class TabRouter<Route: Hashable>: ObservableObject {
    /// Current navigation path.
    @Published var path: [Route] = []

    /// Pushes a new route onto the navigation stack.
    func push(_ route: Route) {
        path.append(route)
    }

    /// Pops the top route when available.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Clears the navigation stack.
    func popToRoot() {
        path.removeAll()
    }

    /// Replaces the entire navigation path with a new value.
    func replacePath(with newPath: [Route]) {
        path = newPath
    }
}
