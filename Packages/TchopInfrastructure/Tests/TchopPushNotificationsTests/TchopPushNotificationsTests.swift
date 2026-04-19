import Foundation
import Testing
@testable import TchopPushNotifications

struct TchopPushNotificationsTests {
    @Test
    func deviceTokenFormatsAsLowercaseHex() {
        let token = APNsDeviceToken(data: Data([0xDE, 0xAD, 0xBE, 0xEF]))

        #expect(token.value == "deadbeef")
    }

    @Test
    func defaultParserExtractsAlertAndCustomData() {
        let parser = DefaultPushNotificationPayloadParser()
        let payload = parser.parse(
            userInfo: [
                "aps": [
                    "alert": [
                        "title": "Breaking",
                        "body": "Parrots help others in need, study shows for first time"
                    ],
                    "badge": 3,
                    "sound": "default"
                ],
                "route": "tchop://news/discussion/parrots",
                "articleID": 42
            ],
            source: .foreground
        )

        #expect(payload.title == "Breaking")
        #expect(payload.body == "Parrots help others in need, study shows for first time")
        #expect(payload.badge == 3)
        #expect(payload.sound == "default")
        #expect(payload.customData["route"] == "tchop://news/discussion/parrots")
        #expect(payload.customData["articleID"] == "42")
    }

    @Test
    func managerPersistsTokenAndOpenedPayload() async throws {
        let suiteName = "TchopPushNotificationsTests.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let store = UserDefaultsPushNotificationStateStore(userDefaults: userDefaults)
        let manager = PushNotificationManager(store: store)

        _ = try await manager.updateAuthorizationStatus(.authorized)
        _ = try await manager.handleDeviceToken(Data([0xAA, 0xBB]))
        let payload = try await manager.handleRemoteNotification(
            PushNotificationPayload(
                source: .opened,
                title: "Feed update",
                body: "Parrots help others...",
                badge: nil,
                sound: nil,
                customData: ["route": "tchop://news"]
            )
        )

        let reloadedManager = PushNotificationManager(store: store)
        let state = await reloadedManager.currentState()

        #expect(payload.title == "Feed update")
        #expect(state.authorizationStatus == .authorized)
        #expect(state.deviceToken?.value == "aabb")
        #expect(state.lastOpenedPayload?.customData["route"] == "tchop://news")
    }
}
