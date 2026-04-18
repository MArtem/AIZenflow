import CoreData
import Foundation
import SwiftData
import TchopCoreDataDatabase
import TchopDatabaseCore
import TchopSwiftDataDatabase

/// Shared composition contract that resolves a concrete backend manager for the caller.
@MainActor
public protocol DatabaseManagerResolving {
    func makeDatabaseManager(
        configuration: DatabaseConfiguration,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)?
    ) throws -> any DatabaseManaging

    @available(iOS 17, macOS 14, *)
    func makeDatabaseManager(
        configuration: DatabaseConfiguration,
        makeSwiftDataContainer: (() throws -> ModelContainer)?
    ) throws -> any DatabaseManaging

    @available(iOS 17, macOS 14, *)
    func makeDatabaseManager(
        configuration: DatabaseConfiguration,
        makeSwiftDataContainer: (() throws -> ModelContainer)?,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)?
    ) throws -> any DatabaseManaging
}

/// Default resolver that composes the shared contract with concrete backend managers.
@MainActor
public struct DatabaseManagerResolver: DatabaseManagerResolving {
    public init() {}

    public func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)? = nil
    ) throws -> any DatabaseManaging {
        let backendKind = configuration.backendSelectionPolicy.resolveBackendKind()
        guard backendKind == .coreData else {
            throw DatabaseError.backendInitializationFailed(
                "SwiftData backend requested without a SwiftData-capable resolver call."
            )
        }

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

    @available(iOS 17, macOS 14, *)
    public func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        makeSwiftDataContainer: (() throws -> ModelContainer)?
    ) throws -> any DatabaseManaging {
        let backendKind = configuration.backendSelectionPolicy.resolveBackendKind()
        guard backendKind == .swiftData else {
            throw DatabaseError.backendInitializationFailed(
                "Core Data backend requested without a Core Data-capable resolver call."
            )
        }

        guard let makeSwiftDataContainer else {
            throw DatabaseError.backendInitializationFailed(
                "SwiftData backend requested without a ModelContainer factory."
            )
        }

        do {
            return SwiftDataDatabaseManager(modelContainer: try makeSwiftDataContainer())
        } catch {
            throw DatabaseError.backendInitializationFailed(String(describing: error))
        }
    }

    @available(iOS 17, macOS 14, *)
    public func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        makeSwiftDataContainer: (() throws -> ModelContainer)?,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)?
    ) throws -> any DatabaseManaging {
        switch configuration.backendSelectionPolicy.resolveBackendKind() {
        case .swiftData:
            return try makeDatabaseManager(
                configuration: DatabaseConfiguration(
                    backendSelectionPolicy: .swiftData,
                    isStoredInMemoryOnly: configuration.isStoredInMemoryOnly
                ),
                makeSwiftDataContainer: makeSwiftDataContainer
            )
        case .coreData:
            return try makeDatabaseManager(
                configuration: DatabaseConfiguration(
                    backendSelectionPolicy: .coreData,
                    isStoredInMemoryOnly: configuration.isStoredInMemoryOnly
                ),
                makeCoreDataContainer: makeCoreDataContainer
            )
        }
    }
}

/// Backward-compatible factory facade that delegates to `DatabaseManagerResolver`.
public enum DatabaseServiceFactory {
    @MainActor
    public static func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)? = nil
    ) throws -> any DatabaseManaging {
        try DatabaseManagerResolver().makeDatabaseManager(
            configuration: configuration,
            makeCoreDataContainer: makeCoreDataContainer
        )
    }

    @MainActor
    @available(iOS 17, macOS 14, *)
    public static func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        makeSwiftDataContainer: (() throws -> ModelContainer)?
    ) throws -> any DatabaseManaging {
        try DatabaseManagerResolver().makeDatabaseManager(
            configuration: configuration,
            makeSwiftDataContainer: makeSwiftDataContainer
        )
    }

    @MainActor
    @available(iOS 17, macOS 14, *)
    public static func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        makeSwiftDataContainer: (() throws -> ModelContainer)?,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)?
    ) throws -> any DatabaseManaging {
        try DatabaseManagerResolver().makeDatabaseManager(
            configuration: configuration,
            makeSwiftDataContainer: makeSwiftDataContainer,
            makeCoreDataContainer: makeCoreDataContainer
        )
    }
}
