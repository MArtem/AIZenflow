import CoreData
import Foundation
import TchopDatabaseCore

/// Core Data-backed implementation of `DatabaseManaging`.
@MainActor
public final class CoreDataDatabaseManager: DatabaseManaging {
    public let persistentContainer: NSPersistentContainer

    public var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    public let backendKind: DatabaseBackendKind = .coreData

    /// Creates a new CoreDataDatabaseManager instance.
    public init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    /// Reads this operation.
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

    /// Writes this operation.
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

    /// Rolls back this operation.
    public func rollback() {
        viewContext.rollback()
    }

    /// Writes batch.
    public func writeBatch<Result>(_ operation: DatabaseBatchWriteOperation<Result>) throws -> Result {
        guard let coreDataOperation = operation.coreData else {
            throw DatabaseError.unsupportedOperation(
                "Missing Core Data implementation for batch write operation."
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
}
