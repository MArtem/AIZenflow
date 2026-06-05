import AppErrors
import AppErrorsNetworkingIntegration
import AppNetworking
import XCTest

final class AppErrorsNetworkingIntegrationTests: XCTestCase {
    func testHTTPFailureMapsToRetryableServerErrorWithoutBodyLeak() {
        let failure = APIHTTPFailure(statusCode: 503, body: Data("secret backend body".utf8), headers: [:])
        let mapper = APIErrorAppErrorMapper()

        let appError = mapper.map(failure)

        XCTAssertEqual(appError.category, .server)
        XCTAssertEqual(appError.suggestion, .retry)
        XCTAssertTrue(appError.isRetryable)
        XCTAssertFalse(appError.debugDescription.contains("secret backend body"))
    }
}
