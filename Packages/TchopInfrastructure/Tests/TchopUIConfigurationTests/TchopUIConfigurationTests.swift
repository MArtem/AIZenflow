import XCTest
@testable import TchopUIConfiguration

final class TchopUIConfigurationTests: XCTestCase {
    /// Verifies mock provider returns configured snapshot.
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

    /// Verifies manager returns fallback snapshot before refresh.
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

    /// Verifies manager refresh persists snapshot to store.
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

    /// Verifies manager bootstraps current snapshot from store.
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

    /// Creates a new InMemoryUIConfigurationSnapshotStore instance.
    init(snapshot: UIConfigurationSnapshot? = nil) {
        self.snapshot = snapshot
    }

    /// Saves this operation.
    func save(_ snapshot: UIConfigurationSnapshot) throws {
        self.snapshot = snapshot
    }

    /// Loads this operation.
    func load() throws -> UIConfigurationSnapshot? {
        snapshot
    }

    /// Clears this operation.
    func clear() throws {
        snapshot = nil
    }
}
