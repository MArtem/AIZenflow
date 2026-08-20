import Foundation

/// App-group JSON store setup failures.
public enum AppGroupJSONItemDirectoryStoreError: Error, Equatable, Sendable {
    case unavailableSharedContainer(groupIdentifier: String)
}

/// Result of safe app-group JSON loading with valid items separated from corrupt files.
public struct AppGroupJSONItemDirectoryLoadResult<Item: Sendable>: Sendable {
    public let items: [Item]
    public let failedFileURLs: [URL]

    public init(items: [Item], failedFileURLs: [URL]) {
        self.items = items
        self.failedFileURLs = failedFileURLs
    }
}

/// Stores identifiable JSON items as one atomic file per item in an app-group directory.
///
/// External usage:
/// Used by app and extensions to exchange pending work without depending on shared process memory.
///
/// Identity semantics:
/// This is an identifiable key-value store, not a transactional queue. An item ID identifies one current
/// logical value: saving the same ID replaces that value, and removing the ID removes whichever value is current
/// at removal time. Callers that need revision history, claim/ack delivery, or multiple pending operations for
/// one logical entity must use distinct operation IDs or add that policy above this storage mechanism.
///
/// Thread safety:
/// The store retains immutable path configuration and a delegate-free `FileManager`. Foundation documents
/// delegate-free file-manager operations as safe for concurrent calls, and encoding/decoding uses operation-local
/// instances. The unchecked conformance is limited to the imported `FileManager` reference; callers must still
/// coordinate higher-level read/modify/write semantics when multiple processes can act on the same item ID.
public final class AppGroupJSONItemDirectoryStore<Item>: @unchecked Sendable
where Item: Codable & Identifiable & Sendable, Item.ID == String {
    private let fileManager: FileManager
    private let directoryURL: URL

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
        try Self.applyPrivacyAttributes(to: directoryURL, fileManager: fileManager)
    }

    /// Atomically saves one identifiable item as an individual JSON file, replacing the current value for its ID.
    public func save(_ item: Item) throws {
        let data = try JSONEncoder().encode(item)
        try Self.writePreparedItem(
            data,
            to: fileURL(for: item.id),
            in: directoryURL,
            fileManager: fileManager
        )
    }

    /// Saves one item on a utility task, replacing the current value for its ID.
    public func saveAsync(_ item: Item) async throws {
        let directoryURL = directoryURL
        try await Task.detached(priority: .utility) {
            let data = try JSONEncoder().encode(item)
            let fileURL = directoryURL
                .appendingPathComponent(Self.safeFileName(for: item.id))
                .appendingPathExtension("json")
            try Self.writePreparedItem(
                data,
                to: fileURL,
                in: directoryURL,
                fileManager: .default
            )
        }.value
    }

    /// Loads all items or rethrows the first corrupt file decode error for strict callers.
    public func loadAll() throws -> [Item] {
        let result = try loadAllSafely()
        if let failedFileURL = result.failedFileURLs.first {
            let data = try Data(contentsOf: failedFileURL)
            _ = try JSONDecoder().decode(Item.self, from: data)
        }
        return result.items
    }

    /// Loads valid items and returns corrupt file URLs separately for quarantine/remediation.
    public func loadAllSafely() throws -> AppGroupJSONItemDirectoryLoadResult<Item> {
        try Self.loadAllSafely(in: directoryURL, fileManager: fileManager)
    }

    /// Loads valid items on a utility task and returns corrupt file URLs separately.
    public func loadAllSafelyAsync() async throws -> AppGroupJSONItemDirectoryLoadResult<Item> {
        let directoryURL = directoryURL
        return try await Task.detached(priority: .utility) {
            try Self.loadAllSafely(in: directoryURL, fileManager: .default)
        }.value
    }

    /// Removes one item file matching the provided stable item identifier.
    public func remove(id: String) throws {
        try removeItems(withIDs: [id])
    }

    /// Removes item files matching the provided stable item identifiers.
    public func removeItems(withIDs ids: [String]) throws {
        for id in ids {
            let itemURL = fileURL(for: id)
            guard fileManager.fileExists(atPath: itemURL.path) else {
                continue
            }
            try fileManager.removeItem(at: itemURL)
        }
    }

    /// Removes item files on a utility task.
    public func removeItemsAsync(withIDs ids: [String]) async throws {
        let directoryURL = directoryURL
        try await Task.detached(priority: .utility) {
            let fileManager = FileManager.default
            for id in ids {
                let itemURL = directoryURL
                    .appendingPathComponent(Self.safeFileName(for: id))
                    .appendingPathExtension("json")
                guard fileManager.fileExists(atPath: itemURL.path) else {
                    continue
                }
                try fileManager.removeItem(at: itemURL)
            }
        }.value
    }

    /// Moves files that are still corrupt/unreadable into a quarantine directory for later inspection or cleanup.
    public func quarantineFiles(_ fileURLs: [URL]) throws {
        try Self.quarantineFiles(fileURLs, in: directoryURL, fileManager: fileManager)
    }

    /// Quarantines corrupt/unreadable files on a utility task.
    public func quarantineFilesAsync(_ fileURLs: [URL]) async throws {
        let directoryURL = directoryURL
        try await Task.detached(priority: .utility) {
            try Self.quarantineFiles(fileURLs, in: directoryURL, fileManager: .default)
        }.value
    }

    /// Removes all JSON item files from the directory.
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
        try Self.jsonFileURLs(in: directoryURL, fileManager: fileManager)
    }

    private func fileURL(for id: String) -> URL {
        directoryURL.appendingPathComponent(Self.safeFileName(for: id)).appendingPathExtension("json")
    }

    private static func loadAllSafely(
        in directoryURL: URL,
        fileManager: FileManager
    ) throws -> AppGroupJSONItemDirectoryLoadResult<Item> {
        let fileURLs = try jsonFileURLs(in: directoryURL, fileManager: fileManager)
        let decoder = JSONDecoder()
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

    private static func quarantineFiles(
        _ fileURLs: [URL],
        in directoryURL: URL,
        fileManager: FileManager
    ) throws {
        guard !fileURLs.isEmpty else {
            return
        }

        let quarantineDirectoryURL = directoryURL.appendingPathComponent("corrupted", isDirectory: true)
        try fileManager.createDirectory(
            at: quarantineDirectoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        try applyPrivacyAttributes(to: quarantineDirectoryURL, fileManager: fileManager)

        for fileURL in fileURLs {
            guard fileManager.fileExists(atPath: fileURL.path) else {
                continue
            }

            // A producer may have replaced a previously corrupt file with a valid current value.
            // Revalidate immediately before quarantine so a stale load result does not discard that recovery.
            if
                let data = try? Data(contentsOf: fileURL),
                (try? JSONDecoder().decode(Item.self, from: data)) != nil
            {
                continue
            }

            let quarantineURL = quarantineDirectoryURL
                .appendingPathComponent("\(UUID().uuidString)-\(fileURL.lastPathComponent)")
            if fileManager.fileExists(atPath: quarantineURL.path) {
                try fileManager.removeItem(at: quarantineURL)
            }
            try fileManager.moveItem(at: fileURL, to: quarantineURL)
            try applyPrivacyAttributes(to: quarantineURL, fileManager: fileManager)
        }
    }

    private static func jsonFileURLs(in directoryURL: URL, fileManager: FileManager) throws -> [URL] {
        try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        )
        .filter { $0.pathExtension == "json" }
    }

    private static func writePreparedItem(
        _ data: Data,
        to itemURL: URL,
        in directoryURL: URL,
        fileManager: FileManager
    ) throws {
        let stagingURL = directoryURL.appendingPathComponent(".\(UUID().uuidString).staging")

        do {
            try data.write(to: stagingURL, options: .withoutOverwriting)
            try applyPrivacyAttributes(to: stagingURL, fileManager: fileManager)

            if fileManager.fileExists(atPath: itemURL.path) {
                _ = try fileManager.replaceItemAt(itemURL, withItemAt: stagingURL)
            } else {
                try fileManager.moveItem(at: stagingURL, to: itemURL)
            }
        } catch {
            try? fileManager.removeItem(at: stagingURL)
            throw error
        }
    }

    private static func safeFileName(for id: String) -> String {
        id.replacingOccurrences(of: "/", with: "_")
    }

    private static func applyPrivacyAttributes(to url: URL, fileManager: FileManager) throws {
        try (url as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: url.path
        )
    }
}
