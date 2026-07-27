import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Optional integration helper for projects that use both `AppAnalytics` and `AppNetworking`.
///
/// This helper intentionally lives outside both root packages so each package remains single-folder standalone.
///
/// Privacy:
/// The mapper never records raw error descriptions, HTTP bodies, headers, URL paths, query strings, or URL fragments.
/// It emits stable categories/codes suitable for production telemetry.
public enum APIMetricsAnalyticsEventMapper {
    public static func map(_ event: APIMetricsEvent) -> AnalyticsEvent {
        switch event {
        case let .requestPrepared(method, url):
            return AnalyticsEvent(
                domain: .networking,
                name: "request_prepared",
                attributes: [
                    "method": .string(method),
                    "url": .string(TelemetrySanitizer.redactedURL(url)),
                    "url_host": .string(TelemetrySanitizer.host(url))
                ]
            )
        case let .requestSucceeded(statusCode, bytes, url):
            return AnalyticsEvent(
                domain: .networking,
                name: "request_succeeded",
                attributes: [
                    "status_code": .int(statusCode),
                    "bytes": .int(bytes),
                    "url": .string(TelemetrySanitizer.redactedURL(url)),
                    "url_host": .string(TelemetrySanitizer.host(url))
                ]
            )
        case let .requestFailed(error, url):
            let descriptor = NetworkingTelemetryErrorDescriptor(error: error)
            return AnalyticsEvent(
                domain: .networking,
                name: "request_failed",
                attributes: descriptor.attributes.merging([
                    "url": .string(TelemetrySanitizer.redactedURL(url)),
                    "url_host": .string(TelemetrySanitizer.host(url))
                ], uniquingKeysWith: { current, _ in current })
            )
        case let .retryScheduled(error, attempt, delayNanoseconds, url):
            let descriptor = NetworkingTelemetryErrorDescriptor(error: error)
            return AnalyticsEvent(
                domain: .networking,
                name: "retry_scheduled",
                attributes: descriptor.attributes.merging([
                    "attempt": .int(attempt),
                    "delay_nanoseconds": .string(String(delayNanoseconds)),
                    "url": .string(TelemetrySanitizer.redactedURL(url)),
                    "url_host": .string(TelemetrySanitizer.host(url))
                ], uniquingKeysWith: { current, _ in current })
            )
        }
    }
}

/// Sanitized networking failure descriptor safe for telemetry.
public struct NetworkingTelemetryErrorDescriptor: Sendable, Equatable {
    public let category: String
    public let code: String
    public let statusCode: Int?
    public let isRetryable: Bool

    public init(error: APIError) {
        switch error {
        case .badURL:
            self.init(category: "client", code: "bad_url", statusCode: nil, isRetryable: false)
        case .noConnection:
            self.init(category: "network", code: "no_connection", statusCode: nil, isRetryable: true)
        case .invalidResponse:
            self.init(category: "client", code: "invalid_response", statusCode: nil, isRetryable: false)
        case let .httpFailure(failure):
            self.init(statusCode: failure.statusCode)
        case let .invalidStatusCode(statusCode):
            self.init(statusCode: statusCode)
        case .decodingFailed:
            self.init(category: "client", code: "decoding_failed", statusCode: nil, isRetryable: false)
        case .requestCancelled:
            self.init(category: "client", code: "request_cancelled", statusCode: nil, isRetryable: false)
        case .timeout:
            self.init(category: "network", code: "timeout", statusCode: nil, isRetryable: true)
        case .transportFailure:
            self.init(category: "transport", code: "transport_failure", statusCode: nil, isRetryable: true)
        }
    }

    private init(statusCode: Int) {
        let category: String
        let isRetryable: Bool

        switch statusCode {
        case 401, 403:
            category = "authentication"
            isRetryable = false
        case 408, 429:
            category = "network"
            isRetryable = true
        case 500...599:
            category = "server"
            isRetryable = true
        case 400...499:
            category = "client"
            isRetryable = false
        default:
            category = "http"
            isRetryable = false
        }

        self.init(
            category: category,
            code: "http_\(statusCode)",
            statusCode: statusCode,
            isRetryable: isRetryable
        )
    }

    private init(category: String, code: String, statusCode: Int?, isRetryable: Bool) {
        self.category = category
        self.code = code
        self.statusCode = statusCode
        self.isRetryable = isRetryable
    }

    public var attributes: [String: AnalyticsValue] {
        var attributes: [String: AnalyticsValue] = [
            "error_category": .string(category),
            "error_code": .string(code),
            "is_retryable": .bool(isRetryable)
        ]
        if let statusCode {
            attributes["status_code"] = .int(statusCode)
        }
        return attributes
    }
}

private enum TelemetrySanitizer {
    static func redactedURL(_ value: String) -> String {
        guard var components = URLComponents(string: value) else {
            return "invalid_url"
        }
        if !components.path.isEmpty {
            components.path = "/<redacted-path>"
        }
        components.query = nil
        components.fragment = nil
        return components.string ?? "invalid_url"
    }

    static func host(_ value: String) -> String {
        URLComponents(string: value)?.host ?? "unknown"
    }
}

/// Networking metrics collector that forwards events into the shared analytics layer.
public struct APIAnalyticsMetricsCollector: APIMetricsCollecting {
    private let collector: any AnalyticsCollecting

    public init(collector: any AnalyticsCollecting) {
        self.collector = collector
    }

    public func record(_ event: APIMetricsEvent) async {
        await collector.record(APIMetricsAnalyticsEventMapper.map(event))
    }
}
