#if canImport(AVFoundation)
@preconcurrency import AVFoundation
import Foundation

public struct AVFoundationPermissionProvider: PermissionProviding {
    public let supportedKinds: Set<PermissionKind> = [.camera, .microphone]
    private let usageDescriptionChecker: any PermissionUsageDescriptionChecking

    public init(usageDescriptionChecker: any PermissionUsageDescriptionChecking = PermissionUsageDescriptionChecker.mainBundle) {
        self.usageDescriptionChecker = usageDescriptionChecker
    }

    public func state(for kind: PermissionKind) async -> PermissionState {
        guard let mediaType = mediaType(for: kind) else { return .unavailable }
        return map(AVCaptureDevice.authorizationStatus(for: mediaType))
    }

    public func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome {
        guard let mediaType = mediaType(for: kind) else { throw PermissionError.unsupportedKind(kind) }
        try usageDescriptionChecker.validateUsageDescriptions(for: kind)
        let previous = await state(for: kind)
        let granted = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                continuation.resume(returning: granted)
            }
        }
        let next: PermissionState = granted ? .authorized : await state(for: kind)
        return PermissionRequestOutcome(kind: kind, state: next, didPromptUser: previous == .notDetermined)
    }

    private func mediaType(for kind: PermissionKind) -> AVMediaType? {
        switch kind {
        case .camera: .video
        case .microphone: .audio
        default: nil
        }
    }

    private func map(_ status: AVAuthorizationStatus) -> PermissionState {
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
