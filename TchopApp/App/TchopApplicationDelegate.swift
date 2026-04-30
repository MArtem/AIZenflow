import Foundation
import UIKit
import UserNotifications
import TchopPushNotifications

/// UIKit lifecycle bridge used to receive APNs callbacks in the SwiftUI app.
final class TchopApplicationDelegate: NSObject, UIApplicationDelegate {
    weak var pushNotificationBridge: (any AppPushNotificationBridging)?
    private let payloadParser: any PushNotificationPayloadParsing = DefaultPushNotificationPayloadParser()
    private let notificationCenterDelegateProxy = TchopUserNotificationCenterDelegateProxy()

    /// Handles application.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        notificationCenterDelegateProxy.pushNotificationBridge = pushNotificationBridge
        notificationCenterDelegateProxy.payloadParser = payloadParser
        UNUserNotificationCenter.current().delegate = notificationCenterDelegateProxy
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
        let payload = payloadParser.parse(
            userInfo: userInfo,
            source: .backgroundFetch
        )
        Task {
            await pushNotificationBridge?.handleRemoteNotification(payload)
            completionHandler(.newData)
        }
    }

}

/// Dedicated UNUserNotificationCenterDelegate proxy kept separate from UIApplicationDelegate isolation rules.
private final class TchopUserNotificationCenterDelegateProxy: NSObject, UNUserNotificationCenterDelegate {
    weak var pushNotificationBridge: (any AppPushNotificationBridging)?
    var payloadParser: (any PushNotificationPayloadParsing)?

    /// Handles foreground notification presentation.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        guard let payloadParser else {
            completionHandler([.banner, .badge, .sound])
            return
        }
        let payload = payloadParser.parse(
            userInfo: notification.request.content.userInfo,
            source: .foreground
        )
        let pushNotificationBridge = pushNotificationBridge
        completionHandler([.banner, .badge, .sound])
        Task { [pushNotificationBridge, payload] in
            await pushNotificationBridge?.handleRemoteNotification(payload)
        }
    }

    /// Handles notification response opens.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard let payloadParser else {
            completionHandler()
            return
        }
        let payload = payloadParser.parse(
            userInfo: response.notification.request.content.userInfo,
            source: .opened
        )
        let pushNotificationBridge = pushNotificationBridge
        completionHandler()
        Task { [pushNotificationBridge, payload] in
            await pushNotificationBridge?.handleRemoteNotification(payload)
        }
    }
}
