import Foundation

public struct FileStorageNamespace: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String { "FileStorageNamespace(<redacted>)" }
}

public struct FileStorageRelativePath: Hashable, Codable, Sendable, CustomStringConvertible {
    public let components: [String]

    public init(_ components: [String]) throws {
        let sanitizedComponents = try components.map { try FileStorageRelativePath.validateComponent($0) }
        guard !sanitizedComponents.isEmpty else {
            throw FileStorageError.invalidRelativePath(reason: .empty)
        }
        self.components = sanitizedComponents
    }

    public init(_ first: String, _ rest: String...) throws {
        try self.init([first] + rest)
    }

    public var pathString: String {
        components.joined(separator: "/")
    }

    public var fileName: String {
        components.last ?? ""
    }

    public var description: String {
        "FileStorageRelativePath(<redacted>, components: \(components.count))"
    }

    private static func validateComponent(_ component: String) throws -> String {
        let trimmed = component.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw FileStorageError.invalidRelativePath(reason: .emptyComponent)
        }
        guard trimmed != ".", trimmed != ".." else {
            throw FileStorageError.invalidRelativePath(reason: .directoryTraversal)
        }
        guard !trimmed.contains("/") else {
            throw FileStorageError.invalidRelativePath(reason: .containsSeparator)
        }
        guard !trimmed.contains("\\") else {
            throw FileStorageError.invalidRelativePath(reason: .containsSeparator)
        }
        guard trimmed.rangeOfCharacter(from: .controlCharacters) == nil else {
            throw FileStorageError.invalidRelativePath(reason: .containsControlCharacter)
        }
        return trimmed
    }
}

public enum FileStorageRoot: Hashable, Codable, Sendable, CustomStringConvertible {
    case documents
    case caches
    case applicationSupport
    case temporary
    case custom(FileStorageNamespace)

    public var description: String {
        switch self {
        case .documents: "documents"
        case .caches: "caches"
        case .applicationSupport: "applicationSupport"
        case .temporary: "temporary"
        case .custom: "custom(<redacted>)"
        }
    }
}

public struct FileStorageDirectory: Hashable, Sendable, CustomStringConvertible {
    public let root: FileStorageRoot
    public let namespace: FileStorageNamespace?
    public let url: URL

    public init(root: FileStorageRoot, namespace: FileStorageNamespace? = nil, url: URL) {
        self.root = root
        self.namespace = namespace
        self.url = url
    }

    public var description: String {
        "FileStorageDirectory(root: \(root), namespace: \(namespace.map { String(describing: $0) } ?? "none"), url: <redacted>)"
    }
}

public protocol FileStorageDirectoryProviding: Sendable {
    func directory(for root: FileStorageRoot, namespace: FileStorageNamespace?) throws -> FileStorageDirectory
}

public struct StaticFileStorageDirectoryProvider: FileStorageDirectoryProviding {
    private let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func directory(for root: FileStorageRoot, namespace: FileStorageNamespace?) throws -> FileStorageDirectory {
        var directoryURL = baseURL.appendingPathComponent(FileStorageRootDirectoryNames.directoryName(for: root), isDirectory: true)
        if let namespace {
            let namespaceName = FileStoragePathSanitizer.safeDirectoryName(for: namespace.rawValue)
            directoryURL.appendPathComponent(namespaceName, isDirectory: true)
        }
        return FileStorageDirectory(root: root, namespace: namespace, url: directoryURL)
    }
}

public struct DefaultFileStorageDirectoryProvider: FileStorageDirectoryProviding {
    public init() {}

    public func directory(for root: FileStorageRoot, namespace: FileStorageNamespace?) throws -> FileStorageDirectory {
        let fileManager = FileManager.default
        let baseURL: URL
        switch root {
        case .documents:
            baseURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .caches:
            baseURL = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .applicationSupport:
            baseURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .temporary:
            baseURL = fileManager.temporaryDirectory
        case .custom:
            baseURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        }

        var directoryURL = baseURL
        if case .custom = root {
            directoryURL.appendPathComponent(FileStorageRootDirectoryNames.directoryName(for: root), isDirectory: true)
        }
        if let namespace {
            let namespaceName = FileStoragePathSanitizer.safeDirectoryName(for: namespace.rawValue)
            directoryURL.appendPathComponent(namespaceName, isDirectory: true)
        }
        return FileStorageDirectory(root: root, namespace: namespace, url: directoryURL)
    }
}

