import Foundation

public enum AppGroupJSONItemDirectoryStoreError: Error, Equatable, Sendable {
    case unavailableSharedContainer(groupIdentifier: String)
}

public final class AppGroupJSONItemDirectoryStore<Item>
where Item: Codable & Identifiable & Sendable, Item.ID == String {
    private let fileManager: FileManager
    private let directoryURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        groupIdentifier: String,
        directoryName: String,
        fileManager: FileManager = .default
    ) throws {
        guard let containerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: groupIdentifier
        ) else {
            throw AppGroupJSONItemDirectoryStoreError.unavailableSharedContainer(
                groupIdentifier: groupIdentifier
            )
        }

        self.fileManager = fileManager
        self.directoryURL = containerURL.appendingPathComponent(directoryName, isDirectory: true)
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    public func save(_ item: Item) throws {
        let data = try encoder.encode(item)
        try data.write(to: fileURL(for: item.id), options: [.atomic])
    }

    public func loadAll() throws -> [Item] {
        let fileURLs = try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        )
        .filter { $0.pathExtension == "json" }

        return try fileURLs.map { fileURL in
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(Item.self, from: data)
        }
    }

    public func clear() throws {
        let fileURLs = try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        )

        for fileURL in fileURLs {
            try fileManager.removeItem(at: fileURL)
        }
    }

    private func fileURL(for id: String) -> URL {
        directoryURL.appendingPathComponent(safeFileName(for: id)).appendingPathExtension("json")
    }

    private func safeFileName(for id: String) -> String {
        id.replacingOccurrences(of: "/", with: "_")
    }
}
