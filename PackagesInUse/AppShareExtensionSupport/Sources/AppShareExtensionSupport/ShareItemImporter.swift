import Foundation
import UniformTypeIdentifiers

/// Supported file categories imported from share-sheet item providers.
public enum ShareImportedFileKind: String, Codable, Equatable, Sendable {
    case image
    case video
    case pdf
    case audio
}

/// Text payload imported from an external share provider.
public struct ShareImportedTextItem: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let text: String

    public init(id: String = UUID().uuidString, text: String) {
        self.id = id
        self.text = text
    }
}

/// Durable file copy imported from an external share provider.
///
/// Ownership:
/// The importer owns copying provider URLs into the configured app-group or temporary import directory.
public struct ShareImportedFileItem: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let kind: ShareImportedFileKind
    public let originalFilename: String
    public let contentTypeIdentifier: String
    public let fileURL: URL

    public init(
        id: String = UUID().uuidString,
        kind: ShareImportedFileKind,
        originalFilename: String,
        contentTypeIdentifier: String,
        fileURL: URL
    ) {
        self.id = id
        self.kind = kind
        self.originalFilename = originalFilename
        self.contentTypeIdentifier = contentTypeIdentifier
        self.fileURL = fileURL
    }
}

/// Source-neutral imported share item consumed by app or extension composer flows.
public enum ShareImportedItem: Codable, Equatable, Identifiable, Sendable {
    case text(ShareImportedTextItem)
    case file(ShareImportedFileItem)

    public var id: String {
        switch self {
        case let .text(item):
            return item.id
        case let .file(item):
            return item.id
        }
    }
}

/// Import failures surfaced when share providers cannot produce supported content.
public enum ShareItemImportError: Error, Equatable, Sendable {
    case unsupportedProvider
    case unableToDecodeText
    case unableToLoadFileRepresentation(typeIdentifier: String)
    case unsupportedMixedMediaAttachments
    case tooManyImageFiles(maximum: Int)
    case tooManyNonImageFiles(maximum: Int)
    case fileTooLarge(maximumBytes: Int64)
    case totalFileSizeExceeded(maximumBytes: Int64)
}

/// Host-owned limits for one share-import session.
public struct ShareItemImportBudget: Equatable, Sendable {
    public let maximumImageFileCount: Int
    public let maximumNonImageFileCount: Int
    public let maximumFileBytes: Int64
    public let maximumTotalFileBytes: Int64
    public let allowsMixedFileKinds: Bool

    public init(
        maximumImageFileCount: Int,
        maximumNonImageFileCount: Int,
        maximumFileBytes: Int64,
        maximumTotalFileBytes: Int64,
        allowsMixedFileKinds: Bool = true
    ) {
        self.maximumImageFileCount = maximumImageFileCount
        self.maximumNonImageFileCount = maximumNonImageFileCount
        self.maximumFileBytes = maximumFileBytes
        self.maximumTotalFileBytes = maximumTotalFileBytes
        self.allowsMixedFileKinds = allowsMixedFileKinds
    }

    /// Preserves prior behaviour for hosts that have not defined a product import policy.
    public static let unbounded = ShareItemImportBudget(
        maximumImageFileCount: .max,
        maximumNonImageFileCount: .max,
        maximumFileBytes: .max,
        maximumTotalFileBytes: .max,
        allowsMixedFileKinds: true
    )
}

@MainActor
/// Imports `NSItemProvider` payloads into durable text/file share items.
///
/// Ownership:
/// Created by app or extension composition for a share session.
///
/// Concurrency:
/// Main-actor isolated because `NSItemProvider` loading is driven by UIKit/share-extension callbacks;
/// large file copies are moved to utility work where possible.
public final class NSItemProviderShareItemImporter {
    private static let importedFilesDirectoryName = "share-imported-items"

    private let fileManager: FileManager
    private let importedFilesSessionURL: URL
    private let budget: ShareItemImportBudget
    private var activeCopyTask: Task<Int64, Error>?

