import Foundation

/// Single-file JSON app-group store for lightweight shared snapshots.
///
/// Contract:
/// Suitable for small Codable values; use item-directory storage for append-like pending queues.
public final class AppGroupJSONFileStore<Item> where Item: Codable & Sendable {
    private let fileManager: FileManager
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        groupIdentifier: String,
        directoryName: String,
        fileName: String,
        fileManager: FileManager = .default
    ) throws {
        guard let containerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: groupIdentifier
        ) else {
            throw AppGroupJSONItemDirectoryStoreError.unavailableSharedContainer(
                groupIdentifier: groupIdentifier
            )
        }

        let directoryURL = containerURL.appendingPathComponent(directoryName, isDirectory: true)
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        self.fileManager = fileManager
        self.fileURL = directoryURL.appendingPathComponent(fileName).appendingPathExtension("json")
    }

    /// Atomically writes the current snapshot value to the app-group file.
    public func save(_ item: Item) throws {
        let data = try encoder.encode(item)
        try data.write(to: fileURL, options: [.atomic])
    }

    /// Loads the current snapshot value, returning `nil` when the file does not exist.
    public func load() throws -> Item? {
        guard fileManager.fileExists(atPath: fileURL.path()) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(Item.self, from: data)
    }

    /// Removes the snapshot file if it exists.
    public func clear() throws {
        guard fileManager.fileExists(atPath: fileURL.path()) else {
            return
        }

        try fileManager.removeItem(at: fileURL)
    }
}
