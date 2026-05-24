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
    private let importedFilesRootURL: URL

    public init(
        groupIdentifier: String? = nil,
        fileManager: FileManager = .default
    ) throws {
        self.fileManager = fileManager

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

        self.importedFilesRootURL = rootURL
            .appendingPathComponent(Self.importedFilesDirectoryName, isDirectory: true)

        try fileManager.createDirectory(
            at: importedFilesRootURL,
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

        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                items.append(.text(try await loadTextItem(from: provider)))
                continue
            }

            guard let supportedFile = supportedFileKind(for: provider) else {
                continue
            }

            items.append(.file(try await loadFileItem(from: provider, kind: supportedFile)))
        }

        if items.isEmpty {
            throw ShareItemImportError.unsupportedProvider
        }

        return items
    }

    private static func copyImportedFile(from sourceURL: URL, to destinationURL: URL) async throws {
        try await Task.detached(priority: .utility) {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        }.value
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
        kind: SupportedShareFile
    ) async throws -> ShareImportedFileItem {
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

        let destinationURL = importedFilesRootURL
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(sourceURL.pathExtension)

        try await Self.copyImportedFile(from: sourceURL, to: destinationURL)

        return ShareImportedFileItem(
            kind: kind.kind,
            originalFilename: sourceURL.lastPathComponent,
            contentTypeIdentifier: kind.contentType.identifier,
            fileURL: destinationURL
        )
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
