import CoreData
import Foundation
import SwiftData

/// Identifies the concrete persistence backend currently serving database operations.
public enum DatabaseBackendKind: String, Sendable, Equatable, CaseIterable {
    /// SwiftData-backed persistence.
    case swiftData

    /// Core Data-backed persistence.
    case coreData
}

/// Selects which persistence backend should be used by the database resolver.
public enum DatabaseBackendSelectionPolicy: Sendable, Equatable {
    /// Picks the best available backend for the current runtime.
    case automatic

    /// Forces SwiftData when the caller provides a SwiftData container factory.
    case swiftData

    /// Forces Core Data when the caller provides a Core Data container factory.
    case coreData

    /// Resolves the effective backend for the current process.
    public func resolveBackendKind() -> DatabaseBackendKind {
        switch self {
        case .automatic:
            if #available(iOS 17, macOS 14, *) {
                return .swiftData
            }
            return .coreData
        case .swiftData:
            return .swiftData
        case .coreData:
            return .coreData
        }
    }
}

/// Describes database-layer failures with explicit operation context.
public enum DatabaseError: Error, Equatable, Sendable {
    case unsupportedOperation(String)
    case backendInitializationFailed(String)
    case fetchFailed(String)
    case saveFailed(String)
    case deleteFailed(String)
    case transactionFailed(String)
    case migrationFailed(String)
}

/// Marks a model as supporting created and updated timestamps.
public protocol TimestampTrackableRecord: AnyObject {
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
}

/// Marks a model as supporting soft deletion.
public protocol SoftDeletableRecord: AnyObject {
    var deletedAt: Date? { get set }
}

/// Runtime configuration for the database resolver.
public struct DatabaseConfiguration: Sendable, Equatable {
    public let backendSelectionPolicy: DatabaseBackendSelectionPolicy
    public let isStoredInMemoryOnly: Bool

    /// Creates a new DatabaseConfiguration instance.
    public init(
        backendSelectionPolicy: DatabaseBackendSelectionPolicy = .automatic,
        isStoredInMemoryOnly: Bool
    ) {
        self.backendSelectionPolicy = backendSelectionPolicy
        self.isStoredInMemoryOnly = isStoredInMemoryOnly
    }

    public static let persistent = DatabaseConfiguration(
        backendSelectionPolicy: .automatic,
        isStoredInMemoryOnly: false
    )

    public static let inMemory = DatabaseConfiguration(
        backendSelectionPolicy: .automatic,
        isStoredInMemoryOnly: true
    )
}

/// Read-only operation that can be executed against either supported backend.
public struct DatabaseReadOperation<Result> {
    public let swiftData: (@MainActor (Any) throws -> Result)?
    public let coreData: (@MainActor (NSManagedObjectContext) throws -> Result)?

    /// Creates a new DatabaseReadOperation instance.
    public init(
        coreData: (@MainActor (NSManagedObjectContext) throws -> Result)? = nil
    ) {
        self.swiftData = nil
        self.coreData = coreData
    }

    @available(iOS 17, macOS 14, *)
    /// Creates a new DatabaseReadOperation instance.
    public init(
        swiftData: (@MainActor (ModelContext) throws -> Result)? = nil,
        coreData: (@MainActor (NSManagedObjectContext) throws -> Result)? = nil
    ) {
        self.swiftData = swiftData.map { swiftDataOperation in
            { @MainActor context in
                guard let modelContext = context as? ModelContext else {
                    throw DatabaseError.unsupportedOperation(
                        "Invalid SwiftData context for read operation."
                    )
                }

                return try swiftDataOperation(modelContext)
            }
        }
        self.coreData = coreData
    }
}

/// Mutating operation that can be executed against either supported backend.
public struct DatabaseWriteOperation<Result> {
    public let swiftData: (@MainActor (Any) throws -> Result)?
    public let coreData: (@MainActor (NSManagedObjectContext) throws -> Result)?

    /// Creates a new DatabaseWriteOperation instance.
    public init(
        coreData: (@MainActor (NSManagedObjectContext) throws -> Result)? = nil
    ) {
        self.swiftData = nil
        self.coreData = coreData
    }

    @available(iOS 17, macOS 14, *)
    /// Creates a new DatabaseWriteOperation instance.
    public init(
        swiftData: (@MainActor (ModelContext) throws -> Result)? = nil,
        coreData: (@MainActor (NSManagedObjectContext) throws -> Result)? = nil
    ) {
        self.swiftData = swiftData.map { swiftDataOperation in
            { @MainActor context in
                guard let modelContext = context as? ModelContext else {
                    throw DatabaseError.unsupportedOperation(
                        "Invalid SwiftData context for write operation."
                    )
                }

                return try swiftDataOperation(modelContext)
            }
        }
        self.coreData = coreData
    }
}

/// Batch mutating operation that can be executed against either supported backend.
public struct DatabaseBatchWriteOperation<Result> {
    public let swiftData: (@MainActor (Any) throws -> Result)?
    public let coreData: (@MainActor (NSManagedObjectContext) throws -> Result)?

    /// Creates a new DatabaseBatchWriteOperation instance.
    public init(
        coreData: (@MainActor (NSManagedObjectContext) throws -> Result)? = nil
    ) {
        self.swiftData = nil
        self.coreData = coreData
    }

