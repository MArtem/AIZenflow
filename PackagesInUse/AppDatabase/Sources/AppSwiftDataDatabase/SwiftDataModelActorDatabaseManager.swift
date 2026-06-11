import Foundation
import SwiftData

/// Actor-confined SwiftData manager for persistence work that must not use `ModelContainer.mainContext`.
///
/// Use this type for imports, migrations, sync application, and other persistence work that should be isolated from
/// UI-owned main-context operations. The operation closures remain SwiftData-specific intentionally; this avoids
/// weakening type safety through a backend-neutral `Any` context outside the main-context compatibility contract.
@available(iOS 17, macOS 14, *)
@ModelActor
public actor SwiftDataModelActorDatabaseManager {
    /// Executes a read-only operation on this model actor's context.
    public func read<Result: Sendable>(
        _ operation: @Sendable (ModelContext) throws -> Result
    ) throws -> Result {
        do {
            return try operation(modelContext)
        } catch let databaseError as DatabaseError {
            throw databaseError
        } catch {
            throw DatabaseError.fetchFailed(String(describing: error))
        }
    }

    /// Executes a write operation on this model actor's context and saves pending changes.
    public func write<Result: Sendable>(
        _ operation: @Sendable (ModelContext) throws -> Result
    ) throws -> Result {
        do {
            let result = try operation(modelContext)
            if modelContext.hasChanges {
                try modelContext.save()
            }
            return result
        } catch let databaseError as DatabaseError {
            modelContext.rollback()
            throw databaseError
        } catch {
            modelContext.rollback()
            throw DatabaseError.transactionFailed(String(describing: error))
        }
    }

    /// Rolls back pending changes on this model actor's context.
    public func rollback() {
        modelContext.rollback()
    }
}
