import Foundation
import UIKit
import UserNotifications
import TchopPushNotifications

/// UIKit lifecycle bridge used to receive APNs callbacks in the SwiftUI app.
final class TchopApplicationDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    weak var pushNotificationBridge: (any AppPushNotificationBridging)?

    /// Handles application.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        pushNotificationBridge?.start(application: application)
        return true
    }

    /// Handles application.
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task {
            await pushNotificationBridge?.didRegisterForRemoteNotifications(deviceToken: deviceToken)
        }
    }

    /// Handles application.
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task {
            await pushNotificationBridge?.didFailToRegisterForRemoteNotifications(error: error)
        }
    }

    /// Handles application.
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Task {
            await pushNotificationBridge?.handleRemoteNotification(
                userInfo: userInfo,
                source: .backgroundFetch
            )
            completionHandler(.newData)
        }
    }

    /// Handles user notification center.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Task {
            await pushNotificationBridge?.handleRemoteNotification(
                userInfo: notification.request.content.userInfo,
                source: .foreground
            )
            completionHandler([.banner, .badge, .sound])
        }
    }

    /// Handles user notification center.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task {
            await pushNotificationBridge?.handleRemoteNotification(
                userInfo: response.notification.request.content.userInfo,
                source: .opened
            )
            completionHandler()
        }
    }
}
