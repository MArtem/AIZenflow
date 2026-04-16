import Foundation

/// UserDefaults-backed navigation snapshot persistence.
@MainActor
final class NavigationStateManager: NavigationStateManaging {
    private enum Constants {
        static let snapshotKeyPrefix = "navigation_snapshot_"
        static let supportedSnapshotVersion = 1
    }

    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        userDefaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }

    func saveSnapshot(_ snapshot: NavigationSnapshot, for userID: String) {
        guard let encodedSnapshot = try? encoder.encode(snapshot) else {
            assertionFailure("Failed to encode navigation snapshot.")
            return
        }

        userDefaults.set(encodedSnapshot, forKey: key(for: userID))
    }

    func restoreSnapshot(for userID: String) -> NavigationSnapshot? {
        guard let rawSnapshot = userDefaults.data(forKey: key(for: userID)) else {
            return nil
        }

        guard let decodedSnapshot = try? decoder.decode(NavigationSnapshot.self, from: rawSnapshot) else {
            userDefaults.removeObject(forKey: key(for: userID))
            return nil
        }

        guard decodedSnapshot.version == Constants.supportedSnapshotVersion else {
            userDefaults.removeObject(forKey: key(for: userID))
            return nil
        }

        return decodedSnapshot
    }

    func clearSnapshot(for userID: String) {
        userDefaults.removeObject(forKey: key(for: userID))
    }

    private func key(for userID: String) -> String {
        Constants.snapshotKeyPrefix + userID
    }
}
