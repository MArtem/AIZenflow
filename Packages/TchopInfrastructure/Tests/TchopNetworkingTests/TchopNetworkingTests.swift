import XCTest
@testable import TchopNetworking

final class TchopNetworkingTests: XCTestCase {
    func testMockManagerReturnsStubbedValue() async throws {
        let manager = MockAPIManager()
        let request = APIRequest<String>(
            path: "feed",
            stubResponse: { "ok" }
        )

        let response = try await manager.perform(request)

        XCTAssertEqual(response, "ok")
    }

    func testCancellationTokenCancelsRequest() async {
        let manager = APIManager(configuration: .stub)
        let token = APICancellationToken()
        await token.cancel()

        let request = APIRequest<String>(
            path: "feed",
            stubResponse: {
                try await Task.sleep(nanoseconds: 50_000_000)
                return "ok"
            }
        )

        do {
            _ = try await manager.perform(request, cancellationToken: token)
            XCTFail("Expected request cancellation")
        } catch let error as APIError {
            XCTAssertEqual(error, .requestCancelled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
