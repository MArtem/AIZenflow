import CoreData
import Foundation
import SwiftData

/// Identifies the concrete persistence backend currently serving database operations.
public enum DatabaseBackendKind: String, Sendable, Equatable {
    /// SwiftData-backed persistence.
    case swiftData

    /// Core Data-backed persistence.
    case coreData
}

/// Selects which persistence backend should be used by the database factory.
public enum DatabaseBackendSelectionPolicy: Sendable, Equatable {
    /// Picks the best available backend for the current runtime.
    case automatic

    /// Forces SwiftData when the caller provides a SwiftData container factory.
    case swiftData

    /// Forces Core Data when the caller provides a Core Data container factory.
    case coreData

    /// Resolves the effective backend for the current process.
    ///
    /// - Returns: The backend that should be instantiated by the factory.
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
    /// The requested operation could not run because the selected backend had no compatible implementation.
    case unsupportedOperation(String)

    /// The configured backend could not be constructed.
    case backendInitializationFailed(String)

    /// The backend failed while fetching data.
    case fetchFailed(String)

    /// The backend failed while persisting data.
    case saveFailed(String)

    /// The backend failed while deleting data.
    case deleteFailed(String)

    /// The backend failed while running a transaction.
    case transactionFailed(String)
}

/// Marks a model as supporting created and updated timestamps.
public protocol TimestampTrackableRecord: AnyObject {
    /// Creation timestamp.
    var createdAt: Date { get set }

    /// Last update timestamp.
    var updatedAt: Date { get set }
}

/// Marks a model as supporting soft deletion.
public protocol SoftDeletableRecord: AnyObject {
    /// Timestamp when the record was soft deleted.
    var deletedAt: Date? { get set }
}

/// Runtime configuration for the database service factory.
public struct DatabaseConfiguration: Sendable, Equatable {
    /// Selected backend policy.
    public let backendSelectionPolicy: DatabaseBackendSelectionPolicy

    /// Indicates whether the store should live only in memory.
    public let isStoredInMemoryOnly: Bool

    /// Creates a new configuration value.
    ///
    /// - Parameters:
    ///   - backendSelectionPolicy: Preferred backend resolution policy.
    ///   - isStoredInMemoryOnly: When `true`, the resulting store should not write to disk.
    public init(
        backendSelectionPolicy: DatabaseBackendSelectionPolicy = .automatic,
        isStoredInMemoryOnly: Bool
    ) {
        self.backendSelectionPolicy = backendSelectionPolicy
        self.isStoredInMemoryOnly = isStoredInMemoryOnly
    }

    /// Default persistent configuration.
    public static let persistent = DatabaseConfiguration(
        backendSelectionPolicy: .automatic,
        isStoredInMemoryOnly: false
    )

    /// In-memory configuration suited for tests and previews.
    public static let inMemory = DatabaseConfiguration(
        backendSelectionPolicy: .automatic,
        isStoredInMemoryOnly: true
    )
}

/// Read-only operation that can be executed against either supported backend.
///
/// The caller supplies one or both backend implementations. The selected manager
/// executes only the closure matching its active backend.
public struct DatabaseReadOperation<Result> {
    let swiftData: (@MainActor (Any) throws -> Result)?
    let coreData: (@MainActor (NSManagedObjectContext) throws -> Result)?

    /// Creates a Core Data-only read operation.
    ///
    /// - Parameter coreData: Core Data implementation for the operation.
    public init(
        coreData: (@MainActor (NSManagedObjectContext) throws -> Result)? = nil
    ) {
        self.swiftData = nil
        self.coreData = coreData
    }

    /// Creates a backend-neutral read operation.
    ///
    /// - Parameters:
    ///   - swiftData: SwiftData implementation for the operation.
    ///   - coreData: Core Data implementation for the operation.
    @available(iOS 17, macOS 14, *)
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
///
/// The manager automatically commits changes when the operation succeeds and rolls
/// them back when it fails.
public struct DatabaseWriteOperation<Result> {
    let swiftData: (@MainActor (Any) throws -> Result)?
    let coreData: (@MainActor (NSManagedObjectContext) throws -> Result)?

    /// Creates a Core Data-only write operation.
    ///
    /// - Parameter coreData: Core Data implementation for the operation.
    public init(
        coreData: (@MainActor (NSManagedObjectContext) throws -> Result)? = nil
    ) {
        self.swiftData = nil
        self.coreData = coreData
    }

    /// Creates a backend-neutral write operation.
    ///
    /// - Parameters:
    ///   - swiftData: SwiftData implementation for the operation.
    ///   - coreData: Core Data implementation for the operation.
    @available(iOS 17, macOS 14, *)
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

/// Common contract implemented by all database managers.
///
/// The interface is backend-neutral. Consumers describe their work as read/write
/// operations and the manager dispatches them to the active backend.
@MainActor
public protocol DatabaseManaging: AnyObject {
    /// Concrete backend currently serving requests.
    var backendKind: DatabaseBackendKind { get }

    /// Executes a read-only operation.
    ///
    /// - Parameter operation: Operation with backend-specific implementations.
    /// - Returns: The value returned by the active backend implementation.
    func read<Result>(_ operation: DatabaseReadOperation<Result>) throws -> Result

    /// Executes a mutating operation and persists changes atomically.
    ///
    /// - Parameter operation: Operation with backend-specific implementations.
    /// - Returns: The value returned by the active backend implementation.
    func write<Result>(_ operation: DatabaseWriteOperation<Result>) throws -> Result

