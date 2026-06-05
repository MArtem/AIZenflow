import AppAnalytics
import AppAnalyticsNavigationIntegration
import AppNavigation
import XCTest

@MainActor
final class AppAnalyticsNavigationIntegrationTests: XCTestCase {
    func testDeepLinkDoesNotExposeQueryOrFragment() {
        let event = NavigationAnalyticsEventMapper.map(
            .deepLinkHandled(
                url: "myapp://article/42?token=secret#private",
                destination: "article_detail",
                policy: .push
            )
        )

        XCTAssertEqual(event.attributes["url"], .string("myapp://article/42"))
        let rendered = event.attributes.mapValues { $0.stringValue }.description
        XCTAssertFalse(rendered.contains("token=secret"))
        XCTAssertFalse(rendered.contains("private"))
    }
}
