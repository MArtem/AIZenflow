import Foundation

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

    public func save(_ item: Item) throws {
        let data = try encoder.encode(item)
        try data.write(to: fileURL, options: [.atomic])
    }

    public func load() throws -> Item? {
        guard fileManager.fileExists(atPath: fileURL.path()) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(Item.self, from: data)
    }

    public func clear() throws {
        guard fileManager.fileExists(atPath: fileURL.path()) else {
            return
        }

        try fileManager.removeItem(at: fileURL)
    }
}
