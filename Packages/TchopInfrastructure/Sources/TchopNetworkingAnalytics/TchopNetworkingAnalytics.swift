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
                    "method": .string(method),
                    "url": .string(url)
                ]
            )
        case let .requestSucceeded(statusCode, bytes, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "request_succeeded",
                attributes: [
                    "status_code": .int(statusCode),
                    "bytes": .int(bytes),
                    "url": .string(url)
                ]
            )
        case let .requestFailed(error, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "request_failed",
                attributes: [
                    "error": .string(String(describing: error)),
                    "url": .string(url)
                ]
            )
        case let .retryScheduled(error, attempt, delayNanoseconds, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "retry_scheduled",
                attributes: [
                    "error": .string(String(describing: error)),
                    "attempt": .int(attempt),
                    "delay_nanoseconds": .string(String(delayNanoseconds)),
                    "url": .string(url)
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
