import Foundation
import Testing
@testable import AppAnalytics

struct AppAnalyticsTests {
    @Test
    func eventPreservesTypedAttributes() {
        let event = AnalyticsEvent(
            domain: "demo",
            name: "button_tapped",
            attributes: [
                "title": .string("Continue"),
                "position": .int(2),
                "enabled": .bool(true),
                "duration": .double(1.5)
            ],
            recordedAt: Date(timeIntervalSince1970: 10)
        )

        #expect(event.domain == AnalyticsDomain(rawValue: "demo"))
        #expect(event.attributes["title"]?.stringValue == "Continue")
        #expect(event.attributes["position"]?.stringValue == "2")
        #expect(event.attributes["enabled"]?.stringValue == "true")
    }

    @Test
    func memoryCollectorStoresEventsInOrder() async {
        let collector = AnalyticsMemoryCollector()

        await collector.record(.init(domain: "demo", name: "first", attributes: [:]))
        await collector.record(.init(domain: "demo", name: "second", attributes: [:]))

        let events = await collector.events
        #expect(events.map(\.name) == ["first", "second"])
    }

    @Test
    func noopCollectorAcceptsEvents() async {
        let collector = AnalyticsNoopCollector()

        await collector.record(.init(domain: "demo", name: "ignored", attributes: [:]))

        #expect(Bool(true))
    }
}
