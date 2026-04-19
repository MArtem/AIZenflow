import SwiftUI
import TchopNavigation

/// Generic navigation root hosting a typed path with destination builder closure.
struct StubTabNavigationRootView<Route: Hashable, Destination: View>: View {
    let tab: AppTab
    @ObservedObject var router: TabRouter<Route>
    let sampleRoute: Route
    let destinationBuilder: (Route) -> Destination

    var body: some View {
        NavigationStack(path: pathBinding) {
            TabStubView(
                tab: tab,
                onOpenSample: openSample
            )
            .navigationDestination(for: Route.self) { route in
                destinationBuilder(route)
            }
        }
    }

    private var pathBinding: Binding<[Route]> {
        Binding(
            get: { router.path },
            set: { router.replacePath(with: $0) }
        )
    }

    /// Opens sample.
    private func openSample() {
        router.push(sampleRoute)
    }
}
