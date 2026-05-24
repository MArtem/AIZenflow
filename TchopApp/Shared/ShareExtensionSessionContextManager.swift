import Foundation
import TchopShareSupport

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

    init(groupIdentifier: String) throws {
        self.store = try AppGroupJSONFileStore(
            groupIdentifier: groupIdentifier,
            directoryName: Self.directoryName,
            fileName: Self.fileName
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
}
