import AppAnalytics
import AppAnalyticsNetworkingIntegration
import AppNetworking
import XCTest

final class AppAnalyticsNetworkingIntegrationTests: XCTestCase {
    func testRequestFailureDoesNotExposeRawErrorBodyOrQueryTokens() {
        let body = Data("{\"token\":\"secret-token\",\"message\":\"private body\"}".utf8)
        let failure = APIHTTPFailure(statusCode: 500, body: body, headers: ["Authorization": "Bearer secret"])

        let event = APIMetricsAnalyticsEventMapper.map(
            .requestFailed(
                error: .httpFailure(failure),
                url: "https://api.example.com/users/42?token=secret-token#fragment"
            )
        )

        XCTAssertEqual(event.name, "request_failed")
        XCTAssertEqual(event.attributes["error_category"], .string("server"))
        XCTAssertEqual(event.attributes["error_code"], .string("http_500"))
        XCTAssertEqual(event.attributes["status_code"], .int(500))
        XCTAssertEqual(event.attributes["is_retryable"], AnalyticsValue.bool(true))
        XCTAssertEqual(event.attributes["url"], .string("https://api.example.com/users/42"))
        XCTAssertEqual(event.attributes["url_host"], .string("api.example.com"))

        let rendered = event.attributes.mapValues { $0.stringValue }.description
        XCTAssertFalse(rendered.contains("secret-token"))
        XCTAssertFalse(rendered.contains("private body"))
        XCTAssertFalse(rendered.contains("Authorization"))
        XCTAssertFalse(rendered.contains("fragment"))
    }

    func testRetryScheduledUsesSanitizedFailureCode() {
        let event = APIMetricsAnalyticsEventMapper.map(
            .retryScheduled(
                error: .transportFailure("URLSession failed for https://example.com?token=secret"),
                attempt: 2,
                delayNanoseconds: 1_000,
                url: "https://api.example.com/search?q=secret"
            )
        )

        XCTAssertEqual(event.attributes["error_category"], .string("transport"))
        XCTAssertEqual(event.attributes["error_code"], .string("transport_failure"))
        XCTAssertEqual(event.attributes["attempt"], .int(2))
        XCTAssertEqual(event.attributes["url"], .string("https://api.example.com/search"))

        let rendered = event.attributes.mapValues { $0.stringValue }.description
        XCTAssertFalse(rendered.contains("token=secret"))
        XCTAssertFalse(rendered.contains("q=secret"))
    }
}
