#if canImport(Contacts)
@preconcurrency import Contacts
import Foundation

public struct ContactsPermissionProvider: PermissionProviding {
    public let supportedKinds: Set<PermissionKind> = [.contacts]
    private let usageDescriptionChecker: any PermissionUsageDescriptionChecking

    public init(usageDescriptionChecker: any PermissionUsageDescriptionChecking = PermissionUsageDescriptionChecker.mainBundle) {
        self.usageDescriptionChecker = usageDescriptionChecker
    }

    public func state(for kind: PermissionKind) async -> PermissionState {
        guard kind == .contacts else { return .unavailable }
        return map(CNContactStore.authorizationStatus(for: .contacts))
    }

    public func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome {
        guard kind == .contacts else { throw PermissionError.unsupportedKind(kind) }
        try usageDescriptionChecker.validateUsageDescriptions(for: kind)
        let previous = await state(for: kind)
        do {
            _ = try await CNContactStore().requestAccess(for: .contacts)
            let next = await state(for: kind)
            return PermissionRequestOutcome(kind: kind, state: next, didPromptUser: previous == .notDetermined)
        } catch {
            throw PermissionError.platformRequestFailed(kind: kind, code: "contacts_request_failed")
        }
    }

    private func map(_ status: CNAuthorizationStatus) -> PermissionState {
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
