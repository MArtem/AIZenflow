import Foundation
import Testing
import AppNavigation
import AppNetworking
import AppPushNotifications
@testable import AppAnalytics

/// Verifies analytics event mapping across infrastructure domains.
struct AppAnalyticsTests {
    @Test
    /// Maps a navigation event into the shared analytics surface.
    @MainActor
    func navigationMapperProducesExpectedProductEvent() {
        let event = NavigationAnalyticsEventMapper.map(
            .deepLinkHandled(
                url: "app://news/article/42",
                destination: "news.article",
                policy: .push
            )
        )

        #expect(event.domain == .navigation)
        #expect(event.name == "deep_link_handled")
        #expect(event.attributes["url"] == .string("app://news/article/42"))
        #expect(event.attributes["destination"] == .string("news.article"))
        #expect(event.attributes["policy"] == .string("push"))
    }

    @Test
    /// Maps a networking metrics event into the shared analytics surface.
    func apiMetricsMapperProducesExpectedProductEvent() {
        let event = APIMetricsAnalyticsEventMapper.map(
            .requestSucceeded(
                statusCode: 200,
                bytes: 512,
                url: "https://stub.local/feed"
            )
        )

        #expect(event.domain == .networking)
        #expect(event.name == "request_succeeded")
        #expect(event.attributes["status_code"] == .int(200))
        #expect(event.attributes["bytes"] == .int(512))
    }

    @Test
    /// Maps a push lifecycle event into the shared analytics surface.
    func pushMapperProducesExpectedProductEvent() {
        let event = PushNotificationAnalyticsEventMapper.map(
            .remoteNotificationHandled(
                source: .opened,
                route: "app://news",
                title: "Feed update"
            )
        )

        #expect(event.domain == .pushNotifications)
        #expect(event.name == "remote_notification_handled")
        #expect(event.attributes["source"] == .string("opened"))
        #expect(event.attributes["route"] == .string("app://news"))
        #expect(event.attributes["title"] == .string("Feed update"))
    }

    @Test
    /// Forwards navigation reports into the shared analytics collector.
    @MainActor
    func navigationReporterForwardsMappedEvents() async {
        let collector = ProductAnalyticsMemoryCollector()
        let reporter = NavigationAnalyticsEventReporter(collector: collector)

        reporter.report(.deepLinkRejected(url: "app://unknown", reason: "unsupported-link"))

        try? await Task.sleep(for: .milliseconds(20))
        let events = await collector.events

        #expect(events.count == 1)
        #expect(events.first?.domain == .navigation)
        #expect(events.first?.name == "deep_link_rejected")
    }

    @Test
    /// Forwards networking metrics into the shared analytics collector.
    func apiAnalyticsCollectorForwardsMappedEvents() async {
        let collector = ProductAnalyticsMemoryCollector()
        let analyticsCollector = APIAnalyticsMetricsCollector(collector: collector)

        await analyticsCollector.record(.requestPrepared(method: "GET", url: "https://stub.local/feed"))
        let events = await collector.events

        #expect(events.count == 1)
        #expect(events.first?.domain == .networking)
        #expect(events.first?.name == "request_prepared")
    }

    @Test
    /// Forwards push lifecycle events into the shared analytics collector.
    func pushAnalyticsCollectorForwardsMappedEvents() async {
        let collector = ProductAnalyticsMemoryCollector()
        let analyticsCollector = PushNotificationAnalyticsCollector(collector: collector)

        await analyticsCollector.record(.stateCleared)
        let events = await collector.events

        #expect(events.count == 1)
        #expect(events.first?.domain == .pushNotifications)
        #expect(events.first?.name == "state_cleared")
    }
}
