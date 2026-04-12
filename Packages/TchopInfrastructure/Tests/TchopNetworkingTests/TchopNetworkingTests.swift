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

    func testAuthenticationInterceptorInjectsHeaders() async throws {
        let interceptor = APIAuthenticationInterceptor(
            provider: TestAuthenticationProvider(headers: ["Authorization": "Bearer token"])
        )
        let request = URLRequest(url: URL(string: "https://example.com")!)

        let preparedRequest = try await interceptor.prepare(request)

        XCTAssertEqual(preparedRequest.value(forHTTPHeaderField: "Authorization"), "Bearer token")
    }

    func testOfflineQueueDrainsOnlyWhenConnected() async {
        let queue = APIOfflineRequestQueue()
        let recorder = InvocationRecorder()

        await queue.enqueue {
            await recorder.recordInvocation()
        }

        await queue.drainIfConnected(using: StaticConnectivityProvider(connected: false))
        let afterDisconnectedDrain = await recorder.invocationCount
        XCTAssertEqual(afterDisconnectedDrain, 0)

        await queue.drainIfConnected(using: StaticConnectivityProvider(connected: true))
        let afterConnectedDrain = await recorder.invocationCount
        let remainingOperations = await queue.pendingRequestCount

        XCTAssertEqual(afterConnectedDrain, 1)
        XCTAssertEqual(remainingOperations, 0)
    }

    func testMockManagerDownloadWritesStubbedData() async throws {
        let manager = MockAPIManager()
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let request = APIRequest<Data>(
            path: "download",
            stubResponse: { Data("payload".utf8) }
        )

        let fileURL = try await manager.download(
            request,
            destinationURL: destinationURL,
            progressHandler: nil
        )

        let data = try Data(contentsOf: fileURL)
        XCTAssertEqual(String(decoding: data, as: UTF8.self), "payload")
    }
}

private struct TestAuthenticationProvider: APIAuthenticationProviding {
    let headers: [String: String]

    func authorizationHeaders() async throws -> [String: String] {
        headers
    }
}

private actor InvocationRecorder {
    private(set) var invocationCount = 0

    func recordInvocation() {
        invocationCount += 1
    }
}
