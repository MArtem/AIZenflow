import Foundation

public protocol FeatureFlagSnapshotStoring: Sendable {
    func loadSnapshot() async throws -> FeatureFlagSnapshot?
    func saveSnapshot(_ snapshot: FeatureFlagSnapshot) async throws
    func removeSnapshot() async throws
}

public protocol FeatureFlagOverrideStoring: Sendable {
    func override(for key: FeatureFlagKey) async throws -> FeatureFlagValue?
    func setOverride(_ value: FeatureFlagValue, for key: FeatureFlagKey) async throws
    func removeOverride(for key: FeatureFlagKey) async throws
    func removeAllOverrides() async throws
}

public actor InMemoryFeatureFlagSnapshotStore: FeatureFlagSnapshotStoring {
    private var snapshot: FeatureFlagSnapshot?

    public init(snapshot: FeatureFlagSnapshot? = nil) {
        self.snapshot = snapshot
    }

    public func loadSnapshot() async throws -> FeatureFlagSnapshot? {
        snapshot
    }

    public func saveSnapshot(_ snapshot: FeatureFlagSnapshot) async throws {
        try FeatureFlagSnapshotValidation.validate(snapshot)
        self.snapshot = snapshot
    }

    public func removeSnapshot() async throws {
        snapshot = nil
    }
}

public actor InMemoryFeatureFlagOverrideStore: FeatureFlagOverrideStoring {
    private var values: [FeatureFlagKey: FeatureFlagValue]

    public init(values: [FeatureFlagKey: FeatureFlagValue] = [:]) {
        self.values = values
    }

    public func override(for key: FeatureFlagKey) async throws -> FeatureFlagValue? {
        values[key]
    }

    public func setOverride(_ value: FeatureFlagValue, for key: FeatureFlagKey) async throws {
        guard !key.isEmpty else { throw FeatureFlagError.emptyKey }
        values[key] = value
    }

    public func removeOverride(for key: FeatureFlagKey) async throws {
        values.removeValue(forKey: key)
    }

    public func removeAllOverrides() async throws {
        values.removeAll()
    }
}

/// UserDefaults-backed snapshot store for standalone app integration.
///
/// Use this when a host app wants feature flags to survive relaunch without
/// introducing a database or a sibling configuration package dependency.
public actor UserDefaultsFeatureFlagSnapshotStore: FeatureFlagSnapshotStoring {
    private let userDefaults: UserDefaults
    private let storageKey: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "app.feature-flags.snapshot",
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.encoder = encoder
        self.decoder = decoder
    }

    public init(
        suiteName: String,
        storageKey: String = "app.feature-flags.snapshot",
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) throws {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw FeatureFlagError.userDefaultsSuiteUnavailable(suiteName)
        }
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.encoder = encoder
        self.decoder = decoder
    }

    public func loadSnapshot() async throws -> FeatureFlagSnapshot? {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return nil
        }
        return try decoder.decode(FeatureFlagSnapshot.self, from: data)
    }

    public func saveSnapshot(_ snapshot: FeatureFlagSnapshot) async throws {
        try FeatureFlagSnapshotValidation.validate(snapshot)
        let data = try encoder.encode(snapshot)
        userDefaults.set(data, forKey: storageKey)
    }

    public func removeSnapshot() async throws {
        userDefaults.removeObject(forKey: storageKey)
    }
}

/// UserDefaults-backed local override store for debug menus, QA switches, and
/// host-app-controlled rollout overrides.
public actor UserDefaultsFeatureFlagOverrideStore: FeatureFlagOverrideStoring {
    private let userDefaults: UserDefaults
    private let storageKey: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "app.feature-flags.overrides",
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.encoder = encoder
        self.decoder = decoder
    }

    public init(
        suiteName: String,
        storageKey: String = "app.feature-flags.overrides",
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) throws {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw FeatureFlagError.userDefaultsSuiteUnavailable(suiteName)
        }
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.encoder = encoder
        self.decoder = decoder
    }

    public func override(for key: FeatureFlagKey) async throws -> FeatureFlagValue? {
        try loadOverrides()[key]
    }

    public func setOverride(_ value: FeatureFlagValue, for key: FeatureFlagKey) async throws {
        guard !key.isEmpty else { throw FeatureFlagError.emptyKey }
        var values = try loadOverrides()
        values[key] = value
        try saveOverrides(values)
    }

    public func removeOverride(for key: FeatureFlagKey) async throws {
        var values = try loadOverrides()
        values.removeValue(forKey: key)
        try saveOverrides(values)
    }

    public func removeAllOverrides() async throws {
        userDefaults.removeObject(forKey: storageKey)
    }

    private func loadOverrides() throws -> [FeatureFlagKey: FeatureFlagValue] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return [:]
        }
        return try decoder.decode([FeatureFlagKey: FeatureFlagValue].self, from: data)
    }

    private func saveOverrides(_ values: [FeatureFlagKey: FeatureFlagValue]) throws {
        let data = try encoder.encode(values)
        userDefaults.set(data, forKey: storageKey)
    }
}
