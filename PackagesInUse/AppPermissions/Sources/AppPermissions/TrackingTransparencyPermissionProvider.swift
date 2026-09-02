#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
import Foundation

public struct TrackingTransparencyPermissionProvider: PermissionProviding {
    public let supportedKinds: Set<PermissionKind> = [.trackingTransparency]
    private let usageDescriptionChecker: any PermissionUsageDescriptionChecking

    public init(usageDescriptionChecker: any PermissionUsageDescriptionChecking = PermissionUsageDescriptionChecker.mainBundle) {
        self.usageDescriptionChecker = usageDescriptionChecker
    }

    public func state(for kind: PermissionKind) async -> PermissionState {
        guard kind == .trackingTransparency else { return .unavailable }
        if #available(iOS 14, tvOS 14, *) {
            return map(ATTrackingManager.trackingAuthorizationStatus)
        }
        return .unavailable
    }

    public func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome {
        guard kind == .trackingTransparency else { throw PermissionError.unsupportedKind(kind) }
        guard #available(iOS 14, tvOS 14, *) else { throw PermissionError.unavailable(kind) }
        try usageDescriptionChecker.validateUsageDescriptions(for: kind)
        let previous = await state(for: kind)
        let status = await ATTrackingManager.requestTrackingAuthorization()
        return PermissionRequestOutcome(kind: kind, state: map(status), didPromptUser: previous == .notDetermined)
    }

    @available(iOS 14, tvOS 14, *)
    private func map(_ status: ATTrackingManager.AuthorizationStatus) -> PermissionState {
        switch status {
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        case .denied: .denied
        case .authorized: .authorized
        @unknown default: .unknown
        }
    }
}
#endif
