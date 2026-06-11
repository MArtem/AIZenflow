import XCTest
@testable import AppFeatureFlags

final class DefaultFeatureFlagManagerTests: XCTestCase {
    func testMissingFlagReturnsDefaultValue() async {
        let manager = DefaultFeatureFlagManager()
        let result = await manager.evaluation(for: "missing", defaultValue: .bool(true), context: FeatureFlagContext())

        XCTAssertTrue(result.isEnabled)
        XCTAssertEqual(result.value, .bool(true))
        XCTAssertEqual(result.source, .fallback)
        XCTAssertEqual(result.reason, .missingFlag)
    }

    func testDisabledFlagReturnsFalse() async throws {
        let key: FeatureFlagKey = "feature.disabled"
        let manager = DefaultFeatureFlagManager()
        try await manager.updateSnapshot(FeatureFlagSnapshot(flags: [
            key: FeatureFlag(key: key, isEnabled: false, value: .bool(true))
        ]))

        let enabled = await manager.isEnabled(key, default: true, context: FeatureFlagContext(stableIdentifier: "user"))
        XCTAssertFalse(enabled)
    }

    func testEnabledFlagReturnsStoredValue() async throws {
        let key: FeatureFlagKey = "feature.enabled"
        let manager = DefaultFeatureFlagManager()
        try await manager.updateSnapshot(FeatureFlagSnapshot(flags: [
            key: FeatureFlag(key: key, isEnabled: true, value: .string("new"))
        ]))

        let value = await manager.value(for: key, default: .string("old"), context: FeatureFlagContext(stableIdentifier: "user"))
        XCTAssertEqual(value, .string("new"))
    }

    func testLocalOverrideWinsOverSnapshot() async throws {
        let key: FeatureFlagKey = "feature.override"
        let manager = DefaultFeatureFlagManager()
        try await manager.updateSnapshot(FeatureFlagSnapshot(flags: [
            key: FeatureFlag(key: key, isEnabled: false, value: .bool(false))
        ]))
        try await manager.setOverride(.bool(true), for: key)

        let result = await manager.evaluation(for: key, defaultValue: .bool(false), context: FeatureFlagContext(stableIdentifier: "user"))
        XCTAssertTrue(result.isEnabled)
        XCTAssertEqual(result.source, .localOverride)
        XCTAssertEqual(result.reason, .localOverride)
    }

    func testRolloutZeroExcludesUser() async throws {
        let key: FeatureFlagKey = "feature.rollout.zero"
        let manager = DefaultFeatureFlagManager()
        try await manager.updateSnapshot(FeatureFlagSnapshot(flags: [
            key: FeatureFlag(key: key, isEnabled: true, value: .bool(true), rolloutPercentage: 0)
        ]))

        let result = await manager.evaluation(for: key, defaultValue: .bool(false), context: FeatureFlagContext(stableIdentifier: "user"))
        XCTAssertFalse(result.isEnabled)
        XCTAssertEqual(result.reason, .rolloutExcluded)
    }

    func testRolloutHundredIncludesUser() async throws {
        let key: FeatureFlagKey = "feature.rollout.full"
        let manager = DefaultFeatureFlagManager()
        try await manager.updateSnapshot(FeatureFlagSnapshot(flags: [
            key: FeatureFlag(key: key, isEnabled: true, value: .bool(true), rolloutPercentage: 100)
        ]))

        let result = await manager.evaluation(for: key, defaultValue: .bool(false), context: FeatureFlagContext(stableIdentifier: "user"))
        XCTAssertTrue(result.isEnabled)
        XCTAssertEqual(result.reason, .rolloutIncluded)
    }

    func testVariantSelectionIsStable() async throws {
        let key: FeatureFlagKey = "experiment.checkout"
        let manager = DefaultFeatureFlagManager()
        try await manager.updateSnapshot(FeatureFlagSnapshot(flags: [
            key: FeatureFlag(
                key: key,
                isEnabled: true,
                variants: [
                    FeatureFlagVariant(id: "control", value: .string("control"), weight: 50),
                    FeatureFlagVariant(id: "treatment", value: .string("treatment"), weight: 50)
                ]
            )
        ]))

        let context = FeatureFlagContext(stableIdentifier: "user-123")
        let first = await manager.variant(for: key, context: context)
        let second = await manager.variant(for: key, context: context)

        XCTAssertEqual(first, second)
        XCTAssertNotNil(first)
    }

