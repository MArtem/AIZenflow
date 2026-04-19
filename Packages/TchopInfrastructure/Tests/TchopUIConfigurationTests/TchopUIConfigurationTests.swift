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

    func testManagerReturnsFallbackSnapshotBeforeRefresh() async {
        let fallbackSnapshot = UIConfigurationSnapshot(
            shell: ShellUIConfiguration(showsFloatingActionButton: true)
        )
        let manager = UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(
                response: UIConfigurationSnapshot(
                    shell: ShellUIConfiguration(showsFloatingActionButton: false)
                ),
                delayNanoseconds: 0
            ),
            fallbackSnapshot: fallbackSnapshot
        )

        let currentSnapshot = await manager.currentConfiguration()

        XCTAssertEqual(currentSnapshot, fallbackSnapshot)
    }

    func testManagerRefreshPersistsSnapshotToStore() async throws {
        let snapshot = UIConfigurationSnapshot(
            shell: ShellUIConfiguration(showsFloatingActionButton: false)
        )
        let store = InMemoryUIConfigurationSnapshotStore()
        let manager = UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(
                response: snapshot,
                delayNanoseconds: 0
            ),
            store: store
        )

        let refreshedSnapshot = try await manager.refreshConfiguration()
        let persistedSnapshot = try store.load()

        XCTAssertEqual(refreshedSnapshot, snapshot)
        XCTAssertEqual(persistedSnapshot, snapshot)
    }

    func testManagerBootstrapsCurrentSnapshotFromStore() async {
        let snapshot = UIConfigurationSnapshot(
            shell: ShellUIConfiguration(showsFloatingActionButton: false)
        )
        let store = InMemoryUIConfigurationSnapshotStore(snapshot: snapshot)
        let manager = UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(delayNanoseconds: 0),
            store: store
        )

        let currentSnapshot = await manager.currentConfiguration()

        XCTAssertEqual(currentSnapshot, snapshot)
    }
}

private final class InMemoryUIConfigurationSnapshotStore: @unchecked Sendable, UIConfigurationSnapshotStoring {
    private var snapshot: UIConfigurationSnapshot?

    init(snapshot: UIConfigurationSnapshot? = nil) {
        self.snapshot = snapshot
    }

    func save(_ snapshot: UIConfigurationSnapshot) throws {
        self.snapshot = snapshot
    }

    func load() throws -> UIConfigurationSnapshot? {
        snapshot
    }

    func clear() throws {
        snapshot = nil
    }
}
