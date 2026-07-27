import Foundation
import UIKit
import UserNotifications

/// App-facing abstraction used by the application delegate to forward APNs events.
@MainActor
protocol AppPushNotificationBridging: AnyObject, Sendable {
    /// Handles start.
    func start(application: UIApplication)
    /// Requests authorization and register.
    func requestAuthorizationAndRegister(application: UIApplication) async
    /// Handles register for remote notifications.
    func didRegisterForRemoteNotifications(deviceToken: Data) async
    /// Handles fail to register for remote notifications.
    func didFailToRegisterForRemoteNotifications(error: Error) async
    /// Handles remote notification.
    func handleRemoteNotification(_ payload: PushNotificationPayload) async
}

/// No-op implementation used when the app intentionally does not wire real push handling.
@MainActor
final class NoopPushNotificationBridge: AppPushNotificationBridging {
    /// Handles start.
    func start(application: UIApplication) {}

    /// Requests authorization and register.
    func requestAuthorizationAndRegister(application: UIApplication) async {}

    /// Handles register for remote notifications.
    func didRegisterForRemoteNotifications(deviceToken: Data) async {}

    /// Handles fail to register for remote notifications.
    func didFailToRegisterForRemoteNotifications(error: Error) async {}

    /// Handles remote notification.
    func handleRemoteNotification(_ payload: PushNotificationPayload) async {}
}

/// App composition bridge that connects system APNs callbacks with the reusable package manager.
@MainActor
final class AppPushNotificationBridge: AppPushNotificationBridging {
    private let manager: any PushNotificationManaging
    private let notificationPermissionProvider: any PermissionProviding
    private let errorManager: any AppErrorManaging

    /// Creates a new AppPushNotificationBridge instance.
    init(
        manager: any PushNotificationManaging,
        errorManager: any AppErrorManaging,
        notificationCenter: UNUserNotificationCenter = .current(),
        notificationPermissionProvider: (any PermissionProviding)? = nil
    ) {
        self.manager = manager
        self.errorManager = errorManager
        self.notificationPermissionProvider = notificationPermissionProvider ?? UserNotificationPermissionProvider(
            notificationCenter: notificationCenter
        )
    }

    /// Handles start.
    func start(application: UIApplication) {
        Task {
            let status = await refreshAuthorizationStatus()
            if status.supportsRemoteRegistration {
                application.registerForRemoteNotifications()
                await syncRemoteRegistration(application: application)
            }
        }
    }

    /// Requests authorization and register.
    func requestAuthorizationAndRegister(application: UIApplication) async {
        do {
            let outcome = try await notificationPermissionProvider.request(.notifications)
            let status = PushNotificationAuthorizationStatus(outcome.state)
            _ = try await manager.updateAuthorizationStatus(status)

            guard outcome.state.grantsAccess else {
                return
            }

            application.registerForRemoteNotifications()
            await syncRemoteRegistration(application: application)
        } catch {
            reportPushFailure(
                error,
                operation: "requestAuthorizationAndRegister"
            )
        }
    }

    /// Handles register for remote notifications.
    func didRegisterForRemoteNotifications(deviceToken: Data) async {
        do {
            _ = try await manager.handleDeviceToken(deviceToken)
        } catch {
            reportPushFailure(
                error,
                operation: "handleDeviceToken"
            )
        }
    }

    /// Handles fail to register for remote notifications.
    func didFailToRegisterForRemoteNotifications(error: Error) async {
        do {
            _ = try await manager.handleRegistrationFailure(error.localizedDescription)
        } catch {
            reportPushFailure(
                error,
                operation: "handleRegistrationFailure"
            )
        }
    }

    /// Handles remote notification.
    func handleRemoteNotification(_ payload: PushNotificationPayload) async {
        do {
            _ = try await manager.handleRemoteNotification(payload)
        } catch {
            reportPushFailure(
                error,
                operation: "handleRemoteNotification"
            )
        }
    }

    /// Handles refresh authorization status.
    private func refreshAuthorizationStatus() async -> PushNotificationAuthorizationStatus {
        let permissionState = await notificationPermissionProvider.state(for: .notifications)
        let status = PushNotificationAuthorizationStatus(permissionState)
        do {
            _ = try await manager.updateAuthorizationStatus(status)
        } catch {
            reportPushFailure(
                error,
                operation: "refreshAuthorizationStatus"
            )
        }
        return status
    }

    /// Persists the current app-level APNs registration state through the shared push manager.
    private func syncRemoteRegistration(application: UIApplication) async {
        do {
            _ = try await manager.updateRemoteRegistration(
                isRegistered: application.isRegisteredForRemoteNotifications
            )
        } catch {
            reportPushFailure(
                error,
                operation: "updateRemoteRegistration"
            )
        }
    }

    /// Normalizes and reports push-runtime failures through the shared app error manager.
    private func reportPushFailure(
        _ error: Error,
        operation: String
    ) {
        Task { [errorManager] in
            let presentation = await errorManager.presentableError(
                from: error,
                context: AppErrorContext(
                    operation: operation,
                    feature: "pushNotifications"
                )
            )
            _ = presentation
        }
    }
}

extension PushNotificationAuthorizationStatus {
    var supportsRemoteRegistration: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        }
    }

    /// Creates a push authorization status from the generic permission state contract.
    init(_ state: PermissionState) {
        switch state {
        case .notDetermined:
            self = .notDetermined
        case .authorized:
            self = .authorized
        case .provisional:
            self = .provisional
        case .ephemeral:
            self = .ephemeral
        case .denied, .restricted, .limited, .unavailable:
            self = .denied
        case .unknown:
            self = .notDetermined
        }
    }

    /// Creates a push authorization status from the platform notification status.
    init(_ status: UNAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .denied:
            self = .denied
        case .authorized:
            self = .authorized
        case .provisional:
            self = .provisional
        case .ephemeral:
            self = .ephemeral
        @unknown default:
            self = .notDetermined
        }
    }
}
