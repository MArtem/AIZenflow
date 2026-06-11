import Foundation

/// Extensible top-level domain identifier used by the shared analytics layer.
public struct AnalyticsDomain: RawRepresentable, Codable, Hashable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    /// Creates a new analytics domain.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a new analytics domain from a string literal.
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }

    public static let navigation = AnalyticsDomain(rawValue: "navigation")
    public static let networking = AnalyticsDomain(rawValue: "networking")
    public static let pushNotifications = AnalyticsDomain(rawValue: "push_notifications")
}

/// Backward-compatible typealias for older callers.
@available(*, deprecated, renamed: "AnalyticsDomain")
public typealias ProductAnalyticsDomain = AnalyticsDomain

/// Typed analytics attribute value that preserves primitive semantics until the app adapter serializes the event.
public enum AnalyticsValue: Codable, Equatable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    /// String representation suitable for legacy providers that only accept string attributes.
    public var stringValue: String {
        switch self {
        case let .string(value):
            return value
        case let .int(value):
            return String(value)
        case let .double(value):
            return String(value)
        case let .bool(value):
            return String(value)
        }
    }
}

extension AnalyticsValue: ExpressibleByStringLiteral {
    /// Creates a string analytics value from a string literal.
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension AnalyticsValue: ExpressibleByIntegerLiteral {
    /// Creates an integer analytics value from an integer literal.
    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension AnalyticsValue: ExpressibleByFloatLiteral {
    /// Creates a double analytics value from a float literal.
    public init(floatLiteral value: FloatLiteralType) {
        self = .double(value)
    }
}

extension AnalyticsValue: ExpressibleByBooleanLiteral {
    /// Creates a boolean analytics value from a boolean literal.
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

/// Generic analytics event shared across infrastructure modules.
///
/// The historical `ProductAnalyticsEvent` name is kept for source compatibility. New code can use
/// the `AnalyticsEvent` typealias below to avoid product-specific naming in reusable packages.
public struct ProductAnalyticsEvent: Codable, Equatable, Sendable {
    public let domain: AnalyticsDomain
    public let name: String
    public let attributes: [String: AnalyticsValue]
    public let recordedAt: Date

    /// Creates a new product analytics event.
    public init(
        domain: AnalyticsDomain,
        name: String,
        attributes: [String: AnalyticsValue],
        recordedAt: Date = Date()
    ) {
        self.domain = domain
        self.name = name
        self.attributes = attributes
        self.recordedAt = recordedAt
    }

    /// Creates a new event from legacy string-only attributes.
    public init(
        domain: AnalyticsDomain,
        name: String,
        stringAttributes: [String: String],
        recordedAt: Date = Date()
    ) {
        self.init(
            domain: domain,
            name: name,
            attributes: stringAttributes.mapValues(AnalyticsValue.string),
            recordedAt: recordedAt
        )
    }
}

/// Preferred neutral event name for reusable package callers.
public typealias AnalyticsEvent = ProductAnalyticsEvent

/// Sink contract used by analytics adapters across infrastructure modules.
public protocol ProductAnalyticsCollecting: Sendable {
    /// Records a product analytics event.
    func record(_ event: ProductAnalyticsEvent) async
}

/// Preferred neutral collector name for reusable package callers.
public typealias AnalyticsCollecting = ProductAnalyticsCollecting

/// In-memory collector useful for tests, debug overlays, and local inspection.
/// Preferred neutral memory collector name for reusable package callers.
public typealias AnalyticsMemoryCollector = ProductAnalyticsMemoryCollector

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

/// Preferred neutral no-op collector name for reusable package callers.
public typealias AnalyticsNoopCollector = ProductAnalyticsNoopCollector