private enum FileStorageRootDirectoryNames {
    static func directoryName(for root: FileStorageRoot) -> String {
        switch root {
        case .documents:
            return "documents"
        case .caches:
            return "caches"
        case .applicationSupport:
            return "applicationSupport"
        case .temporary:
            return "temporary"
        case let .custom(namespace):
            return FileStoragePathSanitizer.safeDirectoryName(for: namespace.rawValue)
        }
    }
}

public struct FileStoragePathSanitizer: Sendable {
    public init() {}

    public static func safeFileName(for input: String, replacement: Character = "-") -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._-"))
        let scalars = trimmed.unicodeScalars.map { scalar -> Character in
            allowed.contains(scalar) ? Character(scalar) : replacement
        }
        let result = String(scalars).trimmingCharacters(in: CharacterSet(charactersIn: String(replacement)))
        return result.isEmpty ? "file" : result
    }

    public static func safeDirectoryName(for input: String) -> String {
        safeFileName(for: input, replacement: "-")
    }
}

public enum FileStorageInvalidPathReason: String, Codable, Sendable {
    case empty
    case emptyComponent
    case directoryTraversal
    case containsSeparator
    case containsControlCharacter
}

public enum FileStorageError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidRelativePath(reason: FileStorageInvalidPathReason)
    case directoryCreationFailed(code: String)
    case writeFailed(code: String)
    case readFailed(code: String)
    case removeFailed(code: String)
    case moveFailed(code: String)
    case fileNotFound
    case notAFile
    case notADirectory

    public var description: String {
        switch self {
        case let .invalidRelativePath(reason): "invalid_relative_path_\(reason.rawValue)"
        case let .directoryCreationFailed(code): "directory_creation_failed_\(code)"
        case let .writeFailed(code): "write_failed_\(code)"
        case let .readFailed(code): "read_failed_\(code)"
        case let .removeFailed(code): "remove_failed_\(code)"
        case let .moveFailed(code): "move_failed_\(code)"
        case .fileNotFound: "file_not_found"
        case .notAFile: "not_a_file"
        case .notADirectory: "not_a_directory"
        }
    }
}

public struct FileStorageWriteOptions: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let atomic = FileStorageWriteOptions(rawValue: 1 << 0)
    public static let replaceExisting = FileStorageWriteOptions(rawValue: 1 << 1)
    public static let createIntermediateDirectories = FileStorageWriteOptions(rawValue: 1 << 2)

    public static let `default`: FileStorageWriteOptions = [.atomic, .replaceExisting, .createIntermediateDirectories]
}

public struct FileStorageReadOptions: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let requireRegularFile = FileStorageReadOptions(rawValue: 1 << 0)
    public static let `default`: FileStorageReadOptions = [.requireRegularFile]
}

public struct FileStorageAttributes: Equatable, Codable, Sendable {
    public let sizeInBytes: Int64
    public let createdAt: Date?
    public let modifiedAt: Date?
    public let isDirectory: Bool
    public let isRegularFile: Bool

    public init(sizeInBytes: Int64, createdAt: Date?, modifiedAt: Date?, isDirectory: Bool, isRegularFile: Bool) {
        self.sizeInBytes = sizeInBytes
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.isDirectory = isDirectory
        self.isRegularFile = isRegularFile
    }
}

public struct FileStorageEntry: Equatable, Codable, Sendable, CustomStringConvertible {
    public let relativePath: FileStorageRelativePath
    public let attributes: FileStorageAttributes

    public init(relativePath: FileStorageRelativePath, attributes: FileStorageAttributes) {
        self.relativePath = relativePath
        self.attributes = attributes
    }

    public var description: String {
        "FileStorageEntry(path: <redacted>, sizeInBytes: \(attributes.sizeInBytes))"
    }
}

