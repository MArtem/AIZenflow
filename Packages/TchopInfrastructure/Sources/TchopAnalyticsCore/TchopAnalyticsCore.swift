import Foundation

/// Stable top-level domains used by the shared analytics layer.
public enum ProductAnalyticsDomain: String, Codable, Equatable, Sendable {
    case navigation
    case networking
    case pushNotifications
}

/// Product-level analytics event shared across infrastructure modules.
public struct ProductAnalyticsEvent: Codable, Equatable, Sendable {
    public let domain: ProductAnalyticsDomain
    public let name: String
    public let attributes: [String: String]
    public let recordedAt: Date

    /// Creates a new product analytics event.
    public init(
        domain: ProductAnalyticsDomain,
        name: String,
        attributes: [String: String],
        recordedAt: Date = Date()
    ) {
        self.domain = domain
        self.name = name
        self.attributes = attributes
        self.recordedAt = recordedAt
    }
}

/// Sink contract used by analytics adapters across infrastructure modules.
public protocol ProductAnalyticsCollecting: Sendable {
    /// Records a product analytics event.
    func record(_ event: ProductAnalyticsEvent) async
}

/// In-memory collector useful for tests, debug overlays, and local inspection.
public actor ProductAnalyticsMemoryCollector: ProductAnalyticsCollecting {
    private var eventsStorage: [ProductAnalyticsEvent] = []

    /// Creates an empty analytics collector.
    public init() {}

    /// Recorded events in insertion order.
    public var events: [ProductAnalyticsEvent] {
        eventsStorage
    }

    /// Clears all recorded analytics events.
    public func reset() {
        eventsStorage.removeAll()
    }

    /// Records a product analytics event.
    public func record(_ event: ProductAnalyticsEvent) async {
        eventsStorage.append(event)
    }
}

/// Default no-op collector used when analytics is intentionally disabled.
public struct ProductAnalyticsNoopCollector: ProductAnalyticsCollecting {
    /// Creates a new no-op analytics collector.
    public init() {}

    /// Ignores the incoming analytics event.
    public func record(_ event: ProductAnalyticsEvent) async {}
}