    public init(
        groupIdentifier: String? = nil,
        fileManager: FileManager = .default,
        budget: ShareItemImportBudget = .unbounded
    ) throws {
        self.fileManager = fileManager
        self.budget = budget

        let rootURL: URL
        if let groupIdentifier {
            guard let containerURL = fileManager.containerURL(
                forSecurityApplicationGroupIdentifier: groupIdentifier
            ) else {
                throw AppGroupJSONItemDirectoryStoreError.unavailableSharedContainer(
                    groupIdentifier: groupIdentifier
                )
            }

            rootURL = containerURL
        } else {
            rootURL = fileManager.temporaryDirectory
        }

        let importedFilesRootURL = rootURL
            .appendingPathComponent(Self.importedFilesDirectoryName, isDirectory: true)
        self.importedFilesSessionURL = importedFilesRootURL
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try fileManager.createDirectory(
            at: importedFilesSessionURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    /// Loads supported text/file items from share providers into durable imported items.
    ///
    /// External usage:
    /// Called by share-extension controllers after receiving `NSExtensionItem` providers.
    public func loadItems(from providers: [NSItemProvider]) async throws -> [ShareImportedItem] {
        var items: [ShareImportedItem] = []
        var imageFileCount = 0
        var nonImageFileCount = 0
        var totalFileBytes: Int64 = 0

        do {
            for provider in providers {
                try Task.checkCancellation()

                if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    items.append(.text(try await loadTextItem(from: provider)))
                    continue
                }

                guard let supportedFile = supportedFileKind(for: provider) else {
                    continue
                }

                switch supportedFile.kind {
                case .image:
                    guard budget.allowsMixedFileKinds || nonImageFileCount == 0 else {
                        throw ShareItemImportError.unsupportedMixedMediaAttachments
                    }
                    guard imageFileCount < budget.maximumImageFileCount else {
                        throw ShareItemImportError.tooManyImageFiles(maximum: budget.maximumImageFileCount)
                    }
                    imageFileCount += 1
                case .video, .pdf, .audio:
                    guard budget.allowsMixedFileKinds || imageFileCount == 0 else {
                        throw ShareItemImportError.unsupportedMixedMediaAttachments
                    }
                    guard nonImageFileCount < budget.maximumNonImageFileCount else {
                        throw ShareItemImportError.tooManyNonImageFiles(maximum: budget.maximumNonImageFileCount)
                    }
                    nonImageFileCount += 1
                }

                let importedFile = try await loadFileItem(
                    from: provider,
                    kind: supportedFile,
                    totalFileBytes: totalFileBytes
                )
                totalFileBytes += importedFile.sizeInBytes
                items.append(.file(importedFile.item))
            }

            if items.isEmpty {
                throw ShareItemImportError.unsupportedProvider
            }

            return items
        } catch {
            try discardImportSession()
            throw error
        }
    }

    /// Deletes imported file copies when a share session ends before they are transferred to the containing app.
    public func discardImportedFiles(in items: [ShareImportedItem]) {
        discardImportedFiles(at: items.compactMap { item in
            guard case let .file(file) = item else {
                return nil
            }
            return file.fileURL
        })
    }

    /// Deletes an import session after its file-copy work has completed.
    public func discardImportSession() throws {
        guard fileManager.fileExists(atPath: importedFilesSessionURL.path) else {
            return
        }
        try fileManager.removeItem(at: importedFilesSessionURL)
    }

    /// Cancels and joins the only active file copy before removing its isolated session.
    public func cancelAndDiscardImportSession() async throws {
        if let activeCopyTask {
            activeCopyTask.cancel()
            _ = try? await activeCopyTask.value
        }
        try discardImportSession()
    }

    private func copyImportedFile(
        from sourceURL: URL,
        to destinationURL: URL,
        remainingTotalFileBytes: Int64
    ) async throws -> Int64 {
        let maximumFileBytes = budget.maximumFileBytes
        let maximumTotalFileBytes = budget.maximumTotalFileBytes
        let copyTask = Task.detached(priority: .utility) {
            let fileManager = FileManager.default
            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                guard fileManager.createFile(atPath: destinationURL.path, contents: nil) else {
                    throw CocoaError(.fileWriteUnknown)
                }

                let sourceHandle = try FileHandle(forReadingFrom: sourceURL)
                defer { try? sourceHandle.close() }
                let destinationHandle = try FileHandle(forWritingTo: destinationURL)
                defer { try? destinationHandle.close() }

                var copiedBytes: Int64 = 0
                while let data = try sourceHandle.read(upToCount: 1_048_576), !data.isEmpty {
                    try Task.checkCancellation()
                    let nextByteCount = Int64(data.count)
                    guard
                        nextByteCount <= maximumFileBytes,
                        copiedBytes <= maximumFileBytes - nextByteCount
                    else {
                        throw ShareItemImportError.fileTooLarge(maximumBytes: maximumFileBytes)
                    }
                    guard
                        nextByteCount <= remainingTotalFileBytes,
                        copiedBytes <= remainingTotalFileBytes - nextByteCount
                    else {
                        throw ShareItemImportError.totalFileSizeExceeded(
                            maximumBytes: maximumTotalFileBytes
                        )
                    }
                    try destinationHandle.write(contentsOf: data)
                    copiedBytes += nextByteCount
                }
                try Task.checkCancellation()
                try destinationHandle.synchronize()

                let copiedSize = try destinationURL.resourceValues(forKeys: [.fileSizeKey]).fileSize
                guard copiedSize.map(Int64.init) == copiedBytes else {
                    throw CocoaError(.fileWriteUnknown)
                }
                return copiedBytes
            } catch {
                try? fileManager.removeItem(at: destinationURL)
                throw error
            }
        }
        activeCopyTask = copyTask
        defer { activeCopyTask = nil }

        return try await withTaskCancellationHandler {
            try await copyTask.value
        } onCancel: {
            copyTask.cancel()
        }
    }

