import Foundation
import SwiftData
import TchopDatabaseCore

/// SwiftData-backed implementation of `DatabaseManaging`.
@MainActor
@available(iOS 17, macOS 14, *)
public final class SwiftDataDatabaseManager: DatabaseManaging {
    public let modelContainer: ModelContainer

    public var modelContext: ModelContext {
        modelContainer.mainContext
    }

    public let backendKind: DatabaseBackendKind = .swiftData

    /// Creates a new SwiftDataDatabaseManager instance.
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    /// Reads this operation.
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

    /// Writes this operation.
    public func write<Result>(_ operation: DatabaseWriteOperation<Result>) throws -> Result {
        try performWrite(
            operation.swiftData,
            missingOperationMessage: "Missing SwiftData implementation for write operation."
        )
    }

    /// Rolls back this operation.
    public func rollback() {
        modelContext.rollback()
    }

    /// Writes batch.
    public func writeBatch<Result>(_ operation: DatabaseBatchWriteOperation<Result>) throws -> Result {
        try performWrite(
            operation.swiftData,
            missingOperationMessage: "Missing SwiftData implementation for batch write operation."
        )
    }

    private func performWrite<Result>(
        _ operation: (@MainActor (Any) throws -> Result)?,
        missingOperationMessage: String
    ) throws -> Result {
        guard let swiftDataOperation = operation else {
            throw DatabaseError.unsupportedOperation(missingOperationMessage)
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
}
