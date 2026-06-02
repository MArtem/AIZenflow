import XCTest
@testable import TchopWidgets

private struct TestWidgetSnapshot: Codable, Equatable, Sendable {
    let headline: String
    let updatedAt: Date
}

final class TchopWidgetsTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "test.widget.snapshot")
        super.tearDown()
    }

    func testUserDefaultsWidgetSnapshotStoreSavesAndLoadsGenericSnapshot() throws {
        let store = UserDefaultsWidgetSnapshotStore<TestWidgetSnapshot>(
            userDefaults: .standard,
            snapshotKey: "test.widget.snapshot"
        )
        let snapshot = TestWidgetSnapshot(
            headline: "Parrots help others...",
            updatedAt: Date(timeIntervalSince1970: 100)
        )

        try store.save(snapshot)

        XCTAssertEqual(try store.load(), snapshot)
    }

    func testUserDefaultsWidgetSnapshotStoreClearsSnapshot() throws {
        let store = UserDefaultsWidgetSnapshotStore<TestWidgetSnapshot>(
            userDefaults: .standard,
            snapshotKey: "test.widget.snapshot"
        )
        try store.save(TestWidgetSnapshot(headline: "Parrots help others...", updatedAt: .now))

        try store.clear()

        XCTAssertNil(try store.load())
    }
}
