import CoreData
import Foundation
import SwiftData
import TchopCoreDataDatabase
import TchopDatabaseCore
import TchopSwiftDataDatabase

/// Groups backend container factories into one reusable composition payload.
@MainActor
public struct DatabaseManagerFactorySet {
    public let makeCoreDataContainer: (() throws -> NSPersistentContainer)?
    private let swiftDataContainerFactory: (() throws -> Any)?

    /// Creates a new DatabaseManagerFactorySet instance.
    public init(
        makeCoreDataContainer: (() throws -> NSPersistentContainer)? = nil
    ) {
        self.makeCoreDataContainer = makeCoreDataContainer
        self.swiftDataContainerFactory = nil
    }

    @available(iOS 17, macOS 14, *)
    /// Creates a new DatabaseManagerFactorySet instance.
    public init(
        makeSwiftDataContainer: (() throws -> ModelContainer)? = nil,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)? = nil
    ) {
        self.makeCoreDataContainer = makeCoreDataContainer
        self.swiftDataContainerFactory = makeSwiftDataContainer.map { factory in
            { try factory() as Any }
        }
    }

    @available(iOS 17, macOS 14, *)
    public var makeSwiftDataContainer: (() throws -> ModelContainer)? {
        guard let swiftDataContainerFactory else {
            return nil
        }

        return {
            guard let container = try swiftDataContainerFactory() as? ModelContainer else {
                throw DatabaseError.backendInitializationFailed(
                    "Invalid SwiftData container factory output."
                )
            }

            return container
        }
    }

    /// Reports backend.
    public func supportsBackend(_ backend: DatabaseBackendKind) -> Bool {
        switch backend {
        case .coreData:
            return makeCoreDataContainer != nil
        case .swiftData:
            if #available(iOS 17, macOS 14, *) {
                return makeSwiftDataContainer != nil
            }
            return false
        }
    }

    public var availableBackends: [DatabaseBackendKind] {
        DatabaseBackendKind.allCases.filter(supportsBackend(_:))
    }
}

/// Shared composition contract that resolves a concrete backend manager for the caller.
@MainActor
public protocol DatabaseManagerResolving {
    /// Handles available backends.
    func availableBackends(
        for factories: DatabaseManagerFactorySet
    ) -> [DatabaseBackendKind]

    /// Creates database manager.
    func makeDatabaseManager(
        configuration: DatabaseConfiguration,
        factories: DatabaseManagerFactorySet
    ) throws -> any DatabaseManaging

    /// Creates database manager.
    func makeDatabaseManager(
        configuration: DatabaseConfiguration,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)?
    ) throws -> any DatabaseManaging

    @available(iOS 17, macOS 14, *)
    /// Creates database manager.
    func makeDatabaseManager(
        configuration: DatabaseConfiguration,
        makeSwiftDataContainer: (() throws -> ModelContainer)?
    ) throws -> any DatabaseManaging

    @available(iOS 17, macOS 14, *)
    /// Creates database manager.
    func makeDatabaseManager(
        configuration: DatabaseConfiguration,
        makeSwiftDataContainer: (() throws -> ModelContainer)?,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)?
    ) throws -> any DatabaseManaging
}

/// Default resolver that composes the shared contract with concrete backend managers.
@MainActor
public struct DatabaseManagerResolver: DatabaseManagerResolving {
    /// Creates a new DatabaseManagerResolver instance.
    public init() {}

    /// Handles available backends.
    public func availableBackends(
        for factories: DatabaseManagerFactorySet
    ) -> [DatabaseBackendKind] {
        factories.availableBackends
    }

    /// Creates database manager.
    public func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        factories: DatabaseManagerFactorySet
    ) throws -> any DatabaseManaging {
        let backendKind = configuration.backendSelectionPolicy.resolveBackendKind()
        guard factories.supportsBackend(backendKind) else {
            throw DatabaseError.backendInitializationFailed(
                "Requested backend \(backendKind.rawValue) is unavailable for the provided factories."
            )
        }

        switch backendKind {
        case .coreData:
            guard let makeCoreDataContainer = factories.makeCoreDataContainer else {
                throw DatabaseError.backendInitializationFailed(
                    "Core Data backend requested without an NSPersistentContainer factory."
                )
            }

            do {
                return CoreDataDatabaseManager(persistentContainer: try makeCoreDataContainer())
            } catch {
                throw DatabaseError.backendInitializationFailed(String(describing: error))
            }
        case .swiftData:
            if #available(iOS 17, macOS 14, *) {
                guard let makeSwiftDataContainer = factories.makeSwiftDataContainer else {
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

            throw DatabaseError.backendInitializationFailed(
                "SwiftData backend is unavailable on the current platform version."
            )
        }
    }

    /// Creates database manager.
    public func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)? = nil
    ) throws -> any DatabaseManaging {
        try makeDatabaseManager(
            configuration: configuration,
            factories: DatabaseManagerFactorySet(makeCoreDataContainer: makeCoreDataContainer)
        )
    }

    @available(iOS 17, macOS 14, *)
    /// Creates database manager.
    public func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        makeSwiftDataContainer: (() throws -> ModelContainer)?
    ) throws -> any DatabaseManaging {
        try makeDatabaseManager(
            configuration: configuration,
            factories: DatabaseManagerFactorySet(
                makeSwiftDataContainer: makeSwiftDataContainer
            )
        )
    }

    @available(iOS 17, macOS 14, *)
    /// Creates database manager.
    public func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        makeSwiftDataContainer: (() throws -> ModelContainer)?,
        makeCoreDataContainer: (() throws -> NSPersistentContainer)?
    ) throws -> any DatabaseManaging {
        try makeDatabaseManager(
            configuration: configuration,
            factories: DatabaseManagerFactorySet(
                makeSwiftDataContainer: makeSwiftDataContainer,
                makeCoreDataContainer: makeCoreDataContainer
            )
        )
    }
}

/// Backward-compatible factory facade that delegates to `DatabaseManagerResolver`.
public enum DatabaseServiceFactory {
    @MainActor
    public static func availableBackends(
        for factories: DatabaseManagerFactorySet
    ) -> [DatabaseBackendKind] {
        DatabaseManagerResolver().availableBackends(for: factories)
    }

    @MainActor
        /// Backward-compatible facade for resolving a database manager from explicit factories.
public static func makeDatabaseManager(
        configuration: DatabaseConfiguration = .persistent,
        factories: DatabaseManagerFactorySet
    ) throws -> any DatabaseManaging {
        try DatabaseManagerResolver().makeDatabaseManager(
            configuration: configuration,
            factories: factories
        )
    }

    @MainActor
        /// Backward-compatible facade for resolving a database manager from explicit factories.
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
        /// Backward-compatible facade for resolving a database manager from explicit factories.
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
        /// Backward-compatible facade for resolving a database manager from explicit factories.
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