public struct FileStorageCleanupPolicy: Equatable, Sendable {
    public let maximumAge: TimeInterval?
    public let allowedFileExtensions: Set<String>?
    public let removeEmptyDirectories: Bool

    public init(maximumAge: TimeInterval? = nil, allowedFileExtensions: Set<String>? = nil, removeEmptyDirectories: Bool = true) {
        self.maximumAge = maximumAge
        self.allowedFileExtensions = allowedFileExtensions?.map { $0.lowercased() }.reduce(into: Set<String>()) { $0.insert($1) }
        self.removeEmptyDirectories = removeEmptyDirectories
    }
}

public struct FileStorageCleanupResult: Equatable, Codable, Sendable {
    public let removedFileCount: Int
    public let removedDirectoryCount: Int
    public let removedBytes: Int64

    public init(removedFileCount: Int, removedDirectoryCount: Int, removedBytes: Int64) {
        self.removedFileCount = removedFileCount
        self.removedDirectoryCount = removedDirectoryCount
        self.removedBytes = removedBytes
    }
}

public struct FileStorageDiagnosticSnapshot: Equatable, Codable, Sendable, CustomStringConvertible {
    public let root: FileStorageRoot
    public let namespaceIsSet: Bool
    public let fileCount: Int
    public let directoryCount: Int
    public let totalSizeInBytes: Int64

    public init(root: FileStorageRoot, namespaceIsSet: Bool, fileCount: Int, directoryCount: Int, totalSizeInBytes: Int64) {
        self.root = root
        self.namespaceIsSet = namespaceIsSet
        self.fileCount = fileCount
        self.directoryCount = directoryCount
        self.totalSizeInBytes = totalSizeInBytes
    }

    public var description: String {
        "FileStorageDiagnosticSnapshot(root: \(root), namespaceIsSet: \(namespaceIsSet), fileCount: \(fileCount), directoryCount: \(directoryCount), totalSizeInBytes: \(totalSizeInBytes))"
    }
}

public protocol FileStoring: Sendable {
    func write(_ data: Data, to path: FileStorageRelativePath, options: FileStorageWriteOptions) async throws
    func copyFile(from sourceURL: URL, to path: FileStorageRelativePath, options: FileStorageWriteOptions) async throws
    func read(from path: FileStorageRelativePath, options: FileStorageReadOptions) async throws -> Data
    func exists(_ path: FileStorageRelativePath) async -> Bool
    func fileURL(for path: FileStorageRelativePath) async throws -> URL
    func attributes(for path: FileStorageRelativePath) async throws -> FileStorageAttributes
    func remove(_ path: FileStorageRelativePath) async throws
    func removeAll() async throws
    func listFiles(recursive: Bool) async throws -> [FileStorageEntry]
    func totalSizeInBytes() async throws -> Int64
    func cleanup(policy: FileStorageCleanupPolicy, now: Date) async throws -> FileStorageCleanupResult
    func diagnostics() async throws -> FileStorageDiagnosticSnapshot
}


/// Synchronous file operations for platform callbacks that cannot call async actor APIs.
///
/// Prefer `LocalFileStorage` for normal app code. Use this API only for synchronous system callbacks such
/// as `Transferable.FileRepresentation` import closures where the source file must be copied before the
/// callback returns.
public enum FileStorageSynchronousOperations {
    /// Returns the safe filesystem URL for a component-based path.
    public static func fileURL(
        for path: FileStorageRelativePath,
        root: FileStorageRoot,
        namespace: FileStorageNamespace? = nil,
        directoryProvider: FileStorageDirectoryProviding = DefaultFileStorageDirectoryProvider()
    ) throws -> URL {
        let directory = try directoryProvider.directory(for: root, namespace: namespace).url
        var url = directory
        for component in path.components {
            url.appendPathComponent(component, isDirectory: false)
        }
        try validateContainedURL(url, within: directory)
        return url
    }

