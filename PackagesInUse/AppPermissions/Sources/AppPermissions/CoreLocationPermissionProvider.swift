#if canImport(CoreLocation)
@preconcurrency import CoreLocation
import Foundation

/// Status-oriented CoreLocation provider.
///
/// CoreLocation request flows need delegate ownership and lifecycle control.
/// This standalone package exposes normalized status and intentionally asks host apps
/// to provide an app-managed requesting provider when they need custom location flow handling.
public struct CoreLocationPermissionProvider: PermissionProviding {
    public let supportedKinds: Set<PermissionKind> = [.locationWhenInUse, .locationAlways]

    public init() {}

    public func state(for kind: PermissionKind) async -> PermissionState {
        guard supportedKinds.contains(kind) else { return .unavailable }
        guard CLLocationManager.locationServicesEnabled() else { return .unavailable }
        return map(Self.authorizationStatus())
    }

    public func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome {
        guard supportedKinds.contains(kind) else { throw PermissionError.unsupportedKind(kind) }
        throw PermissionError.requestRequiresAppManagedDelegate(kind)
    }

    private static func authorizationStatus() -> CLAuthorizationStatus {
        CLLocationManager().authorizationStatus
    }

    private func map(_ status: CLAuthorizationStatus) -> PermissionState {
        switch status {
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        case .denied: .denied
        case .authorizedAlways, .authorizedWhenInUse: .authorized
        @unknown default: .unknown
        }
    }
}
#endif
