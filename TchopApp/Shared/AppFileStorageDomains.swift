import Foundation

/// App-owned file-storage domains backed by the reusable `AppFileStorage` package.
///
/// Runtime owner:
/// `TchopApp`, `TchopAppOcean`, and share-extension composer flows use this type to keep product
/// directory names stable while delegating path validation, atomic writes, and symlink safety to
/// `AppFileStorage`.
///
/// Compatibility:
/// Composer media continues to live under `Documents/TchopComposerMedia` so existing persisted feed-card
/// media URLs and stale-container fallback resolution remain valid.
enum AppFileStorageDomains {
    static let composerMediaRoot: FileStorageRoot = .documents
    static let composerMediaNamespace = FileStorageNamespace("TchopComposerMedia")

    static var composerMediaStorage: LocalFileStorage {
        LocalFileStorage(root: composerMediaRoot, namespace: composerMediaNamespace)
    }

    static func composerMediaPath(suggestedFilename: String) throws -> FileStorageRelativePath {
        try FileStorageRelativePath(uniqueComposerMediaFilename(suggestedFilename: suggestedFilename))
    }

    static func composerMediaPath(existingFilename: String) throws -> FileStorageRelativePath {
        try FileStorageRelativePath(FileStoragePathSanitizer.safeFileName(for: existingFilename))
    }

    static func composerMediaDirectoryURL() throws -> URL {
        try DefaultFileStorageDirectoryProvider()
            .directory(for: composerMediaRoot, namespace: composerMediaNamespace)
            .url
    }

    static func composerMediaFileURL(for path: FileStorageRelativePath) throws -> URL {
        try FileStorageSynchronousOperations.fileURL(
            for: path,
            root: composerMediaRoot,
            namespace: composerMediaNamespace
        )
    }

    private static func uniqueComposerMediaFilename(suggestedFilename: String) -> String {
        let fallbackFilename = "media"
        let trimmedFilename = suggestedFilename.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidate = trimmedFilename.isEmpty ? fallbackFilename : trimmedFilename
        let sanitizedFilename = FileStoragePathSanitizer.safeFileName(for: candidate)
        return "\(UUID().uuidString)-\(sanitizedFilename)"
    }
}