    /// Rolls back pending changes in the active backend context.
    func rollback()
}

/// Factory responsible for constructing backend-neutral database managers.
public enum DatabaseServiceFactory {
    /// Creates a database manager for the supplied configuration.
    ///
    /// - Parameters:
    ///   - configuration: Backend selection and persistence configuration.
    ///   - makeSwiftDataContainer: Factory used when the selected backend is SwiftData.
    ///   - makeCoreDataContainer: Factory used when the selected backend is Core Data.
    /// - Returns: A concrete database manager bound to the selected backend.
    /// - Throws: ``DatabaseError/backendInitializationFailed(_:)`` when the requested backend
    ///   cannot be constructed.
    @MainActor
    public static func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        makeSwiftDataContainer: (() throws -> Any)? = nil,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)? = nil
    ) throws -> any DatabaseManaging {
        let backendKind = configuration.backendSelectionPolicy.resolveBackendKind()

        switch backendKind {
        case .swiftData:
            guard #available(iOS 17, macOS 14, *) else {
                throw DatabaseError.backendInitializationFailed(
                    "SwiftData backend requested on unsupported OS version."
                )
            }

            guard let makeSwiftDataContainer else {
                throw DatabaseError.backendInitializationFailed(
                    "SwiftData backend requested without a ModelContainer factory."
                )
            }

            do {
                guard let container = try makeSwiftDataContainer() as? ModelContainer else {
                    throw DatabaseError.backendInitializationFailed(
                        "SwiftData factory did not return ModelContainer."
                    )
                }

                return SwiftDataDatabaseManager(modelContainer: container)
            } catch {
                throw DatabaseError.backendInitializationFailed(String(describing: error))
            }
        case .coreData:
            guard let makeCoreDataContainer else {
                throw DatabaseError.backendInitializationFailed(
                    "Core Data backend requested without an NSPersistentContainer factory."
                )
            }

            do {
                return CoreDataDatabaseManager(persistentContainer: try makeCoreDataContainer())
            } catch {
                throw DatabaseError.backendInitializationFailed(String(describing: error))
            }
        }
    }
}

/// SwiftData-backed implementation of ``DatabaseManaging``.
@MainActor
@available(iOS 17, macOS 14, *)
public final class SwiftDataDatabaseManager: DatabaseManaging {
    /// Shared model container used by the manager.
    public let modelContainer: ModelContainer

    /// Exposes the main model context for advanced integration points.
    public var modelContext: ModelContext {
        modelContainer.mainContext
    }

    /// Active backend kind.
    public let backendKind: DatabaseBackendKind = .swiftData

    /// Creates a manager around an existing model container.
    ///
    /// - Parameter modelContainer: Container that owns the SwiftData store.
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    public func read<Result>(_ operation: DatabaseReadOperation<Result>) throws -> Result {
        guard let swiftDataOperation = operation.swiftData else {
            throw DatabaseError.unsupportedOperation(
                "Missing SwiftData implementation for read operation."
            )
        }

        do {
            return try swiftDataOperation(modelContext)
        } catch let databaseError as DatabaseError {
            throw databaseError
        } catch {
            throw DatabaseError.fetchFailed(String(describing: error))
        }
    }

    public func write<Result>(_ operation: DatabaseWriteOperation<Result>) throws -> Result {
        guard let swiftDataOperation = operation.swiftData else {
            throw DatabaseError.unsupportedOperation(
                "Missing SwiftData implementation for write operation."
            )
        }

        do {
            let result = try swiftDataOperation(modelContext)
            try modelContext.save()
            return result
        } catch let databaseError as DatabaseError {
            modelContext.rollback()
            throw databaseError
        } catch {
            modelContext.rollback()
            throw DatabaseError.transactionFailed(String(describing: error))
        }
    }

    public func rollback() {
        modelContext.rollback()
    }
}

/// Core Data-backed implementation of ``DatabaseManaging``.
@MainActor
public final class CoreDataDatabaseManager: DatabaseManaging {
    /// Shared persistent container used by the manager.
    public let persistentContainer: NSPersistentContainer

    /// Exposes the main managed object context for advanced integration points.
    public var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    /// Active backend kind.
    public let backendKind: DatabaseBackendKind = .coreData

    /// Creates a manager around an existing persistent container.
    ///
    /// - Parameter persistentContainer: Container that owns the Core Data store.
    public init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    public func read<Result>(_ operation: DatabaseReadOperation<Result>) throws -> Result {
        guard let coreDataOperation = operation.coreData else {
            throw DatabaseError.unsupportedOperation(
                "Missing Core Data implementation for read operation."
            )
        }

        do {
            return try coreDataOperation(viewContext)
        } catch let databaseError as DatabaseError {
            throw databaseError
        } catch {
            throw DatabaseError.fetchFailed(String(describing: error))
        }
    }

    public func write<Result>(_ operation: DatabaseWriteOperation<Result>) throws -> Result {
        guard let coreDataOperation = operation.coreData else {
            throw DatabaseError.unsupportedOperation(
                "Missing Core Data implementation for write operation."
            )
        }

        do {
            let result = try coreDataOperation(viewContext)
            if viewContext.hasChanges {
                try viewContext.save()
            }
            return result
        } catch let databaseError as DatabaseError {
            viewContext.rollback()
            throw databaseError
        } catch {
            viewContext.rollback()
            throw DatabaseError.transactionFailed(String(describing: error))
        }
    }

    public func rollback() {
        viewContext.rollback()
    }
}
