import XCTest
import TchopDatabase
@testable import TchopApp

/// Verifies app-level database runtime policy selection behavior.
final class AppDatabasePolicyTests: XCTestCase {
    /// Verifies automatic policy uses Core Data when SwiftData is unavailable.
    func testAutomaticPolicyUsesCoreDataWhenSwiftDataIsUnavailable() throws {
        let plan = try AppDatabaseRuntimePolicy.plan(
            for: DatabaseConfiguration(backendSelectionPolicy: .automatic),
            context: AppDatabaseRuntimeContext(
                storedBackend: nil,
                hasLegacyCoreDataStoreOnDisk: false,
                supportsSwiftData: false
            )
        )

        XCTAssertEqual(plan, .useCoreData)
    }

    /// Verifies automatic policy prefers SwiftData for fresh installs on supported systems.
    func testAutomaticPolicyUsesSwiftDataForFreshInstall() throws {
        let plan = try AppDatabaseRuntimePolicy.plan(
            for: DatabaseConfiguration(backendSelectionPolicy: .automatic),
            context: AppDatabaseRuntimeContext(
                storedBackend: nil,
                hasLegacyCoreDataStoreOnDisk: false,
                supportsSwiftData: true
            )
        )

        XCTAssertEqual(plan, .useSwiftData)
    }

    /// Verifies automatic policy migrates legacy Core Data installs on supported systems.
    func testAutomaticPolicyMigratesLegacyCoreDataInstall() throws {
        let plan = try AppDatabaseRuntimePolicy.plan(
            for: DatabaseConfiguration(backendSelectionPolicy: .automatic),
            context: AppDatabaseRuntimeContext(
                storedBackend: .coreData,
                hasLegacyCoreDataStoreOnDisk: true,
                supportsSwiftData: true
            )
        )

        XCTAssertEqual(plan, .migrateCoreDataToSwiftData)
    }

    /// Verifies explicit SwiftData policy throws when the platform does not support SwiftData.
    func testExplicitSwiftDataPolicyThrowsWhenSwiftDataIsUnavailable() {
        XCTAssertThrowsError(
            try AppDatabaseRuntimePolicy.plan(
                for: DatabaseConfiguration(backendSelectionPolicy: .swiftData),
                context: AppDatabaseRuntimeContext(
                    storedBackend: nil,
                    hasLegacyCoreDataStoreOnDisk: false,
                    supportsSwiftData: false
                )
            )
        )
    }

    /// Verifies the throwing bootstrap API is available for callers that want to avoid fatalError wrappers.
    @MainActor
    func testThrowingDatabaseBootstrapCreatesInMemoryCoreDataManager() throws {
        let manager = try AppDatabase.makeDatabaseManagerOrThrow(
            configuration: DatabaseConfiguration(
                backendSelectionPolicy: .coreData,
                isStoredInMemoryOnly: true
            )
        )

        XCTAssertTrue(manager is CoreDataDatabaseManager)
    }
}
