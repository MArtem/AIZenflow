import Foundation

/// Seeds the local persistence backend with the initial app content.
@MainActor
enum AppDataSeeder {
    /// Inserts the default channel record on first launch only.
    static func seedIfNeeded(in databaseManager: any AppDatabaseManaging) throws {
        guard try !databaseManager.hasPrimaryChannel() else {
            return
        }

        try databaseManager.performTransaction {
            try databaseManager.insertPrimaryChannel(
                StoredChannel(
                    id: "primary-channel",
                    title: "Tchop",
                    subtitle: "New channel name"
                )
            )
        }
    }
}