    /// Copies a file synchronously without loading it into memory.
    @discardableResult
    public static func copyFile(
        from sourceURL: URL,
        to path: FileStorageRelativePath,
        root: FileStorageRoot,
        namespace: FileStorageNamespace? = nil,
        directoryProvider: FileStorageDirectoryProviding = DefaultFileStorageDirectoryProvider(),
        options: FileStorageWriteOptions = .default
    ) throws -> URL {
        let destination = try fileURL(for: path, root: root, namespace: namespace, directoryProvider: directoryProvider)
        let directory = try directoryProvider.directory(for: root, namespace: namespace).url
        let parent = destination.deletingLastPathComponent()
        if options.contains(.createIntermediateDirectories) {
            try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        }
        try validateContainedURL(destination, within: directory)
        if !options.contains(.replaceExisting), FileManager.default.fileExists(atPath: destination.path) {
            throw FileStorageError.writeFailed(code: "file_exists")
        }
        do {
            if options.contains(.atomic) {
                try atomicCopyFile(from: sourceURL, to: destination)
            } else {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: sourceURL, to: destination)
            }
            try applyPrivacyAttributes(to: destination)
            return destination
        } catch let error as FileStorageError {
            throw error
        } catch {
            throw FileStorageError.writeFailed(code: "copy_failed")
        }
    }

    private static func validateContainedURL(_ url: URL, within directory: URL) throws {
        let rootPath = directory.standardizedFileURL.resolvingSymlinksInPath().path
        let candidatePath = url.standardizedFileURL.resolvingSymlinksInPath().path
        guard candidatePath == rootPath || candidatePath.hasPrefix(rootPath + "/") else {
            throw FileStorageError.invalidRelativePath(reason: .directoryTraversal)
        }
    }

    private static func atomicCopyFile(from sourceURL: URL, to destination: URL) throws {
        let parent = destination.deletingLastPathComponent()
        let temporaryName = ".copy-\(UUID().uuidString).partial"
        let temporaryURL = parent.appendingPathComponent(temporaryName, isDirectory: false)
        do {
            try FileManager.default.copyItem(at: sourceURL, to: temporaryURL)
            if FileManager.default.fileExists(atPath: destination.path) {
                _ = try FileManager.default.replaceItemAt(destination, withItemAt: temporaryURL, backupItemName: nil, options: [])
            } else {
                try FileManager.default.moveItem(at: temporaryURL, to: destination)
            }
        } catch {
            if FileManager.default.fileExists(atPath: temporaryURL.path) {
                try? FileManager.default.removeItem(at: temporaryURL)
            }
            throw FileStorageError.writeFailed(code: "atomic_copy_failed")
        }
    }

    private static func applyPrivacyAttributes(to url: URL) throws {
        do {
            try (url as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: url.path
            )
        } catch {
            throw FileStorageError.writeFailed(code: "privacy_attributes_failed")
        }
    }
}

