import XCTest
import TchopAnalytics
import TchopNavigation
import TchopNetworking
import TchopPushNotifications
@testable import TchopApp

/// Verifies analytics runtime wiring assembled by the app composition root.
@MainActor
final class AppDIContainerTests: XCTestCase {
    /// Verifies navigation reporter forwards runtime events into the shared analytics collector.
    func testNavigationReporterEmitsIntoSharedAnalyticsCollector() async {
        let container = AppDIContainer(databaseConfiguration: .inMemory)

        container.navigationEventReporter.report(
            .deepLinkRejected(url: "tchop://unsupported", reason: "unsupported-link")
        )

        try? await Task.sleep(for: .milliseconds(20))
        let events = await container.analyticsCollector.events

        XCTAssertTrue(
            events.contains(where: {
                $0.domain == .navigation && $0.name == "deep_link_rejected"
            })
        )
    }

    /// Verifies the real API manager emits networking analytics through its interceptor pipeline.
    func testAPIManagerEmitsIntoSharedAnalyticsCollector() async throws {
        let container = AppDIContainer(databaseConfiguration: .inMemory)

        let response = try await container.apiManager.perform(
            APIRequest(
                path: "analytics-networking-test",
                stubResponse: { 1 }
            )
        )

        let events = await waitForAnalyticsEvents(in: container.analyticsCollector, minimumCount: 2)

        XCTAssertEqual(response, 1)
        XCTAssertTrue(
            events.contains(where: {
                $0.domain == .networking && $0.name == "request_prepared"
            })
        )
        XCTAssertTrue(
            events.contains(where: {
                $0.domain == .networking && $0.name == "request_succeeded"
            })
        )
    }

    /// Verifies push bridge wiring emits push lifecycle events into the shared analytics collector.
    func testPushBridgeEmitsIntoSharedAnalyticsCollector() async {
        let container = AppDIContainer(databaseConfiguration: .inMemory)

        await container.pushNotificationBridge.didRegisterForRemoteNotifications(
            deviceToken: Data([0xAA, 0xBB])
        )
        await container.pushNotificationBridge.handleRemoteNotification(
            userInfo: [
                "aps": [
                    "alert": [
                        "title": "Feed update",
                        "body": "Parrots help others"
                    ]
                ],
                "route": "tchop://news"
            ],
            source: .foreground
        )

        let events = await container.analyticsCollector.events

        XCTAssertTrue(
            events.contains(where: {
                $0.domain == .pushNotifications && $0.name == "device_token_updated"
            })
        )
        XCTAssertTrue(
            events.contains(where: {
                $0.domain == .pushNotifications &&
                $0.name == "remote_notification_handled" &&
                $0.attributes["route"] == "tchop://news"
            })
        )
    }

    /// Waits until the shared analytics collector accumulates the expected number of events.
    private func waitForAnalyticsEvents(
        in collector: ProductAnalyticsMemoryCollector,
        minimumCount: Int,
        timeoutNanoseconds: UInt64 = 500_000_000
    ) async -> [ProductAnalyticsEvent] {
        let deadline = ContinuousClock.now + .nanoseconds(Int(timeoutNanoseconds))
        var latestEvents: [ProductAnalyticsEvent] = []

        while ContinuousClock.now < deadline {
            latestEvents = await collector.events
            if latestEvents.count >= minimumCount {
                return latestEvents
            }

            try? await Task.sleep(nanoseconds: 20_000_000)
        }

        return await collector.events
    }
}
