import XCTest
@testable import AppFeatureFlags

final class FeatureFlagStorageTests: XCTestCase {
    func testSnapshotStoreSavesLoadsAndRemovesSnapshot() async throws {
        let store = InMemoryFeatureFlagSnapshotStore()
        let key: FeatureFlagKey = "feature.a"
        let snapshot = FeatureFlagSnapshot(flags: [key: FeatureFlag(key: key, isEnabled: true)])

        try await store.saveSnapshot(snapshot)
        let loadedSnapshot = try await store.loadSnapshot()
        XCTAssertEqual(loadedSnapshot, snapshot)

        try await store.removeSnapshot()
        let removedSnapshot = try await store.loadSnapshot()
        XCTAssertNil(removedSnapshot)
    }

    func testOverrideStoreSavesLoadsAndRemovesOverride() async throws {
        let store = InMemoryFeatureFlagOverrideStore()
        let key: FeatureFlagKey = "feature.a"

        try await store.setOverride(.bool(true), for: key)
        let loadedOverride = try await store.override(for: key)
        XCTAssertEqual(loadedOverride, .bool(true))

        try await store.removeOverride(for: key)
        let removedOverride = try await store.override(for: key)
        XCTAssertNil(removedOverride)
    }

    func testSnapshotStoreRejectsInvalidRolloutPercentage() async {
        let store = InMemoryFeatureFlagSnapshotStore()
        let key: FeatureFlagKey = "feature.invalid-rollout"
        let snapshot = FeatureFlagSnapshot(flags: [
            key: FeatureFlag(key: key, isEnabled: true, rolloutPercentage: 150)
        ])

        do {
            try await store.saveSnapshot(snapshot)
            XCTFail("Expected invalid rollout error")
        } catch {
            XCTAssertEqual(error as? FeatureFlagError, .invalidRolloutPercentage(150))
        }
    }

    func testSnapshotStoreRejectsMismatchedDictionaryKey() async {
        let store = InMemoryFeatureFlagSnapshotStore()
        let dictionaryKey: FeatureFlagKey = "feature.dictionary"
        let flagKey: FeatureFlagKey = "feature.payload"
        let snapshot = FeatureFlagSnapshot(flags: [
            dictionaryKey: FeatureFlag(key: flagKey, isEnabled: true)
        ])

        do {
            try await store.saveSnapshot(snapshot)
            XCTFail("Expected mismatched key error")
        } catch {
            XCTAssertEqual(error as? FeatureFlagError, .mismatchedSnapshotKey(expected: dictionaryKey, actual: flagKey))
        }
    }

    func testUserDefaultsSnapshotStorePersistsSnapshotAcrossInstances() async throws {
        let suiteName = "AppFeatureFlagsTests.snapshot.\(UUID().uuidString)"
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        let key: FeatureFlagKey = "feature.persisted"
        let snapshot = FeatureFlagSnapshot(flags: [
            key: FeatureFlag(key: key, isEnabled: true, value: .string("enabled"))
        ])

        let writer = try UserDefaultsFeatureFlagSnapshotStore(suiteName: suiteName)
        try await writer.saveSnapshot(snapshot)

        let reader = try UserDefaultsFeatureFlagSnapshotStore(suiteName: suiteName)
        let loadedSnapshot = try await reader.loadSnapshot()

        XCTAssertEqual(loadedSnapshot, snapshot)
    }

    func testUserDefaultsOverrideStorePersistsAndClearsOverrides() async throws {
        let suiteName = "AppFeatureFlagsTests.overrides.\(UUID().uuidString)"
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        let key: FeatureFlagKey = "feature.override.persisted"
        let writer = try UserDefaultsFeatureFlagOverrideStore(suiteName: suiteName)
        try await writer.setOverride(.bool(true), for: key)

        let reader = try UserDefaultsFeatureFlagOverrideStore(suiteName: suiteName)
        let loadedOverride = try await reader.override(for: key)
        XCTAssertEqual(loadedOverride, .bool(true))

        try await reader.removeAllOverrides()
        let removedOverride = try await writer.override(for: key)
        XCTAssertNil(removedOverride)
    }
}
