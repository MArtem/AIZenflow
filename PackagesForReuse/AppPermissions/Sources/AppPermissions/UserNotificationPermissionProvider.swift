#if canImport(UserNotifications)
@preconcurrency import UserNotifications
import Foundation

public struct UserNotificationPermissionProvider: PermissionProviding {
    public let supportedKinds: Set<PermissionKind> = [.notifications]
    private let notificationCenter: UNUserNotificationCenter
    private let options: UNAuthorizationOptions

    public init(
        notificationCenter: UNUserNotificationCenter = .current(),
        options: UNAuthorizationOptions = [.alert, .badge, .sound]
    ) {
        self.notificationCenter = notificationCenter
        self.options = options
    }

    public func state(for kind: PermissionKind) async -> PermissionState {
        guard kind == .notifications else { return .unavailable }
        let settings = await notificationCenter.notificationSettings()
        return map(settings.authorizationStatus)
    }

    public func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome {
        guard kind == .notifications else { throw PermissionError.unsupportedKind(kind) }
        let previous = await state(for: kind)
        do {
            _ = try await notificationCenter.requestAuthorization(options: options)
            let next = await state(for: kind)
            return PermissionRequestOutcome(kind: kind, state: next, didPromptUser: previous == .notDetermined)
        } catch {
            throw PermissionError.platformRequestFailed(kind: kind, code: "notification_request_failed")
        }
    }

    private func map(_ status: UNAuthorizationStatus) -> PermissionState {
        switch status {
        case .notDetermined: .notDetermined
        case .denied: .denied
        case .authorized: .authorized
        case .provisional: .provisional
        case .ephemeral: .ephemeral
        @unknown default: .unknown
        }
    }
}
#endif
