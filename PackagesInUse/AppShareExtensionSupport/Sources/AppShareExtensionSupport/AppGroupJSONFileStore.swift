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
        try Self.applyPrivacyAttributes(to: directoryURL, fileManager: fileManager)

        self.fileManager = fileManager
        self.fileURL = directoryURL.appendingPathComponent(fileName).appendingPathExtension("json")
    }

    /// Atomically writes the current snapshot value to the app-group file.
    public func save(_ item: Item) throws {
        let data = try encoder.encode(item)
        try data.write(to: fileURL, options: [.atomic])
        try Self.applyPrivacyAttributes(to: fileURL, fileManager: fileManager)
    }

    /// Atomically writes a snapshot without performing encoding or file I/O on the caller's executor.
    @MainActor
    public func saveAsync(_ item: Item) async throws {
        let fileURL = fileURL
        let operation = Task.detached(priority: .utility) {
            try Task.checkCancellation()
            let data = try JSONEncoder().encode(item)
            try data.write(to: fileURL, options: [.atomic])
            try Task.checkCancellation()
        }

        try await withTaskCancellationHandler(operation: {
            try await operation.value
        }, onCancel: {
            operation.cancel()
        })
    }

    /// Loads the current snapshot value, returning `nil` when the file does not exist.
    public func load() throws -> Item? {
        guard fileManager.fileExists(atPath: fileURL.path()) else {
            return nil
        }

        let data = try Self.readData(from: fileURL)
        return try decoder.decode(Item.self, from: data)
    }

    /// Loads a snapshot without performing file I/O or decoding on the caller's executor.
    @MainActor
    public func loadAsync() async throws -> Item? {
        guard let data = try await Self.readDataIfPresentAsync(from: fileURL) else {
            return nil
        }
        return try decoder.decode(Item.self, from: data)
    }

    /// Removes the snapshot file if it exists.
    public func clear() throws {
        guard fileManager.fileExists(atPath: fileURL.path()) else {
            return
        }

        try fileManager.removeItem(at: fileURL)
    }

    private static func applyPrivacyAttributes(to url: URL, fileManager: FileManager) throws {
        try (url as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: url.path
        )
    }

    private static func readData(from url: URL) throws -> Data {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        return try handle.readToEnd() ?? Data()
    }

    private static func readDataIfPresentAsync(from url: URL) async throws -> Data? {
        let operation = Task.detached(priority: .utility) { () -> Data? in
            try Task.checkCancellation()
            guard FileManager.default.fileExists(atPath: url.path) else {
                return nil
            }
            let data = try Self.readData(from: url)
            try Task.checkCancellation()
            return data
        }

        return try await withTaskCancellationHandler(operation: {
            try await operation.value
        }, onCancel: {
            operation.cancel()
        })
    }
}
