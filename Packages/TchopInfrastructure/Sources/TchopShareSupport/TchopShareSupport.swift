import Foundation

public enum AppGroupJSONItemDirectoryStoreError: Error, Equatable, Sendable {
    case unavailableSharedContainer(groupIdentifier: String)
}

public struct AppGroupJSONItemDirectoryLoadResult<Item: Sendable>: Sendable {
    public let items: [Item]
    public let failedFileURLs: [URL]

    public init(items: [Item], failedFileURLs: [URL]) {
        self.items = items
        self.failedFileURLs = failedFileURLs
    }
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
        let result = try loadAllSafely()
        if let failedFileURL = result.failedFileURLs.first {
            let data = try Data(contentsOf: failedFileURL)
            _ = try decoder.decode(Item.self, from: data)
        }
        return result.items
    }

    public func loadAllSafely() throws -> AppGroupJSONItemDirectoryLoadResult<Item> {
        let fileURLs = try jsonFileURLs()
        var items: [Item] = []
        var failedFileURLs: [URL] = []

        for fileURL in fileURLs {
            do {
                let data = try Data(contentsOf: fileURL)
                items.append(try decoder.decode(Item.self, from: data))
            } catch {
                failedFileURLs.append(fileURL)
            }
        }

        return AppGroupJSONItemDirectoryLoadResult(items: items, failedFileURLs: failedFileURLs)
    }

    public func removeItems(withIDs ids: [String]) throws {
        for id in ids {
            let itemURL = fileURL(for: id)
            guard fileManager.fileExists(atPath: itemURL.path) else {
                continue
            }
            try fileManager.removeItem(at: itemURL)
        }
    }

    public func quarantineFiles(_ fileURLs: [URL]) throws {
        guard !fileURLs.isEmpty else {
            return
        }

        let quarantineDirectoryURL = directoryURL.appendingPathComponent("corrupted", isDirectory: true)
        try fileManager.createDirectory(
            at: quarantineDirectoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        for fileURL in fileURLs {
            guard fileManager.fileExists(atPath: fileURL.path) else {
                continue
            }

            let quarantineURL = quarantineDirectoryURL
                .appendingPathComponent("\(UUID().uuidString)-\(fileURL.lastPathComponent)")
            if fileManager.fileExists(atPath: quarantineURL.path) {
                try fileManager.removeItem(at: quarantineURL)
            }
            try fileManager.moveItem(at: fileURL, to: quarantineURL)
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

    private func jsonFileURLs() throws -> [URL] {
        try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        )
        .filter { $0.pathExtension == "json" }
    }

    private func fileURL(for id: String) -> URL {
        directoryURL.appendingPathComponent(safeFileName(for: id)).appendingPathExtension("json")
    }

    private func safeFileName(for id: String) -> String {
        id.replacingOccurrences(of: "/", with: "_")
    }
}
