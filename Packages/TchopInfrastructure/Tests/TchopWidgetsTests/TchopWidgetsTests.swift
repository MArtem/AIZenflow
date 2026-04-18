import Foundation
import Testing
@testable import TchopWidgets

struct TchopWidgetsTests {
    @Test
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
