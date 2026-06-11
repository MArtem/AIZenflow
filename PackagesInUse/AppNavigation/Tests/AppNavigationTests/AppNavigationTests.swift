import Foundation
import Testing
import AppNavigation

/// Verifies reusable navigation routing and snapshot persistence contracts.
@MainActor
struct AppNavigationTests {
    @Test
    func tabRouterMutationsUpdatePathAndNotifyChanges() {
        let router = TabRouter<String>()
        var changeCount = 0
        router.onPathChange = { changeCount += 1 }

        router.push("details")
        router.push("comments")
        router.pop()
        router.replacePath(with: ["profile"])
        router.popToRoot()
        router.pop()

        #expect(router.path == [])
        #expect(changeCount == 5)
    }

    @Test
    func navigationStateManagerSavesRestoresClearsAndDropsCorruptedSnapshots() {
        let suiteName = "navigation-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let manager = NavigationStateManager(userDefaults: defaults)
        let snapshot = TestNavigationSnapshot(path: ["feed", "card"], selectedTab: "news")

        manager.saveSnapshot(snapshot, for: "user-1")
        let restored = manager.restoreSnapshot(for: "user-1", as: TestNavigationSnapshot.self)
        #expect(restored == snapshot)

        manager.clearSnapshot(for: "user-1")
        #expect(manager.restoreSnapshot(for: "user-1", as: TestNavigationSnapshot.self) == nil)

        defaults.set(Data("not-json".utf8), forKey: "navigation_snapshot_user-2")
        let corrupted = manager.restoreSnapshot(for: "user-2", as: TestNavigationSnapshot.self)
        #expect(corrupted == nil)
        #expect(defaults.data(forKey: "navigation_snapshot_user-2") == nil)
    }

    @Test
    func memoryReporterRecordsNavigationEventsInOrder() {
        let reporter = NavigationMemoryEventReporter()

        reporter.report(.deepLinkRejected(url: "app://bad", reason: "unknown"))
        reporter.report(.snapshotRestoreSkipped(userID: "user", reason: "empty"))

        #expect(reporter.events == [
            .deepLinkRejected(url: "app://bad", reason: "unknown"),
            .snapshotRestoreSkipped(userID: "user", reason: "empty")
        ])
    }
}

private struct TestNavigationSnapshot: Codable, Equatable {
    let path: [String]
    let selectedTab: String
}
