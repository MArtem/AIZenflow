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

    /// Verifies manager reports stale snapshot when staleness interval expires.
    func testManagerReportsCurrentSnapshotAsStaleAfterConfiguredInterval() async {
        let now = Date(timeIntervalSince1970: 2_000)
        let snapshot = UIConfigurationSnapshot(
            metadata: UIConfigurationSnapshotMetadata(
                schemaVersion: UIConfigurationSnapshot.supportedSchemaVersion,
                fetchedAt: now.addingTimeInterval(-120),
                expirationDate: nil
            ),
            shell: ShellUIConfiguration(showsFloatingActionButton: false)
        )
        let manager = UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(delayNanoseconds: 0),
            store: InMemoryUIConfigurationSnapshotStore(snapshot: snapshot),
            stalenessPolicy: .after(60),
            dateProvider: { now }
        )

        let isStale = await manager.isCurrentConfigurationStale()

        XCTAssertTrue(isStale)
    }

    /// Verifies manager ignores throttling and refreshes when current snapshot is stale.
    func testManagerRefreshIgnoresThrottleWhenSnapshotIsStale() async throws {
        let now = Date(timeIntervalSince1970: 3_000)
        let staleSnapshot = UIConfigurationSnapshot(
            metadata: UIConfigurationSnapshotMetadata(
                schemaVersion: UIConfigurationSnapshot.supportedSchemaVersion,
                fetchedAt: now.addingTimeInterval(-120),
                expirationDate: nil
            ),
            shell: ShellUIConfiguration(showsFloatingActionButton: false)
        )
        let freshSnapshot = UIConfigurationSnapshot(
            metadata: UIConfigurationSnapshotMetadata(
                schemaVersion: UIConfigurationSnapshot.supportedSchemaVersion,
                fetchedAt: now,
                expirationDate: nil
            ),
            shell: ShellUIConfiguration(showsFloatingActionButton: true)
        )
        let manager = UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(
                response: freshSnapshot,
                delayNanoseconds: 0
            ),
            store: InMemoryUIConfigurationSnapshotStore(snapshot: staleSnapshot),
            stalenessPolicy: .after(60),
            refreshThrottling: .minimumInterval(300),
            dateProvider: { now }
        )

        let refreshedSnapshot = try await manager.refreshConfiguration()

        XCTAssertEqual(refreshedSnapshot, freshSnapshot)
    }

    /// Verifies manager reuses current snapshot when throttling blocks a fresh remote hit.
    func testManagerRefreshReturnsCurrentSnapshotWhenThrottleBlocksFetch() async throws {
        let now = Date(timeIntervalSince1970: 4_000)
        let currentSnapshot = UIConfigurationSnapshot(
            metadata: UIConfigurationSnapshotMetadata(
                schemaVersion: UIConfigurationSnapshot.supportedSchemaVersion,
                fetchedAt: now.addingTimeInterval(-10),
                expirationDate: nil
            ),
            shell: ShellUIConfiguration(showsFloatingActionButton: false)
        )
        let remoteSnapshot = UIConfigurationSnapshot(
            metadata: UIConfigurationSnapshotMetadata(
                schemaVersion: UIConfigurationSnapshot.supportedSchemaVersion,
                fetchedAt: now,
                expirationDate: nil
            ),
            shell: ShellUIConfiguration(showsFloatingActionButton: true)
        )
        let manager = UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(
                response: remoteSnapshot,
                delayNanoseconds: 0
            ),
            store: InMemoryUIConfigurationSnapshotStore(snapshot: currentSnapshot),
            stalenessPolicy: .after(120),
            refreshThrottling: .minimumInterval(60),
            dateProvider: { now }
        )

        let refreshedSnapshot = try await manager.refreshConfiguration()

        XCTAssertEqual(refreshedSnapshot, currentSnapshot)
    }

    /// Verifies manager falls back when persisted snapshot has unsupported schema.
    func testManagerFallsBackWhenStoredSnapshotHasUnsupportedSchema() async {
        let fallbackSnapshot = UIConfigurationSnapshot(
            shell: ShellUIConfiguration(showsFloatingActionButton: true)
        )
        let unsupportedSnapshot = UIConfigurationSnapshot(
            metadata: UIConfigurationSnapshotMetadata(
                schemaVersion: UIConfigurationSnapshot.supportedSchemaVersion + 1,
                fetchedAt: Date(),
                expirationDate: nil
            ),
            shell: ShellUIConfiguration(showsFloatingActionButton: false)
        )
        let manager = UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(delayNanoseconds: 0),
            store: InMemoryUIConfigurationSnapshotStore(snapshot: unsupportedSnapshot),
            fallbackSnapshot: fallbackSnapshot
        )

        let currentSnapshot = await manager.currentConfiguration()

        XCTAssertEqual(currentSnapshot, fallbackSnapshot)
    }

    /// Verifies manager rejects unsupported remote snapshot schema versions.
    func testManagerRejectsUnsupportedRemoteSnapshotSchema() async {
        let unsupportedSnapshot = UIConfigurationSnapshot(
            metadata: UIConfigurationSnapshotMetadata(
                schemaVersion: UIConfigurationSnapshot.supportedSchemaVersion + 1,
                fetchedAt: Date(),
                expirationDate: nil
            ),
            shell: ShellUIConfiguration(showsFloatingActionButton: false)
        )
        let manager = UIConfigurationManager(
            remoteProvider: MockUIConfigurationRemoteProvider(
                response: unsupportedSnapshot,
                delayNanoseconds: 0
            )
        )

        await XCTAssertThrowsErrorAsync({ try await manager.refreshConfiguration() }) { error in
            XCTAssertEqual(
                error as? UIConfigurationManagerError,
                .unsupportedSchemaVersion(
                    actual: UIConfigurationSnapshot.supportedSchemaVersion + 1,
                    supported: UIConfigurationSnapshot.supportedSchemaVersion
                )
            )
        }
    }
}

/// Asserts an async throwing expression raises an error that matches expectations.
private func XCTAssertThrowsErrorAsync<T>(
    _ expression: () async throws -> T,
    _ errorHandler: (Error) -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected expression to throw", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
