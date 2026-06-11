import XCTest
@testable import TchopApp

/// Verifies app-level database bootstrap policy for the active SwiftData-only runtime.
@MainActor
final class AppDatabasePolicyTests: XCTestCase {
    /// Verifies the throwing bootstrap API creates an in-memory SwiftData manager.
    func testThrowingDatabaseBootstrapCreatesInMemorySwiftDataManager() throws {
        let manager = try AppDatabase.makeDatabaseManagerOrThrow(
            configuration: DatabaseConfiguration(
                backendSelectionPolicy: .swiftData,
                isStoredInMemoryOnly: true
            )
        )

        XCTAssertTrue(manager is SwiftDataDatabaseManager)
        XCTAssertEqual(manager.backendKind, .swiftData)
    }

    /// Verifies explicit Core Data requests are still resolved to the active SwiftData runtime.
    func testDatabaseBootstrapIgnoresLegacyCoreDataSelectionForActiveRuntime() throws {
        let manager = try AppDatabase.makeDatabaseManagerOrThrow(
            configuration: DatabaseConfiguration(
                backendSelectionPolicy: .coreData,
                isStoredInMemoryOnly: true
            )
        )

        XCTAssertTrue(manager is SwiftDataDatabaseManager)
        XCTAssertEqual(manager.backendKind, .swiftData)
    }
}
