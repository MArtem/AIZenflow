import Observation
import SwiftUI

/// Generic navigation root hosting a typed path with destination builder closure.
struct StubTabNavigationRootView<Route: Hashable, Destination: View>: View {
    let tab: AppTab
    @Bindable var router: TabRouter<Route>
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
        $router.path
    }

    /// Opens sample.
    private func openSample() {
        router.push(sampleRoute)
    }
}

#if DEBUG
#Preview("Stub Navigation Root") {
    StubTabNavigationRootView(
        tab: .mixes,
        router: TabRouter<MixesRoute>(),
        sampleRoute: ViewPreviewSupport.sampleMixesRoute,
        destinationBuilder: { route in
            FeatureTabDetailView(
                title: route.title,
                description: route.description
            )
        }
    )
}
#endif