    func testVariantStringOverrideSelectsMatchingVariant() async throws {
        let key: FeatureFlagKey = "experiment.override"
        let manager = DefaultFeatureFlagManager()
        try await manager.updateSnapshot(FeatureFlagSnapshot(flags: [
            key: FeatureFlag(
                key: key,
                isEnabled: true,
                variants: [
                    FeatureFlagVariant(id: "control", value: .string("control"), weight: 50),
                    FeatureFlagVariant(id: "treatment", value: .string("treatment"), weight: 50)
                ]
            )
        ]))
        try await manager.setOverride(.string("treatment"), for: key)

        let variant = await manager.variant(for: key, context: FeatureFlagContext(stableIdentifier: "user"))
        XCTAssertEqual(variant?.id, "treatment")
    }

    func testRemoveOverrideFallsBackToSnapshot() async throws {
        let key: FeatureFlagKey = "feature.remove-override"
        let manager = DefaultFeatureFlagManager()
        try await manager.updateSnapshot(FeatureFlagSnapshot(flags: [
            key: FeatureFlag(key: key, isEnabled: true, value: .bool(false))
        ]))
        try await manager.setOverride(.bool(true), for: key)
        try await manager.removeOverride(for: key)

        let enabled = await manager.isEnabled(key, default: false, context: FeatureFlagContext(stableIdentifier: "user"))
        XCTAssertFalse(enabled)
    }

    func testEmptyOverrideKeyThrows() async {
        let manager = DefaultFeatureFlagManager()
        do {
            try await manager.setOverride(.bool(true), for: FeatureFlagKey(rawValue: ""))
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? FeatureFlagError, .emptyKey)
        }
    }
}

private struct ThrowingFeatureFlagSnapshotStore: FeatureFlagSnapshotStoring {
    func loadSnapshot() async throws -> FeatureFlagSnapshot? { throw FeatureFlagError.emptyKey }
    func saveSnapshot(_ snapshot: FeatureFlagSnapshot) async throws { throw FeatureFlagError.emptyKey }
    func removeSnapshot() async throws { throw FeatureFlagError.emptyKey }
}

private struct ThrowingFeatureFlagOverrideStore: FeatureFlagOverrideStoring {
    func override(for key: FeatureFlagKey) async throws -> FeatureFlagValue? { throw FeatureFlagError.emptyKey }
    func setOverride(_ value: FeatureFlagValue, for key: FeatureFlagKey) async throws { throw FeatureFlagError.emptyKey }
    func removeOverride(for key: FeatureFlagKey) async throws { throw FeatureFlagError.emptyKey }
    func removeAllOverrides() async throws { throw FeatureFlagError.emptyKey }
}

extension DefaultFeatureFlagManagerTests {
    func testEvaluationReportsSnapshotStoreFailureWithoutThrowing() async {
        let manager = DefaultFeatureFlagManager(
            snapshotStore: ThrowingFeatureFlagSnapshotStore(),
            overrideStore: InMemoryFeatureFlagOverrideStore()
        )

        let result = await manager.evaluation(
            for: "feature.unavailable-store",
            defaultValue: .bool(false),
            context: FeatureFlagContext(stableIdentifier: "stable")
        )

        XCTAssertEqual(result.reason, .snapshotStoreUnavailable)
        XCTAssertEqual(result.source, .fallback)
        XCTAssertFalse(result.isEnabled)
    }

    func testEvaluationReportsOverrideStoreFailureWithoutFallingThroughSilently() async {
        let manager = DefaultFeatureFlagManager(
            snapshotStore: InMemoryFeatureFlagSnapshotStore(),
            overrideStore: ThrowingFeatureFlagOverrideStore()
        )

        let result = await manager.evaluation(
            for: "feature.unavailable-override-store",
            defaultValue: .bool(false),
            context: FeatureFlagContext(stableIdentifier: "stable")
        )

        XCTAssertEqual(result.reason, .overrideStoreUnavailable)
        XCTAssertEqual(result.source, .fallback)
        XCTAssertFalse(result.isEnabled)
    }
}