    @available(iOS 17, macOS 14, *)
    /// Creates a new DatabaseBatchWriteOperation instance.
    public init(
        swiftData: (@MainActor (ModelContext) throws -> Result)? = nil,
        coreData: (@MainActor (NSManagedObjectContext) throws -> Result)? = nil
    ) {
        self.swiftData = swiftData.map { swiftDataOperation in
            { @MainActor context in
                guard let modelContext = context as? ModelContext else {
                    throw DatabaseError.unsupportedOperation(
                        "Invalid SwiftData context for batch write operation."
                    )
                }

                return try swiftDataOperation(modelContext)
            }
        }
        self.coreData = coreData
    }
}

/// Common contract implemented by all database managers.
@MainActor
public protocol DatabaseManaging: AnyObject {
    var backendKind: DatabaseBackendKind { get }
    /// Reads this operation.
    func read<Result>(_ operation: DatabaseReadOperation<Result>) throws -> Result
    /// Writes this operation.
    func write<Result>(_ operation: DatabaseWriteOperation<Result>) throws -> Result
    /// Rolls back this operation.
    func rollback()
    /// Writes batch.
    func writeBatch<Result>(_ operation: DatabaseBatchWriteOperation<Result>) throws -> Result
}

@MainActor
public extension DatabaseManaging {
    /// Reads async.
    func readAsync<Result>(_ operation: DatabaseReadOperation<Result>) async throws -> Result {
        try read(operation)
    }

    /// Writes async.
    func writeAsync<Result>(_ operation: DatabaseWriteOperation<Result>) async throws -> Result {
        try write(operation)
    }

    /// Writes batch async.
    func writeBatchAsync<Result>(
        _ operation: DatabaseBatchWriteOperation<Result>
    ) async throws -> Result {
        try writeBatch(operation)
    }
}

/// Persists and retrieves applied migration versions.
@MainActor
public protocol DatabaseMigrationVersionStoring: AnyObject {
    /// Returns version.
    func currentVersion(for key: String) -> Int
    /// Sets current version.
    func setCurrentVersion(_ version: Int, for key: String)
}

/// UserDefaults-backed migration version storage.
@MainActor
public final class UserDefaultsDatabaseMigrationVersionStore: DatabaseMigrationVersionStoring {
    private let userDefaults: UserDefaults
    private let keyPrefix: String

    /// Creates a new UserDefaultsDatabaseMigrationVersionStore instance.
    public init(
        userDefaults: UserDefaults = .standard,
        keyPrefix: String = "database_migration_version_"
    ) {
        self.userDefaults = userDefaults
        self.keyPrefix = keyPrefix
    }

    /// Returns version.
    public func currentVersion(for key: String) -> Int {
        userDefaults.integer(forKey: keyPrefix + key)
    }

    /// Sets current version.
    public func setCurrentVersion(_ version: Int, for key: String) {
        userDefaults.set(version, forKey: keyPrefix + key)
    }
}

/// Single version transition step in a migration plan.
@MainActor
public struct DatabaseMigrationStep {
    public let fromVersion: Int
    public let toVersion: Int

    private let migrateClosure: (any DatabaseManaging) throws -> Void

    /// Creates a new DatabaseMigrationStep instance.
    public init(
        fromVersion: Int,
        toVersion: Int,
        migrate: @escaping (any DatabaseManaging) throws -> Void
    ) {
        self.fromVersion = fromVersion
        self.toVersion = toVersion
        self.migrateClosure = migrate
    }

    /// Handles run.
    func run(using manager: any DatabaseManaging) throws {
        try migrateClosure(manager)
    }
}

/// Applies ordered versioned migrations against a database manager.
@MainActor
public final class DatabaseMigrationRunner {
    private let versionStore: any DatabaseMigrationVersionStoring

    /// Creates a new DatabaseMigrationRunner instance.
    public init(versionStore: any DatabaseMigrationVersionStoring) {
        self.versionStore = versionStore
    }

    /// Migrates if needed.
    public func migrateIfNeeded(
        key: String,
        targetVersion: Int,
        using manager: any DatabaseManaging,
        steps: [DatabaseMigrationStep]
    ) throws -> Int {
        var currentVersion = versionStore.currentVersion(for: key)
        guard currentVersion < targetVersion else {
            return currentVersion
        }

        let groupedSteps = Dictionary(grouping: steps, by: \.fromVersion)

        while currentVersion < targetVersion {
            guard let nextStep = groupedSteps[currentVersion]?
                .sorted(by: { $0.toVersion < $1.toVersion })
                .first
            else {
                throw DatabaseError.migrationFailed(
                    "Missing migration step from version \(currentVersion) for key \(key)."
                )
            }

            guard nextStep.toVersion > currentVersion else {
                throw DatabaseError.migrationFailed(
                    "Invalid migration step \(nextStep.fromVersion)->\(nextStep.toVersion) for key \(key)."
                )
            }

            do {
                try nextStep.run(using: manager)
            } catch let databaseError as DatabaseError {
                throw databaseError
            } catch {
                throw DatabaseError.migrationFailed(String(describing: error))
            }

            currentVersion = nextStep.toVersion
            versionStore.setCurrentVersion(currentVersion, for: key)
        }

        return currentVersion
    }
}
