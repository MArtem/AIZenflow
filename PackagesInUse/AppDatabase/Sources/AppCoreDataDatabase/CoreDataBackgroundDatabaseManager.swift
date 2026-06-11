import CoreData
import Foundation

/// Queue-confined Core Data manager for background work that must not inherit main-actor execution.
///
/// `CoreDataDatabaseManager` intentionally uses `viewContext` and conforms to the shared
/// main-context database contract. This type is the explicit background counterpart for imports,
/// migrations, sync writes, and other non-UI Core Data work that should execute on Core Data's
/// private queue through `NSPersistentContainer.performBackgroundTask(_:)`.
public final class CoreDataBackgroundDatabaseManager {
    public let persistentContainer: NSPersistentContainer

    /// Creates a background Core Data manager backed by the provided persistent container.
    public init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    /// Executes a read-only operation on a private queue context.
    public func read<Result: Sendable>(
        _ operation: @escaping @Sendable (NSManagedObjectContext) throws -> Result
    ) async throws -> Result {
        try await perform(operation, shouldSave: false)
    }

    /// Executes a write operation on a private queue context and saves pending changes.
    public func write<Result: Sendable>(
        _ operation: @escaping @Sendable (NSManagedObjectContext) throws -> Result
    ) async throws -> Result {
        try await perform(operation, shouldSave: true)
    }

    private func perform<Result: Sendable>(
        _ operation: @escaping @Sendable (NSManagedObjectContext) throws -> Result,
        shouldSave: Bool
    ) async throws -> Result {
        try await withCheckedThrowingContinuation { continuation in
            persistentContainer.performBackgroundTask { context in
                do {
                    let result = try operation(context)
                    if shouldSave, context.hasChanges {
                        try context.save()
                    }
                    continuation.resume(returning: result)
                } catch let databaseError as DatabaseError {
                    context.rollback()
                    continuation.resume(throwing: databaseError)
                } catch {
                    context.rollback()
                    continuation.resume(
                        throwing: shouldSave
                            ? DatabaseError.transactionFailed(String(describing: error))
                            : DatabaseError.fetchFailed(String(describing: error))
                    )
                }
            }
        }
    }
}
