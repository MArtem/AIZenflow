import Foundation
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

    /// Creates a new AppPushNotificationBridge instance.
    init(
        manager: any PushNotificationManaging,
        notificationCenter: UNUserNotificationCenter = .current(),
        payloadParser: any PushNotificationPayloadParsing = DefaultPushNotificationPayloadParser()
    ) {
        self.manager = manager
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
            assertionFailure("Failed to request push notification authorization: \(error)")
        }
    }

    /// Handles register for remote notifications.
    func didRegisterForRemoteNotifications(deviceToken: Data) async {
        do {
            _ = try await manager.handleDeviceToken(deviceToken)
        } catch {
            assertionFailure("Failed to persist APNs device token: \(error)")
        }
    }

    /// Handles fail to register for remote notifications.
    func didFailToRegisterForRemoteNotifications(error: Error) async {
        do {
            _ = try await manager.handleRegistrationFailure(error.localizedDescription)
        } catch {
            assertionFailure("Failed to persist APNs registration error: \(error)")
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
            assertionFailure("Failed to handle APNs payload: \(error)")
        }
    }

    /// Handles refresh authorization status.
    private func refreshAuthorizationStatus() async -> PushNotificationAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        let status = PushNotificationAuthorizationStatus(settings.authorizationStatus)
        do {
            _ = try await manager.updateAuthorizationStatus(status)
        } catch {
            assertionFailure("Failed to persist push authorization status: \(error)")
        }
        return status
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
