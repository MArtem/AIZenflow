import Foundation
import TchopErrors
import UIKit
import UserNotifications
import TchopPushNotifications

/// App-facing abstraction used by the application delegate to forward APNs events.
@MainActor
protocol AppPushNotificationBridging: AnyObject {
    /// Handles start.
    func start(application: UIApplication)
    /// Requests authorization and register.
    func requestAuthorizationAndRegister(application: UIApplication) async
    /// Handles register for remote notifications.
    func didRegisterForRemoteNotifications(deviceToken: Data) async
    /// Handles fail to register for remote notifications.
    func didFailToRegisterForRemoteNotifications(error: Error) async
    /// Handles remote notification.
    func handleRemoteNotification(
        userInfo: [AnyHashable: Any],
        source: PushNotificationEventSource
    ) async
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
    func handleRemoteNotification(
        userInfo: [AnyHashable: Any],
        source: PushNotificationEventSource
    ) async {}
}

/// App composition bridge that connects system APNs callbacks with the reusable package manager.
@MainActor
final class AppPushNotificationBridge: AppPushNotificationBridging {
    private let manager: any PushNotificationManaging
    private let notificationCenter: UNUserNotificationCenter
    private let payloadParser: any PushNotificationPayloadParsing
    private let errorManager: any AppErrorManaging

    /// Creates a new AppPushNotificationBridge instance.
    init(
        manager: any PushNotificationManaging,
        errorManager: any AppErrorManaging,
        notificationCenter: UNUserNotificationCenter = .current(),
        payloadParser: any PushNotificationPayloadParsing = DefaultPushNotificationPayloadParser()
    ) {
        self.manager = manager
        self.errorManager = errorManager
        self.notificationCenter = notificationCenter
        self.payloadParser = payloadParser
    }

    /// Handles start.
    func start(application: UIApplication) {
        Task {
            let status = await refreshAuthorizationStatus()
            if status == .authorized || status == .provisional || status == .ephemeral {
                application.registerForRemoteNotifications()
                _ = try? await manager.updateRemoteRegistration(
                    isRegistered: application.isRegisteredForRemoteNotifications
                )
            }
        }
    }

    /// Requests authorization and register.
    func requestAuthorizationAndRegister(application: UIApplication) async {
        do {
            let isGranted = try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            let status: PushNotificationAuthorizationStatus = isGranted ? .authorized : .denied
            _ = try await manager.updateAuthorizationStatus(status)

            guard isGranted else {
                return
            }

            application.registerForRemoteNotifications()
            _ = try await manager.updateRemoteRegistration(
                isRegistered: application.isRegisteredForRemoteNotifications
            )
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
    func handleRemoteNotification(
        userInfo: [AnyHashable: Any],
        source: PushNotificationEventSource
    ) async {
        do {
            let payload = payloadParser.parse(userInfo: userInfo, source: source)
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
        let settings = await notificationCenter.notificationSettings()
        let status = PushNotificationAuthorizationStatus(settings.authorizationStatus)
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
            assertionFailure("Push notification bridge failure: \(presentation.error.debugDescription)")
        }
    }
}

extension PushNotificationAuthorizationStatus {
    /// Creates a new AppPushNotificationBridge instance.
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