public actor LocalFileStorage: FileStoring {
    private let root: FileStorageRoot
    private let namespace: FileStorageNamespace?
    private let directoryProvider: FileStorageDirectoryProviding

    public init(root: FileStorageRoot, namespace: FileStorageNamespace? = nil, directoryProvider: FileStorageDirectoryProviding = DefaultFileStorageDirectoryProvider()) {
        self.root = root
        self.namespace = namespace
        self.directoryProvider = directoryProvider
    }

    public func write(_ data: Data, to path: FileStorageRelativePath, options: FileStorageWriteOptions = .default) async throws {
        let destination = try resolvedURL(for: path)
        let parent = destination.deletingLastPathComponent()
        if options.contains(.createIntermediateDirectories) {
            try createDirectoryIfNeeded(parent)
        }

        if !options.contains(.replaceExisting), FileManager.default.fileExists(atPath: destination.path) {
            throw FileStorageError.writeFailed(code: "file_exists")
        }

        try validateContainedURL(destination, within: storageDirectory().url)

        if options.contains(.atomic) {
            try atomicWrite(data, to: destination)
        } else {
            do {
                try data.write(to: destination, options: [])
            } catch {
                throw FileStorageError.writeFailed(code: "write_failed")
            }
        }
        try applyPrivacyAttributes(to: destination)
    }

    /// Copies a file into storage without loading the whole payload into memory.
    ///
    /// The source URL is treated as an already-authorized caller-provided file. Destination path safety,
    /// containment, replacement policy, and parent directory creation are enforced by this storage actor.
    public func copyFile(from sourceURL: URL, to path: FileStorageRelativePath, options: FileStorageWriteOptions = .default) async throws {
        let destination = try resolvedURL(for: path)
        let parent = destination.deletingLastPathComponent()
        if options.contains(.createIntermediateDirectories) {
            try createDirectoryIfNeeded(parent)
        }

        try validateContainedURL(destination, within: storageDirectory().url)

        if !options.contains(.replaceExisting), FileManager.default.fileExists(atPath: destination.path) {
            throw FileStorageError.writeFailed(code: "file_exists")
        }

        if options.contains(.atomic) {
            try atomicCopyFile(from: sourceURL, to: destination)
        } else {
            do {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: sourceURL, to: destination)
            } catch {
                throw FileStorageError.writeFailed(code: "copy_failed")
            }
        }
        try applyPrivacyAttributes(to: destination)
    }

    public func read(from path: FileStorageRelativePath, options: FileStorageReadOptions = .default) async throws -> Data {
        let url = try resolvedURL(for: path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FileStorageError.fileNotFound
        }
        if options.contains(.requireRegularFile) {
            let attributes = try attributes(forURL: url)
            guard attributes.isRegularFile else {
                throw FileStorageError.notAFile
            }
        }
        do {
            return try await AsyncFileDataReader.read(from: url)
        } catch let error as CancellationError {
            throw error
        } catch {
            throw FileStorageError.readFailed(code: "read_failed")
        }
    }

    public func exists(_ path: FileStorageRelativePath) async -> Bool {
        do {
            let url = try resolvedURL(for: path)
            return FileManager.default.fileExists(atPath: url.path)
        } catch {
            return false
        }
    }

    /// Returns the safe filesystem URL for platform APIs that require file URLs.
    ///
    /// The returned URL is still considered sensitive and must not be logged or exposed in diagnostics.
    /// Callers that need an existing file should combine this with `exists(_:)` or `attributes(for:)`.
    public func fileURL(for path: FileStorageRelativePath) async throws -> URL {
        try resolvedURL(for: path)
    }

    public func attributes(for path: FileStorageRelativePath) async throws -> FileStorageAttributes {
        try attributes(forURL: resolvedURL(for: path))
    }

    public func remove(_ path: FileStorageRelativePath) async throws {
        let url = try resolvedURL(for: path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw FileStorageError.removeFailed(code: "remove_failed")
        }
    }

    public func removeAll() async throws {
        let directory = try storageDirectory().url
        guard FileManager.default.fileExists(atPath: directory.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(at: directory)
        } catch {
            throw FileStorageError.removeFailed(code: "remove_all_failed")
        }
    }

    public func listFiles(recursive: Bool = true) async throws -> [FileStorageEntry] {
        let directory = try storageDirectory().url
        guard FileManager.default.fileExists(atPath: directory.path) else {
            return []
        }
        let urls = try listedURLs(in: directory, recursive: recursive)
        return try urls.compactMap { url in
            let attributes = try attributes(forURL: url)
            guard attributes.isRegularFile else { return nil }
            return try FileStorageEntry(relativePath: relativePath(for: url, baseURL: directory), attributes: attributes)
        }
        .sorted { $0.relativePath.pathString < $1.relativePath.pathString }
    }

    public func totalSizeInBytes() async throws -> Int64 {
        try await listFiles(recursive: true).reduce(Int64(0)) { $0 + $1.attributes.sizeInBytes }
    }

    public func cleanup(policy: FileStorageCleanupPolicy, now: Date = Date()) async throws -> FileStorageCleanupResult {
        let directory = try storageDirectory().url
        guard FileManager.default.fileExists(atPath: directory.path) else {
            return FileStorageCleanupResult(removedFileCount: 0, removedDirectoryCount: 0, removedBytes: 0)
        }

        let urls = try listedURLs(in: directory, recursive: true)
        var removedFiles = 0
        var removedDirectories = 0
        var removedBytes: Int64 = 0

        for url in urls.sorted(by: { $0.path.count > $1.path.count }) {
            let attributes = try attributes(forURL: url)
            if attributes.isDirectory {
                if policy.removeEmptyDirectories, isDirectoryEmpty(url) {
                    do {
                        try FileManager.default.removeItem(at: url)
                        removedDirectories += 1
                    } catch {
                        throw FileStorageError.removeFailed(code: "remove_directory_failed")
                    }
                }
                continue
            }

            guard attributes.isRegularFile else { continue }
            guard shouldRemoveFile(url: url, attributes: attributes, policy: policy, now: now) else { continue }
            do {
                try FileManager.default.removeItem(at: url)
                removedFiles += 1
                removedBytes += attributes.sizeInBytes
            } catch {
                throw FileStorageError.removeFailed(code: "remove_file_failed")
            }
        }

        return FileStorageCleanupResult(removedFileCount: removedFiles, removedDirectoryCount: removedDirectories, removedBytes: removedBytes)
    }

    public func diagnostics() async throws -> FileStorageDiagnosticSnapshot {
        let directory = try storageDirectory().url
        guard FileManager.default.fileExists(atPath: directory.path) else {
            return FileStorageDiagnosticSnapshot(root: root, namespaceIsSet: namespace != nil, fileCount: 0, directoryCount: 0, totalSizeInBytes: 0)
        }
        let urls = try listedURLs(in: directory, recursive: true)
        var fileCount = 0
        var directoryCount = 0
        var totalSize: Int64 = 0
        for url in urls {
            let attributes = try attributes(forURL: url)
            if attributes.isDirectory {
                directoryCount += 1
            } else if attributes.isRegularFile {
                fileCount += 1
                totalSize += attributes.sizeInBytes
            }
        }
        return FileStorageDiagnosticSnapshot(root: root, namespaceIsSet: namespace != nil, fileCount: fileCount, directoryCount: directoryCount, totalSizeInBytes: totalSize)
    }

    private func storageDirectory() throws -> FileStorageDirectory {
        try directoryProvider.directory(for: root, namespace: namespace)
    }

    private func resolvedURL(for path: FileStorageRelativePath) throws -> URL {
        let directory = try storageDirectory().url
        var url = directory
        for component in path.components {
            url.appendPathComponent(component, isDirectory: false)
        }
        try validateContainedURL(url, within: directory)
        return url
    }

    private func validateContainedURL(_ url: URL, within directory: URL) throws {
        let rootPath = directory.standardizedFileURL.resolvingSymlinksInPath().path
        let candidatePath = url.standardizedFileURL.resolvingSymlinksInPath().path
        guard candidatePath == rootPath || candidatePath.hasPrefix(rootPath + "/") else {
            throw FileStorageError.invalidRelativePath(reason: .directoryTraversal)
        }
    }

    private func createDirectoryIfNeeded(_ url: URL) throws {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            throw FileStorageError.directoryCreationFailed(code: "create_directory_failed")
        }
    }

    private func atomicCopyFile(from sourceURL: URL, to destination: URL) throws {
        let parent = destination.deletingLastPathComponent()
        let temporaryName = ".copy-\(UUID().uuidString).partial"
        let temporaryURL = parent.appendingPathComponent(temporaryName, isDirectory: false)
        do {
            try FileManager.default.copyItem(at: sourceURL, to: temporaryURL)
            if FileManager.default.fileExists(atPath: destination.path) {
                _ = try FileManager.default.replaceItemAt(destination, withItemAt: temporaryURL, backupItemName: nil, options: [])
            } else {
                try FileManager.default.moveItem(at: temporaryURL, to: destination)
            }
        } catch {
            if FileManager.default.fileExists(atPath: temporaryURL.path) {
                try removeTemporaryWriteFile(temporaryURL)
            }
            throw FileStorageError.writeFailed(code: "atomic_copy_failed")
        }
    }

    private func atomicWrite(_ data: Data, to destination: URL) throws {
        let parent = destination.deletingLastPathComponent()
        let temporaryName = ".write-\(UUID().uuidString).partial"
        let temporaryURL = parent.appendingPathComponent(temporaryName, isDirectory: false)
        do {
            try data.write(to: temporaryURL, options: [])
            if FileManager.default.fileExists(atPath: destination.path) {
                _ = try FileManager.default.replaceItemAt(destination, withItemAt: temporaryURL, backupItemName: nil, options: [])
            } else {
                try FileManager.default.moveItem(at: temporaryURL, to: destination)
            }
        } catch {
            if FileManager.default.fileExists(atPath: temporaryURL.path) {
                try removeTemporaryWriteFile(temporaryURL)
            }
            throw FileStorageError.writeFailed(code: "atomic_write_failed")
        }
    }

    private func applyPrivacyAttributes(to url: URL) throws {
        do {
            try (url as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: url.path
            )
        } catch {
            throw FileStorageError.writeFailed(code: "privacy_attributes_failed")
        }
    }

    private func removeTemporaryWriteFile(_ url: URL) throws {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw FileStorageError.removeFailed(code: "remove_partial_write_failed")
        }
    }

    private func listedURLs(in directory: URL, recursive: Bool) throws -> [URL] {
        do {
            let children = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey])
            guard recursive else {
                return children
            }

            var result: [URL] = []
            for child in children {
                result.append(child)
                let values = try child.resourceValues(forKeys: [.isDirectoryKey])
                if values.isDirectory == true {
                    result.append(contentsOf: try listedURLs(in: child, recursive: true))
                }
            }
            return result
        } catch {
            throw FileStorageError.readFailed(code: "list_failed")
        }
    }

    private func attributes(forURL url: URL) throws -> FileStorageAttributes {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey])
            return FileStorageAttributes(
                sizeInBytes: Int64(resourceValues.fileSize ?? 0),
                createdAt: resourceValues.creationDate,
                modifiedAt: resourceValues.contentModificationDate,
                isDirectory: resourceValues.isDirectory ?? false,
                isRegularFile: resourceValues.isRegularFile ?? false
            )
        } catch {
            throw FileStorageError.readFailed(code: "attributes_failed")
        }
    }

    private func relativePath(for url: URL, baseURL: URL) throws -> FileStorageRelativePath {
        let baseComponents = baseURL.standardizedFileURL.pathComponents
        let urlComponents = url.standardizedFileURL.pathComponents
        guard urlComponents.count >= baseComponents.count else {
            throw FileStorageError.readFailed(code: "relative_path_failed")
        }
        let relative = Array(urlComponents.dropFirst(baseComponents.count))
        return try FileStorageRelativePath(relative)
    }

    private func isDirectoryEmpty(_ url: URL) -> Bool {
        do {
            return try FileManager.default.contentsOfDirectory(atPath: url.path).isEmpty
        } catch {
            return false
        }
    }

    private func shouldRemoveFile(url: URL, attributes: FileStorageAttributes, policy: FileStorageCleanupPolicy, now: Date) -> Bool {
        if let allowedFileExtensions = policy.allowedFileExtensions, !allowedFileExtensions.isEmpty {
            let ext = url.pathExtension.lowercased()
            guard allowedFileExtensions.contains(ext) else {
                return false
            }
        }

        if let maximumAge = policy.maximumAge {
            guard let modifiedAt = attributes.modifiedAt else {
                return false
            }
            return now.timeIntervalSince(modifiedAt) > maximumAge
        }
        return true
    }
}

/// Performs blocking file reads away from the caller's actor executor.
///
/// The detached operation captures only the sendable URL and propagates cancellation before and
/// after the blocking read. The storage actor remains the owner of path validation and error mapping.
private enum AsyncFileDataReader {
    static func read(from url: URL) async throws -> Data {
        let operation = Task.detached(priority: nil) {
            try Task.checkCancellation()
            let handle = try FileHandle(forReadingFrom: url)
            defer { try? handle.close() }
            let data = try handle.readToEnd() ?? Data()
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
