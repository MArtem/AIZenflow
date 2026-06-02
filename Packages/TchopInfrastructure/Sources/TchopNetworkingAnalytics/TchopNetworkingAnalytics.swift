import TchopAnalyticsCore
import TchopNetworking

/// Maps networking metrics into shared product analytics events.
public enum APIMetricsAnalyticsEventMapper {
    /// Maps a networking metrics event into the shared analytics format.
    public static func map(_ event: APIMetricsEvent) -> ProductAnalyticsEvent {
        switch event {
        case let .requestPrepared(method, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "request_prepared",
                attributes: [
                    "method": method,
                    "url": url
                ]
            )
        case let .requestSucceeded(statusCode, bytes, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "request_succeeded",
                attributes: [
                    "status_code": String(statusCode),
                    "bytes": String(bytes),
                    "url": url
                ]
            )
        case let .requestFailed(error, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "request_failed",
                attributes: [
                    "error": String(describing: error),
                    "url": url
                ]
            )
        case let .retryScheduled(error, attempt, delayNanoseconds, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "retry_scheduled",
                attributes: [
                    "error": String(describing: error),
                    "attempt": String(attempt),
                    "delay_nanoseconds": String(delayNanoseconds),
                    "url": url
                ]
            )
        }
    }
}

/// Networking metrics collector that forwards events into the shared analytics layer.
public struct APIAnalyticsMetricsCollector: APIMetricsCollecting {
    private let collector: any ProductAnalyticsCollecting

    /// Creates a new analytics-backed networking collector.
    public init(collector: any ProductAnalyticsCollecting) {
        self.collector = collector
    }

    /// Records a networking metrics event through the shared analytics layer.
    public func record(_ event: APIMetricsEvent) async {
        await collector.record(APIMetricsAnalyticsEventMapper.map(event))
    }
}
