import Foundation
import Testing
@testable import TchopWidgets

/// Verifies widget snapshot persistence contracts.
struct TchopWidgetsTests {
    @Test
    /// Handles snapshot manager persists and loads snapshot.
    func snapshotManagerPersistsAndLoadsSnapshot() throws {
        let suiteName = "TchopWidgetsTests.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let manager = UserDefaultsFeedHeadlineWidgetSnapshotManager(userDefaults: userDefaults)
        let snapshot = FeedHeadlineWidgetSnapshot(headline: "Parrots help others...")

        try manager.save(snapshot)

        #expect(try manager.load() == snapshot)
    }

    @Test
    /// Handles snapshot manager clears stored snapshot.
    func snapshotManagerClearsStoredSnapshot() throws {
        let suiteName = "TchopWidgetsTests.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let manager = UserDefaultsFeedHeadlineWidgetSnapshotManager(userDefaults: userDefaults)
        try manager.save(FeedHeadlineWidgetSnapshot(headline: "Parrots help others..."))

        try manager.clear()

        #expect(try manager.load() == nil)
    }
}
