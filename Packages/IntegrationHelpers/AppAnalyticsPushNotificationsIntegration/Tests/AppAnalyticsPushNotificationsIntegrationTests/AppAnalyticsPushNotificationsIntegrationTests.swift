import AppAnalytics
import AppAnalyticsPushNotificationsIntegration
import AppPushNotifications
import XCTest

final class AppAnalyticsPushNotificationsIntegrationTests: XCTestCase {
    func testRemoteNotificationDoesNotExposeTitle() {
        let event = PushNotificationAnalyticsEventMapper.map(
            .remoteNotificationHandled(source: .opened, route: "article/123?token=secret", title: "Private notification title")
        )

        XCTAssertEqual(event.name, "remote_notification_handled")
        XCTAssertEqual(event.attributes["has_title"], AnalyticsValue.bool(true))
        XCTAssertNil(event.attributes["title"])
        XCTAssertNotNil(event.attributes["route_code"])

        let rendered = event.attributes.mapValues { $0.stringValue }.description
        XCTAssertFalse(rendered.contains("Private notification title"))
        XCTAssertFalse(rendered.contains("token=secret"))
    }
}
