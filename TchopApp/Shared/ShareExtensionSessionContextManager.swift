import Foundation

/// Small app-group snapshot that lets the share extension know whether app composer can run.
struct ShareExtensionSessionContext: Codable, Equatable, Sendable {
    let isAuthenticated: Bool
    let availableChannels: [AppChannel]
    let selectedChannelID: String?
}

@MainActor
/// Writes and reads the containing app session/channel snapshot for the share extension.
///
/// Ownership:
/// Owned by app and extension composition; data is exchanged through app-group storage, not process memory.
final class ShareExtensionSessionContextManager {
    private static let directoryName = "share-extension-session"
    private static let fileName = "session-context"

    private let store: AppGroupJSONFileStore<ShareExtensionSessionContext>

    /// Loads the shared session snapshot through the main-actor-owned manager while keeping
    /// blocking file work inside the store's detached operation.
    static func loadFromSharedContainer(groupIdentifier: String) async throws -> ShareExtensionSessionContext? {
        let manager = try ShareExtensionSessionContextManager(groupIdentifier: groupIdentifier)
        return try await manager.loadContextAsync()
    }

    init(groupIdentifier: String) throws {
        self.store = try AppGroupJSONFileStore(
            groupIdentifier: groupIdentifier,
            directoryName: Self.directoryName,
            fileName: Self.fileName
        )
    }

    /// Creates the manager with an explicit file manager for tests and controlled app-group storage.
    init(groupIdentifier: String, fileManager: FileManager) throws {
        self.store = try AppGroupJSONFileStore(
            groupIdentifier: groupIdentifier,
            directoryName: Self.directoryName,
            fileName: Self.fileName,
            fileManager: fileManager
        )
    }

    func syncContext(
        isAuthenticated: Bool,
        availableChannels: [AppChannel],
        selectedChannelID: String?
    ) throws {
        try store.save(
            ShareExtensionSessionContext(
                isAuthenticated: isAuthenticated,
                availableChannels: isAuthenticated ? availableChannels : [],
                selectedChannelID: isAuthenticated ? selectedChannelID : nil
            )
        )
    }

    func loadContext() throws -> ShareExtensionSessionContext? {
        try store.load()
    }

    /// Loads the app-group snapshot without blocking the main actor on file I/O or decoding.
    func loadContextAsync() async throws -> ShareExtensionSessionContext? {
        try await store.loadAsync()
    }
}
