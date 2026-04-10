import Foundation
import SwiftData

/// Describes database-layer errors with explicit operation context.
public enum DatabaseError: Error, Equatable, Sendable {
    case saveFailed(String)
    case fetchFailed(String)
    case deleteFailed(String)
    case transactionFailed(String)
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

/// Runtime configuration for the SwiftData-backed database manager.
public struct DatabaseConfiguration: Sendable, Equatable {
    /// Defines whether the backing store should live only in memory.
    public let isStoredInMemoryOnly: Bool

    /// Creates a new database configuration.
    public init(isStoredInMemoryOnly: Bool) {
        self.isStoredInMemoryOnly = isStoredInMemoryOnly
    }

    /// Default persistent configuration.
    public static let persistent = DatabaseConfiguration(isStoredInMemoryOnly: false)

    /// In-memory configuration suited for tests and previews.
    public static let inMemory = DatabaseConfiguration(isStoredInMemoryOnly: true)
}

/// Contract implemented by the database service used by repositories and seeders.
@MainActor
public protocol DatabaseManaging {
    /// Shared model container used by the manager.
    var modelContainer: ModelContainer { get }

    /// Main model context used by the manager.
    var modelContext: ModelContext { get }

    /// Fetches entities using the provided descriptor.
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T]

    /// Fetches the first matching entity.
    func fetchFirst<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> T?

    /// Returns the number of matching entities.
    func fetchCount<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> Int

    /// Inserts a single model into the current context.
    func insert<T: PersistentModel>(_ model: T)

    /// Inserts many models into the current context.
    func insert<S: Sequence>(_ models: S) where S.Element: PersistentModel

    /// Deletes a single model.
    func delete<T: PersistentModel>(_ model: T)

    /// Deletes many models.
    func delete<S: Sequence>(_ models: S) where S.Element: PersistentModel

    /// Deletes all records of a given model type.
    func deleteAll<T: PersistentModel>(_ modelType: T.Type) throws

    /// Persists in-memory changes.
    func save() throws

    /// Rolls back unsaved changes.
    func rollback()

    /// Executes a transactional operation and rolls back on failure.
    func performTransaction(_ operation: () throws -> Void) throws

    /// Applies a soft delete timestamp when the model supports it.
    func softDelete<T>(_ model: T, at date: Date) throws where T: PersistentModel & SoftDeletableRecord
}

/// Default SwiftData-backed implementation used by the application.
@MainActor
public final class SwiftDataDatabaseManager: DatabaseManaging {
    /// Shared model container used by the manager.
    public let modelContainer: ModelContainer

    /// Exposes the main model context for advanced integration points.
    public var modelContext: ModelContext {
        modelContainer.mainContext
    }

    /// Creates a manager around an existing model container.
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    public func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            throw DatabaseError.fetchFailed(String(describing: error))
        }
    }

    public func fetchFirst<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> T? {
        try fetch(descriptor).first
    }

    public func fetchCount<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> Int {
        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            throw DatabaseError.fetchFailed(String(describing: error))
        }
    }

    public func insert<T: PersistentModel>(_ model: T) {
        stampTimestampsIfNeeded(model)
        modelContext.insert(model)
    }

    public func insert<S: Sequence>(_ models: S) where S.Element: PersistentModel {
        for model in models {
            insert(model)
        }
    }

    public func delete<T: PersistentModel>(_ model: T) {
        modelContext.delete(model)
    }

    public func delete<S: Sequence>(_ models: S) where S.Element: PersistentModel {
        for model in models {
            delete(model)
        }
    }

    public func deleteAll<T: PersistentModel>(_ modelType: T.Type) throws {
        do {
            try modelContext.delete(model: modelType)
        } catch {
            throw DatabaseError.deleteFailed(String(describing: error))
        }
    }

    public func save() throws {
        do {
            try modelContext.save()
        } catch {
            throw DatabaseError.saveFailed(String(describing: error))
        }
    }

    public func rollback() {
        modelContext.rollback()
    }

    public func performTransaction(_ operation: () throws -> Void) throws {
        do {
            try operation()
            try save()
        } catch {
            rollback()
            throw DatabaseError.transactionFailed(String(describing: error))
        }
    }

    public func softDelete<T>(_ model: T, at date: Date = .now) throws where T: PersistentModel & SoftDeletableRecord {
        model.deletedAt = date

        if let timestampedModel = model as? any TimestampTrackableRecord {
            timestampedModel.updatedAt = date
        }

        try save()
    }

    private func stampTimestampsIfNeeded<T: PersistentModel>(_ model: T) {
        guard let timestampedModel = model as? any TimestampTrackableRecord else {
            return
        }

        let now = Date()
        timestampedModel.updatedAt = now
        timestampedModel.createdAt = timestampedModel.createdAt == .distantPast ? now : timestampedModel.createdAt
    }
}
