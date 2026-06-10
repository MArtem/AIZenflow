import Foundation

/// Runtime context used to evaluate rollout and variant assignment.
public struct FeatureFlagContext: Equatable, Codable, Sendable {
    public var stableIdentifier: String?
    public var userIdentifier: String?
    public var appVersion: String?
    public var localeIdentifier: String?
    public var attributes: [String: FeatureFlagValue]

    public init(
        stableIdentifier: String? = nil,
        userIdentifier: String? = nil,
        appVersion: String? = nil,
        localeIdentifier: String? = nil,
        attributes: [String: FeatureFlagValue] = [:]
    ) {
        self.stableIdentifier = stableIdentifier
        self.userIdentifier = userIdentifier
        self.appVersion = appVersion
        self.localeIdentifier = localeIdentifier
        self.attributes = attributes
    }

    public var rolloutIdentifier: String {
        stableIdentifier ?? userIdentifier ?? "anonymous"
    }
}

/// A weighted variant for A/B-like flag values.
public struct FeatureFlagVariant: Identifiable, Equatable, Codable, Sendable {
    public let id: String
    public let value: FeatureFlagValue
    public let weight: Double

    public init(id: String, value: FeatureFlagValue, weight: Double) {
        self.id = id
        self.value = value
        self.weight = max(0, weight)
    }
}

/// A normalized feature flag definition.
public struct FeatureFlag: Equatable, Codable, Sendable {
    public var key: FeatureFlagKey
    public var isEnabled: Bool
    public var value: FeatureFlagValue
    /// 0...100. `nil` means no rollout restriction.
    public var rolloutPercentage: Double?
    public var variants: [FeatureFlagVariant]
    public var metadata: [String: FeatureFlagValue]
    public var updatedAt: Date?

    public init(
        key: FeatureFlagKey,
        isEnabled: Bool,
        value: FeatureFlagValue = .bool(true),
        rolloutPercentage: Double? = nil,
        variants: [FeatureFlagVariant] = [],
        metadata: [String: FeatureFlagValue] = [:],
        updatedAt: Date? = nil
    ) {
        self.key = key
        self.isEnabled = isEnabled
        self.value = value
        self.rolloutPercentage = rolloutPercentage
        self.variants = variants
        self.metadata = metadata
        self.updatedAt = updatedAt
    }
}

/// Validation helpers for snapshots before they become active runtime input.
public enum FeatureFlagSnapshotValidation {
    public static func validate(_ snapshot: FeatureFlagSnapshot) throws {
        for (dictionaryKey, flag) in snapshot.flags {
            guard !dictionaryKey.isEmpty, !flag.key.isEmpty else {
                throw FeatureFlagError.emptyKey
            }
            guard dictionaryKey == flag.key else {
                throw FeatureFlagError.mismatchedSnapshotKey(expected: dictionaryKey, actual: flag.key)
            }
            if let rolloutPercentage = flag.rolloutPercentage,
               rolloutPercentage < 0 || rolloutPercentage > 100 {
                throw FeatureFlagError.invalidRolloutPercentage(rolloutPercentage)
            }
        }
    }
}

public enum FeatureFlagSnapshotSource: String, Codable, Sendable {
    case bundledDefault
    case localOverride
    case remote
    case test
}

/// A collection of feature flags loaded from a source.
public struct FeatureFlagSnapshot: Equatable, Codable, Sendable {
    public var flags: [FeatureFlagKey: FeatureFlag]
    public var source: FeatureFlagSnapshotSource
    public var schemaVersion: Int
    public var createdAt: Date?

    public init(
        flags: [FeatureFlagKey: FeatureFlag] = [:],
        source: FeatureFlagSnapshotSource = .bundledDefault,
        schemaVersion: Int = 1,
        createdAt: Date? = nil
    ) {
        self.flags = flags
        self.source = source
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
    }
}

public enum FeatureFlagEvaluationSource: String, Codable, Sendable {
    case fallback
    case snapshot
    case localOverride
}

public enum FeatureFlagEvaluationReason: String, Codable, Sendable {
    case keyIsEmpty
    case missingFlag
    case disabled
    case enabled
    case rolloutIncluded
    case rolloutExcluded
    case localOverride
    case variantAssigned
    case noMatchingVariant
    case snapshotStoreUnavailable
    case overrideStoreUnavailable
}

/// Diagnostic result for a feature flag evaluation.
public struct FeatureFlagEvaluation: Equatable, Codable, Sendable {
    public let key: FeatureFlagKey
    public let value: FeatureFlagValue
    public let isEnabled: Bool
    public let selectedVariantID: String?
    public let source: FeatureFlagEvaluationSource
    public let reason: FeatureFlagEvaluationReason

    public init(
        key: FeatureFlagKey,
        value: FeatureFlagValue,
        isEnabled: Bool,
        selectedVariantID: String? = nil,
        source: FeatureFlagEvaluationSource,
        reason: FeatureFlagEvaluationReason
    ) {
        self.key = key
        self.value = value
        self.isEnabled = isEnabled
        self.selectedVariantID = selectedVariantID
        self.source = source
        self.reason = reason
    }
}
