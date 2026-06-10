import Foundation

public enum FeatureFlagError: Error, Equatable, Sendable {
    case emptyKey
    case invalidRolloutPercentage(Double)
    case mismatchedSnapshotKey(expected: FeatureFlagKey, actual: FeatureFlagKey)
    case userDefaultsSuiteUnavailable(String)
}

public protocol FeatureFlagManaging: Sendable {
    func evaluation(
        for key: FeatureFlagKey,
        defaultValue: FeatureFlagValue,
        context: FeatureFlagContext
    ) async -> FeatureFlagEvaluation

    func isEnabled(
        _ key: FeatureFlagKey,
        default defaultValue: Bool,
        context: FeatureFlagContext
    ) async -> Bool

    func value(
        for key: FeatureFlagKey,
        default defaultValue: FeatureFlagValue,
        context: FeatureFlagContext
    ) async -> FeatureFlagValue

    func variant(
        for key: FeatureFlagKey,
        context: FeatureFlagContext
    ) async -> FeatureFlagVariant?

    func updateSnapshot(_ snapshot: FeatureFlagSnapshot) async throws
    func removeSnapshot() async throws
    func setOverride(_ value: FeatureFlagValue, for key: FeatureFlagKey) async throws
    func removeOverride(for key: FeatureFlagKey) async throws
    func removeAllOverrides() async throws
}

public actor DefaultFeatureFlagManager: FeatureFlagManaging {
    private let snapshotStore: FeatureFlagSnapshotStoring
    private let overrideStore: FeatureFlagOverrideStoring
    private let bucketer: FeatureFlagBucketing

    public init(
        snapshotStore: FeatureFlagSnapshotStoring = InMemoryFeatureFlagSnapshotStore(),
        overrideStore: FeatureFlagOverrideStoring = InMemoryFeatureFlagOverrideStore(),
        bucketer: FeatureFlagBucketing = StableFeatureFlagBucketer()
    ) {
        self.snapshotStore = snapshotStore
        self.overrideStore = overrideStore
        self.bucketer = bucketer
    }

    public func evaluation(
        for key: FeatureFlagKey,
        defaultValue: FeatureFlagValue,
        context: FeatureFlagContext = FeatureFlagContext()
    ) async -> FeatureFlagEvaluation {
        guard !key.isEmpty else {
            return FeatureFlagEvaluation(
                key: key,
                value: defaultValue,
                isEnabled: defaultValue.boolValue ?? false,
                source: .fallback,
                reason: .keyIsEmpty
            )
        }

        do {
            if let override = try await overrideStore.override(for: key) {
                return FeatureFlagEvaluation(
                    key: key,
                    value: override,
                    isEnabled: override.boolValue ?? true,
                    source: .localOverride,
                    reason: .localOverride
                )
            }
        } catch {
            return FeatureFlagEvaluation(
                key: key,
                value: defaultValue,
                isEnabled: defaultValue.boolValue ?? false,
                source: .fallback,
                reason: .overrideStoreUnavailable
            )
        }

        let snapshot: FeatureFlagSnapshot?
        do {
            snapshot = try await snapshotStore.loadSnapshot()
        } catch {
            return FeatureFlagEvaluation(
                key: key,
                value: defaultValue,
                isEnabled: defaultValue.boolValue ?? false,
                source: .fallback,
                reason: .snapshotStoreUnavailable
            )
        }

        guard let flag = snapshot?.flags[key] else {
            return FeatureFlagEvaluation(
                key: key,
                value: defaultValue,
                isEnabled: defaultValue.boolValue ?? false,
                source: .fallback,
                reason: .missingFlag
            )
        }

        guard flag.isEnabled else {
            return FeatureFlagEvaluation(
                key: key,
                value: flag.value,
                isEnabled: false,
                source: .snapshot,
                reason: .disabled
            )
        }

        if let rolloutPercentage = flag.rolloutPercentage {
            let bucket = bucketer.bucket(key: key, identifier: context.rolloutIdentifier)
            guard bucket < rolloutPercentage else {
                return FeatureFlagEvaluation(
                    key: key,
                    value: flag.value,
                    isEnabled: false,
                    source: .snapshot,
                    reason: .rolloutExcluded
                )
            }

            return FeatureFlagEvaluation(
                key: key,
                value: flag.value,
                isEnabled: flag.value.boolValue ?? true,
                source: .snapshot,
                reason: .rolloutIncluded
            )
        }

        return FeatureFlagEvaluation(
            key: key,
            value: flag.value,
            isEnabled: flag.value.boolValue ?? true,
            source: .snapshot,
            reason: .enabled
        )
    }

    public func isEnabled(
        _ key: FeatureFlagKey,
        default defaultValue: Bool = false,
        context: FeatureFlagContext = FeatureFlagContext()
    ) async -> Bool {
        await evaluation(for: key, defaultValue: .bool(defaultValue), context: context).isEnabled
    }

    public func value(
        for key: FeatureFlagKey,
        default defaultValue: FeatureFlagValue = .null,
        context: FeatureFlagContext = FeatureFlagContext()
    ) async -> FeatureFlagValue {
        await evaluation(for: key, defaultValue: defaultValue, context: context).value
    }

    public func variant(
        for key: FeatureFlagKey,
        context: FeatureFlagContext = FeatureFlagContext()
    ) async -> FeatureFlagVariant? {
        do {
            if case .string(let variantID) = try await overrideStore.override(for: key) {
                let flag = try await snapshotStore.loadSnapshot()?.flags[key]
                return flag?.variants.first(where: { $0.id == variantID })
            }
        } catch {
            return nil
        }

        let flag: FeatureFlag?
        do {
            flag = try await snapshotStore.loadSnapshot()?.flags[key]
        } catch {
            return nil
        }

        guard let flag, flag.isEnabled, !flag.variants.isEmpty else {
            return nil
        }

        if let rolloutPercentage = flag.rolloutPercentage {
            let bucket = bucketer.bucket(key: key, identifier: context.rolloutIdentifier)
            guard bucket < rolloutPercentage else { return nil }
        }

        let totalWeight = flag.variants.reduce(0) { $0 + max(0, $1.weight) }
        guard totalWeight > 0 else { return nil }

        let variantBucket = bucketer.bucket(key: FeatureFlagKey(rawValue: "\(key.rawValue).variant"), identifier: context.rolloutIdentifier)
        let target = (variantBucket / 100.0) * totalWeight

        var cumulative: Double = 0
        for variant in flag.variants {
            cumulative += max(0, variant.weight)
            if target < cumulative {
                return variant
            }
        }

        return flag.variants.last
    }

    public func updateSnapshot(_ snapshot: FeatureFlagSnapshot) async throws {
        try FeatureFlagSnapshotValidation.validate(snapshot)
        try await snapshotStore.saveSnapshot(snapshot)
    }

    public func removeSnapshot() async throws {
        try await snapshotStore.removeSnapshot()
    }

    public func setOverride(_ value: FeatureFlagValue, for key: FeatureFlagKey) async throws {
        guard !key.isEmpty else { throw FeatureFlagError.emptyKey }
        try await overrideStore.setOverride(value, for: key)
    }

    public func removeOverride(for key: FeatureFlagKey) async throws {
        try await overrideStore.removeOverride(for: key)
    }

    public func removeAllOverrides() async throws {
        try await overrideStore.removeAllOverrides()
    }
}
