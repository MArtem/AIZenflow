import XCTest
@testable import AppConfiguration

private struct TestUIConfigurationPayload: Codable, Equatable, Sendable {
    let flagEnabled: Bool
}

final class AppConfigurationTests: XCTestCase {
    func testInMemoryStoreSavesAndLoadsGenericSnapshot() async throws {
        let snapshot = makeSnapshot(flagEnabled: false)
        let store = InMemoryUIConfigurationSnapshotStore<TestUIConfigurationPayload>()

        try store.save(snapshot)

        XCTAssertEqual(try store.load(), snapshot)
    }

    func testManagerUsesStoredSnapshotBeforeRefresh() async throws {
        let storedSnapshot = makeSnapshot(flagEnabled: false)
        let remoteSnapshot = makeSnapshot(flagEnabled: true)
        let manager = UIConfigurationManager(
            remoteProvider: StaticUIConfigurationProvider(snapshot: remoteSnapshot),
            store: InMemoryUIConfigurationSnapshotStore(snapshot: storedSnapshot),
            fallbackSnapshot: makeSnapshot(flagEnabled: true)
        )

        let current = await manager.currentConfiguration()

        XCTAssertEqual(current, storedSnapshot)
    }

    func testManagerRefreshesAndStoresRemoteSnapshot() async throws {
        let remoteSnapshot = makeSnapshot(flagEnabled: true)
        let store = InMemoryUIConfigurationSnapshotStore<TestUIConfigurationPayload>()
        let manager = UIConfigurationManager(
            remoteProvider: StaticUIConfigurationProvider(snapshot: remoteSnapshot),
            store: store,
            fallbackSnapshot: makeSnapshot(flagEnabled: false)
        )

        let refreshed = try await manager.refreshConfiguration()

        XCTAssertEqual(refreshed, remoteSnapshot)
        XCTAssertEqual(try store.load(), remoteSnapshot)
    }

    func testStalenessPolicyUsesMetadataAge() async {
        let now = Date(timeIntervalSince1970: 1_000)
        let oldSnapshot = makeSnapshot(
            flagEnabled: false,
            fetchedAt: now.addingTimeInterval(-500)
        )
        let manager = UIConfigurationManager(
            remoteProvider: StaticUIConfigurationProvider(snapshot: makeSnapshot(flagEnabled: true)),
            store: InMemoryUIConfigurationSnapshotStore(snapshot: oldSnapshot),
            stalenessPolicy: .after(100),
            dateProvider: { now },
            fallbackSnapshot: makeSnapshot(flagEnabled: true)
        )

        let isStale = await manager.isCurrentConfigurationStale()

        XCTAssertTrue(isStale)
    }

    func testUnsupportedStoredSnapshotFallsBack() async {
        let fallbackSnapshot = makeSnapshot(flagEnabled: true)
        let unsupportedSnapshot = UIConfigurationSnapshot(
            metadata: UIConfigurationSnapshotMetadata(
                schemaVersion: UIConfigurationSnapshot<TestUIConfigurationPayload>.supportedSchemaVersion + 1,
                fetchedAt: .now,
                expirationDate: nil
            ),
            payload: TestUIConfigurationPayload(flagEnabled: false)
        )
        let manager = UIConfigurationManager(
            remoteProvider: StaticUIConfigurationProvider(snapshot: fallbackSnapshot),
            store: InMemoryUIConfigurationSnapshotStore(snapshot: unsupportedSnapshot),
            fallbackSnapshot: fallbackSnapshot
        )

        let current = await manager.currentConfiguration()

        XCTAssertEqual(current, fallbackSnapshot)
    }

    func testRefreshThrowsForUnsupportedRemoteSnapshot() async throws {
        let unsupportedSnapshot = UIConfigurationSnapshot(
            metadata: UIConfigurationSnapshotMetadata(
                schemaVersion: UIConfigurationSnapshot<TestUIConfigurationPayload>.supportedSchemaVersion + 1,
                fetchedAt: .now,
                expirationDate: nil
            ),
            payload: TestUIConfigurationPayload(flagEnabled: false)
        )
        let manager = UIConfigurationManager(
            remoteProvider: StaticUIConfigurationProvider(snapshot: unsupportedSnapshot),
            fallbackSnapshot: makeSnapshot(flagEnabled: true)
        )

        do {
            _ = try await manager.refreshConfiguration()
            XCTFail("Expected unsupported schema error")
        } catch let error as UIConfigurationManagerError {
            XCTAssertEqual(
                error,
                .unsupportedSchemaVersion(
                    actual: UIConfigurationSnapshot<TestUIConfigurationPayload>.supportedSchemaVersion + 1,
                    supported: UIConfigurationSnapshot<TestUIConfigurationPayload>.supportedSchemaVersion
                )
            )
        }
    }

    func testInMemoryStoreSupportsConcurrentAccess() async throws {
        let store = InMemoryUIConfigurationSnapshotStore<TestUIConfigurationPayload>()

        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0..<100 {
                group.addTask {
                    try store.save(
                        UIConfigurationSnapshot(
                            payload: TestUIConfigurationPayload(
                                flagEnabled: index.isMultiple(of: 2)
                            )
                        )
                    )
                    _ = try store.load()
                }
            }
            try await group.waitForAll()
        }

        XCTAssertNotNil(try store.load())
        try store.clear()
        XCTAssertNil(try store.load())
    }

    func testUserDefaultsStoreSupportsConcurrentAccess() async throws {
        let suiteName = "AppConfigurationTests.Concurrent.\(UUID().uuidString)"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
        let store = UserDefaultsUIConfigurationSnapshotStore<TestUIConfigurationPayload>(
            userDefaults: userDefaults
        )

        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0..<100 {
                group.addTask {
                    try store.save(
                        UIConfigurationSnapshot(
                            payload: TestUIConfigurationPayload(
                                flagEnabled: index.isMultiple(of: 2)
                            )
                        )
                    )
                    _ = try store.load()
                }
            }
            try await group.waitForAll()
        }

        XCTAssertNotNil(try store.load())
    }

    private func makeSnapshot(
        flagEnabled: Bool,
        fetchedAt: Date = Date(timeIntervalSince1970: 100)
    ) -> UIConfigurationSnapshot<TestUIConfigurationPayload> {
        UIConfigurationSnapshot(
            metadata: UIConfigurationSnapshotMetadata(
                schemaVersion: UIConfigurationSnapshot<TestUIConfigurationPayload>.supportedSchemaVersion,
                fetchedAt: fetchedAt,
                expirationDate: nil
            ),
            payload: TestUIConfigurationPayload(flagEnabled: flagEnabled)
        )
    }
}
