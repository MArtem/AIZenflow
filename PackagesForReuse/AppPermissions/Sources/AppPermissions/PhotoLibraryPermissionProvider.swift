#if canImport(Photos)
import Photos
import Foundation

public struct PhotoLibraryPermissionProvider: PermissionProviding {
    public let supportedKinds: Set<PermissionKind> = [.photoLibrary, .photoLibraryAddOnly]
    private let usageDescriptionChecker: any PermissionUsageDescriptionChecking

    public init(usageDescriptionChecker: any PermissionUsageDescriptionChecking = PermissionUsageDescriptionChecker.mainBundle) {
        self.usageDescriptionChecker = usageDescriptionChecker
    }

    public func state(for kind: PermissionKind) async -> PermissionState {
        guard supportedKinds.contains(kind) else { return .unavailable }
        if #available(iOS 14, macOS 11, tvOS 14, *) {
            let accessLevel: PHAccessLevel = kind == .photoLibraryAddOnly ? .addOnly : .readWrite
            return map(PHPhotoLibrary.authorizationStatus(for: accessLevel))
        } else {
            return map(PHPhotoLibrary.authorizationStatus())
        }
    }

    public func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome {
        guard supportedKinds.contains(kind) else { throw PermissionError.unsupportedKind(kind) }
        try usageDescriptionChecker.validateUsageDescriptions(for: kind)
        let previous = await state(for: kind)
        let status: PHAuthorizationStatus
        if #available(iOS 14, macOS 11, tvOS 14, *) {
            let accessLevel: PHAccessLevel = kind == .photoLibraryAddOnly ? .addOnly : .readWrite
            status = await PHPhotoLibrary.requestAuthorization(for: accessLevel)
        } else {
            status = await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization { status in
                    continuation.resume(returning: status)
                }
            }
        }
        return PermissionRequestOutcome(kind: kind, state: map(status), didPromptUser: previous == .notDetermined)
    }

    private func map(_ status: PHAuthorizationStatus) -> PermissionState {
        switch status {
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        case .denied: .denied
        case .authorized: .authorized
        case .limited: .limited
        @unknown default: .unknown
        }
    }
}
#endif
