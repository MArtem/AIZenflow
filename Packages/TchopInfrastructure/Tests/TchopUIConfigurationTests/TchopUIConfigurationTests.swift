import XCTest
@testable import TchopUIConfiguration

final class TchopUIConfigurationTests: XCTestCase {
    func testMockProviderReturnsConfiguredSnapshot() async throws {
        let snapshot = UIConfigurationSnapshot(
            shell: ShellUIConfiguration(showsFloatingActionButton: false)
        )
        let manager = UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(
                response: snapshot,
                delayNanoseconds: 0
            )
        )

        let result = try await manager.fetchConfiguration()

        XCTAssertEqual(result, snapshot)
    }
}