    private func loadTextItem(from provider: NSItemProvider) async throws -> ShareImportedTextItem {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<ShareImportedTextItem, Error>) in
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                if let text = item as? String {
                    continuation.resume(returning: ShareImportedTextItem(text: text))
                    return
                }

                if let data = item as? Data, let text = String(data: data, encoding: .utf8) {
                    continuation.resume(returning: ShareImportedTextItem(text: text))
                    return
                }

                continuation.resume(throwing: ShareItemImportError.unableToDecodeText)
            }
        }
    }

    private func loadFileItem(
        from provider: NSItemProvider,
        kind: SupportedShareFile,
        totalFileBytes: Int64
    ) async throws -> (item: ShareImportedFileItem, sizeInBytes: Int64) {
        let sourceURL: URL = try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<URL, Error>) in
            provider.loadFileRepresentation(forTypeIdentifier: kind.contentType.identifier) { url, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let url else {
                    continuation.resume(
                        throwing: ShareItemImportError.unableToLoadFileRepresentation(
                            typeIdentifier: kind.contentType.identifier
                        )
                    )
                    return
                }

                continuation.resume(returning: url)
            }
        }
        try Task.checkCancellation()

        let resourceValues = try sourceURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
        guard
            resourceValues.isRegularFile == true,
            let sourceFileSize = resourceValues.fileSize,
            sourceFileSize >= 0
        else {
            throw ShareItemImportError.unableToLoadFileRepresentation(
                typeIdentifier: kind.contentType.identifier
            )
        }

        let sizeInBytes = Int64(sourceFileSize)
        guard sizeInBytes <= budget.maximumFileBytes else {
            throw ShareItemImportError.fileTooLarge(maximumBytes: budget.maximumFileBytes)
        }
        guard sizeInBytes <= budget.maximumTotalFileBytes - totalFileBytes else {
            throw ShareItemImportError.totalFileSizeExceeded(maximumBytes: budget.maximumTotalFileBytes)
        }

        let destinationURL = importedFilesSessionURL
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(sourceURL.pathExtension)

        let copiedSizeInBytes = try await copyImportedFile(
            from: sourceURL,
            to: destinationURL,
            remainingTotalFileBytes: budget.maximumTotalFileBytes - totalFileBytes
        )
        try Task.checkCancellation()

        return (
            item: ShareImportedFileItem(
                kind: kind.kind,
                originalFilename: sourceURL.lastPathComponent,
                contentTypeIdentifier: kind.contentType.identifier,
                fileURL: destinationURL
            ),
            sizeInBytes: copiedSizeInBytes
        )
    }

    private func discardImportedFiles(at fileURLs: [URL]) {
        let sessionPath = importedFilesSessionURL.standardizedFileURL.path

        for fileURL in fileURLs {
            let standardizedURL = fileURL.standardizedFileURL
            guard standardizedURL.deletingLastPathComponent().path == sessionPath else {
                continue
            }
            try? fileManager.removeItem(at: standardizedURL)
        }
    }

    private func supportedFileKind(for provider: NSItemProvider) -> SupportedShareFile? {
        for file in SupportedShareFile.allCases {
            if provider.hasItemConformingToTypeIdentifier(file.contentType.identifier) {
                return file
            }
        }

        return nil
    }
}

private struct SupportedShareFile: Equatable {
    let kind: ShareImportedFileKind
    let contentType: UTType

    static let allCases: [SupportedShareFile] = [
        SupportedShareFile(kind: .image, contentType: .image),
        SupportedShareFile(kind: .video, contentType: .movie),
        SupportedShareFile(kind: .pdf, contentType: .pdf),
        SupportedShareFile(kind: .audio, contentType: .audio)
    ]
}
