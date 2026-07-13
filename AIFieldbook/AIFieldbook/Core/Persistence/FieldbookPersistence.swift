import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import SwiftData
import UniformTypeIdentifiers

enum PersistenceBootstrap {
    case ready(ModelContainer)
    case failed

    @MainActor
    static func load() -> PersistenceBootstrap {
        let schema = Schema(AIFieldbookSchemaV2.models)
        let configuration = ModelConfiguration("AIFieldbook", schema: schema)

        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: AIFieldbookMigrationPlan.self,
                configurations: [configuration]
            )
            return .ready(container)
        } catch {
            return .failed
        }
    }
}

struct DurableFileReference: Codable, Hashable, Sendable {
    let relativePath: String

    init(relativePath: String) throws {
        let path = NSString(string: relativePath).standardizingPath
        guard !path.hasPrefix("/"), path != "..", !path.hasPrefix("../") else {
            throw AppFileStoreError.invalidRelativePath
        }
        self.relativePath = path
    }
}

struct ImportedFileMetadata: Sendable {
    let reference: DurableFileReference
    let originalFilename: String
    let contentType: String
    let byteCount: Int64
    let durationSeconds: Double?
    let pixelWidth: Int?
    let pixelHeight: Int?
    let pageCount: Int?
}

struct StagedDeletion: Sendable {
    let originalReference: DurableFileReference
    let stagedRelativePath: String
}

enum MissingFileDeletionPolicy: Sendable {
    case fail
    case ignoreMissing
}

enum ImportKind: String, CaseIterable, Hashable, Identifiable, Sendable {
    case image
    case pdf
    case plainTextDocument
    case audio

    var id: String { rawValue }

    var knowledgeItemKind: KnowledgeItemKind {
        switch self {
        case .image: .image
        case .pdf: .pdf
        case .plainTextDocument: .plainTextDocument
        case .audio: .audio
        }
    }

    var title: String {
        switch self {
        case .image: String(localized: "Image")
        case .pdf: String(localized: "PDF")
        case .plainTextDocument: String(localized: "Text Document")
        case .audio: String(localized: "Audio")
        }
    }

    var systemImage: String { knowledgeItemKind.systemImage }

    var allowedContentTypes: [UTType] {
        switch self {
        case .image: [.image]
        case .pdf: [.pdf]
        case .plainTextDocument: [.plainText]
        case .audio: [.audio]
        }
    }
}

enum AppFileStoreError: LocalizedError {
    case invalidRelativePath
    case invalidFileExtension
    case notRegularFile
    case unsupportedType
    case fileTooLarge(maximumMegabytes: Int)
    case corruptFile
    case imageDimensionsTooLarge
    case tooManyPDFPages
    case unsupportedTextEncoding
    case audioTooLong
    case audioNotPlayable
    case missingFile

    var errorDescription: String? {
        switch self {
        case .invalidRelativePath, .invalidFileExtension, .notRegularFile:
            String(localized: "The selected file path is invalid.")
        case .unsupportedType:
            String(localized: "The selected file type isn’t supported for this import.")
        case let .fileTooLarge(maximumMegabytes):
            String(localized: "The selected file is larger than the \(maximumMegabytes) MB limit.")
        case .corruptFile:
            String(localized: "The selected file is corrupt or can’t be read.")
        case .imageDimensionsTooLarge:
            String(localized: "The image exceeds the 20,000-pixel dimension limit.")
        case .tooManyPDFPages:
            String(localized: "The PDF exceeds the 500-page limit.")
        case .unsupportedTextEncoding:
            String(localized: "The document must be valid UTF-8 plain text.")
        case .audioTooLong:
            String(localized: "The audio exceeds the four-hour duration limit.")
        case .audioNotPlayable:
            String(localized: "The selected audio file can’t be played.")
        case .missingFile:
            String(localized: "The local file is missing.")
        }
    }
}

/// Actor-isolated owner for app-managed files.
///
/// Responsibilities:
/// - copies imported files into app-owned Application Support storage;
/// - validates imported media before persistence records are created;
/// - stages destructive file deletion so database failures can roll files back;
/// - creates user-initiated local export folders.
///
/// Privacy and backup contract:
/// Iteration 1 is local-only with no approved cloud data path. App-owned content, staging
/// files, and generated exports are marked excluded from system backup. Users can still share
/// an export explicitly through the Settings screen.
actor AppFileStore {
    private let fileManager: FileManager
    private let rootURL: URL
    private let contentURL: URL
    private let stagingURL: URL
    private let exportsURL: URL

    init(
        fileManager: FileManager = .default,
        rootURL: URL = URL.applicationSupportDirectory
            .appending(path: "AIFieldbook", directoryHint: .isDirectory)
    ) {
        self.fileManager = fileManager
        self.rootURL = rootURL
        self.contentURL = rootURL.appending(path: "Content", directoryHint: .isDirectory)
        self.stagingURL = rootURL.appending(path: "Staging", directoryHint: .isDirectory)
        self.exportsURL = rootURL.appending(path: "Exports", directoryHint: .isDirectory)
    }

    func prepareRecordingDraft() throws -> URL {
        try prepareDirectories()
        let url = stagingURL.appending(path: "recording-\(UUID().uuidString).m4a")
        fileManager.createFile(atPath: url.path, contents: nil)
        try applyProtectionAndBackupPolicy(to: url)
        return url
    }

    func discardRecordingDraft(at url: URL) {
        guard url.deletingLastPathComponent().standardizedFileURL == stagingURL.standardizedFileURL else { return }
        try? fileManager.removeItem(at: url)
    }

    func importFile(at sourceURL: URL, kind: ImportKind) async throws -> ImportedFileMetadata {
        let accessedSecurityScope = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessedSecurityScope {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let values = try sourceURL.resourceValues(
            forKeys: [.isRegularFileKey, .fileSizeKey, .contentTypeKey]
        )
        guard values.isRegularFile == true else {
            throw AppFileStoreError.notRegularFile
        }

        let byteCount = Int64(values.fileSize ?? 0)
        let contentType = values.contentType ?? UTType(filenameExtension: sourceURL.pathExtension)
        guard let contentType, kind.allowedContentTypes.contains(where: contentType.conforms(to:)) else {
            throw AppFileStoreError.unsupportedType
        }

        let validation = try await validate(
            sourceURL: sourceURL,
            byteCount: byteCount,
            kind: kind
        )
        let reference = try copyDurably(
            from: sourceURL,
            kind: kind,
            contentType: contentType
        )

        return ImportedFileMetadata(
            reference: reference,
            originalFilename: sanitizedDisplayFilename(sourceURL.lastPathComponent),
            contentType: contentType.identifier,
            byteCount: byteCount,
            durationSeconds: validation.durationSeconds,
            pixelWidth: validation.pixelWidth,
            pixelHeight: validation.pixelHeight,
            pageCount: validation.pageCount
        )
    }

    func resolvedURL(for reference: DurableFileReference) throws -> URL {
        let validated = try DurableFileReference(relativePath: reference.relativePath)
        let url = rootURL.appending(path: validated.relativePath)
        guard fileManager.fileExists(atPath: url.path) else {
            throw AppFileStoreError.missingFile
        }
        return url
    }

    func remove(_ reference: DurableFileReference) throws {
        let url = try resolvedURL(for: reference)
        try fileManager.removeItem(at: url)
    }

    func stageDeletion(
        _ references: [DurableFileReference],
        missingFilePolicy: MissingFileDeletionPolicy = .fail
    ) throws -> [StagedDeletion] {
        guard !references.isEmpty else { return [] }
        try prepareDirectories()

        let batchPath = "Staging/Deletion/\(UUID().uuidString)"
        let batchURL = rootURL.appending(path: batchPath, directoryHint: .isDirectory)
        try createManagedDirectory(batchURL)

        var staged: [StagedDeletion] = []
        do {
            for reference in references {
                let sourceURL: URL
                do {
                    sourceURL = try resolvedURL(for: reference)
                } catch AppFileStoreError.missingFile where missingFilePolicy == .ignoreMissing {
                    continue
                }
                let destinationRelativePath = "\(batchPath)/\(sourceURL.lastPathComponent)"
                let destinationURL = rootURL.appending(path: destinationRelativePath)
                try fileManager.moveItem(at: sourceURL, to: destinationURL)
                try applyProtectionAndBackupPolicy(to: destinationURL)
                staged.append(
                    StagedDeletion(
                        originalReference: reference,
                        stagedRelativePath: destinationRelativePath
                    )
                )
            }
            return staged
        } catch {
            try? rollbackDeletion(staged)
            try? fileManager.removeItem(at: batchURL)
            throw error
        }
    }

    func rollbackDeletion(_ staged: [StagedDeletion]) throws {
        for entry in staged.reversed() {
            let stagedURL = rootURL.appending(path: entry.stagedRelativePath)
            let originalURL = rootURL.appending(path: entry.originalReference.relativePath)
            guard fileManager.fileExists(atPath: stagedURL.path) else { continue }
            try fileManager.moveItem(at: stagedURL, to: originalURL)
        }
        try removeEmptyDeletionParents(from: staged)
    }

    func commitDeletion(_ staged: [StagedDeletion]) {
        for entry in staged {
            let stagedURL = rootURL.appending(path: entry.stagedRelativePath)
            if fileManager.fileExists(atPath: stagedURL.path) {
                try? fileManager.removeItem(at: stagedURL)
            }
        }
        try? removeEmptyDeletionParents(from: staged)
    }

    func cleanupAbandonedStaging() {
        if fileManager.fileExists(atPath: stagingURL.path) {
            try? fileManager.removeItem(at: stagingURL)
        }
        try? createManagedDirectory(stagingURL)
    }

    func storageByteCount() -> Int64 {
        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey]
        ) else { return 0 }
        var total: Int64 = 0
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey]),
                  values.isRegularFile == true else { continue }
            total += Int64(values.fileSize ?? 0)
        }
        return total
    }

    /// Creates one temporary user-shareable export and removes older generated exports.
    ///
    /// Side effects:
    /// Export folders are app-owned, excluded from backup, and intentionally regenerated on
    /// demand instead of becoming a permanent second copy of private local content.
    func createExport(manifest: Data) throws -> URL {
        cleanupExports()
        try createManagedDirectory(exportsURL)
        let exportURL = exportsURL.appending(path: "AIFieldbook-Export-\(UUID().uuidString)", directoryHint: .isDirectory)
        try createManagedDirectory(exportURL)
        try manifest.write(to: exportURL.appending(path: "manifest.json"), options: .atomic)
        try applyProtectionAndBackupPolicy(to: exportURL.appending(path: "manifest.json"))
        if fileManager.fileExists(atPath: contentURL.path) {
            let exportedContentURL = exportURL.appending(path: "Content", directoryHint: .isDirectory)
            try fileManager.copyItem(at: contentURL, to: exportedContentURL)
            try applyProtectionAndBackupPolicy(to: exportedContentURL)
        }
        return exportURL
    }

    func cleanupExports() {
        try? fileManager.removeItem(at: exportsURL)
    }

    private func copyDurably(
        from sourceURL: URL,
        kind: ImportKind,
        contentType: UTType
    ) throws -> DurableFileReference {
        try prepareDirectories()

        let normalizedExtension = sourceURL.pathExtension.lowercased()
        guard !normalizedExtension.isEmpty,
              normalizedExtension.unicodeScalars.allSatisfy(CharacterSet.alphanumerics.contains) else {
            throw AppFileStoreError.invalidFileExtension
        }

        let filename = "\(UUID().uuidString).\(normalizedExtension)"
        let stagedURL = stagingURL.appending(path: filename)
        let destinationURL = contentURL.appending(path: filename)

        do {
            if kind == .image {
                try copyImageWithoutMetadata(
                    from: sourceURL,
                    to: stagedURL,
                    contentType: contentType
                )
            } else {
                try fileManager.copyItem(at: sourceURL, to: stagedURL)
            }
            try fileManager.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: stagedURL.path
            )
            try applyProtectionAndBackupPolicy(to: stagedURL)
            try fileManager.moveItem(at: stagedURL, to: destinationURL)
            return try DurableFileReference(relativePath: "Content/\(filename)")
        } catch {
            try? fileManager.removeItem(at: stagedURL)
            try? fileManager.removeItem(at: destinationURL)
            throw error
        }
    }

    private func copyImageWithoutMetadata(
        from sourceURL: URL,
        to destinationURL: URL,
        contentType: UTType
    ) throws {
        guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
              let destination = CGImageDestinationCreateWithURL(
                destinationURL as CFURL,
                contentType.identifier as CFString,
                CGImageSourceGetCount(source),
                nil
              ) else {
            throw AppFileStoreError.corruptFile
        }

        let emptyMetadata = CGImageMetadataCreateMutable()
        let options = [
            kCGImageDestinationMetadata: emptyMetadata,
            kCGImageDestinationMergeMetadata: false
        ] as CFDictionary
        var copyError: Unmanaged<CFError>?
        guard CGImageDestinationCopyImageSource(destination, source, options, &copyError) else {
            if let copyError {
                throw copyError.takeRetainedValue()
            }
            throw AppFileStoreError.corruptFile
        }
    }

    private func validate(
        sourceURL: URL,
        byteCount: Int64,
        kind: ImportKind
    ) async throws -> ImportValidationMetadata {
        switch kind {
        case .image:
            try enforceFileLimit(byteCount, maximumMegabytes: 25)
            guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
                  CGImageSourceGetCount(source) > 0,
                  let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
                  let width = properties[kCGImagePropertyPixelWidth] as? Int,
                  let height = properties[kCGImagePropertyPixelHeight] as? Int else {
                throw AppFileStoreError.corruptFile
            }
            guard width > 0, height > 0, width <= 20_000, height <= 20_000 else {
                throw AppFileStoreError.imageDimensionsTooLarge
            }
            return ImportValidationMetadata(pixelWidth: width, pixelHeight: height)

        case .pdf:
            try enforceFileLimit(byteCount, maximumMegabytes: 50)
            guard let document = CGPDFDocument(sourceURL as CFURL), document.numberOfPages > 0 else {
                throw AppFileStoreError.corruptFile
            }
            guard document.numberOfPages <= 500 else {
                throw AppFileStoreError.tooManyPDFPages
            }
            return ImportValidationMetadata(pageCount: document.numberOfPages)

        case .plainTextDocument:
            try enforceFileLimit(byteCount, maximumMegabytes: 10)
            guard (try? String(contentsOf: sourceURL, encoding: .utf8)) != nil else {
                throw AppFileStoreError.unsupportedTextEncoding
            }
            return ImportValidationMetadata()

        case .audio:
            try enforceFileLimit(byteCount, maximumMegabytes: 100)
            let asset = AVURLAsset(url: sourceURL)
            let isPlayable = try await asset.load(.isPlayable)
            let duration = try await asset.load(.duration)
            let seconds = duration.seconds
            guard isPlayable, seconds.isFinite, seconds > 0 else {
                throw AppFileStoreError.audioNotPlayable
            }
            guard seconds <= 14_400 else {
                throw AppFileStoreError.audioTooLong
            }
            return ImportValidationMetadata(durationSeconds: seconds)
        }
    }

    private func enforceFileLimit(_ byteCount: Int64, maximumMegabytes: Int) throws {
        let maximumBytes = Int64(maximumMegabytes) * 1_024 * 1_024
        guard byteCount > 0, byteCount <= maximumBytes else {
            throw AppFileStoreError.fileTooLarge(maximumMegabytes: maximumMegabytes)
        }
    }

    private func sanitizedDisplayFilename(_ filename: String) -> String {
        let sanitizedScalars = filename.unicodeScalars.filter {
            !CharacterSet.controlCharacters.contains($0)
        }
        let sanitized = String(String.UnicodeScalarView(sanitizedScalars)).trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return sanitized.isEmpty ? String(localized: "Imported File") : String(sanitized.prefix(240))
    }

    private func prepareDirectories() throws {
        try createManagedDirectory(rootURL)
        try createManagedDirectory(contentURL)
        try createManagedDirectory(stagingURL)
    }

    private func createManagedDirectory(_ url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        try applyProtectionAndBackupPolicy(to: url)
    }

    private func applyProtectionAndBackupPolicy(to url: URL) throws {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: url.path
            )
        }
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        var mutableURL = url
        try mutableURL.setResourceValues(resourceValues)
    }

    private func removeEmptyDeletionParents(from staged: [StagedDeletion]) throws {
        guard let first = staged.first else { return }
        let batchURL = rootURL
            .appending(path: first.stagedRelativePath)
            .deletingLastPathComponent()
        if fileManager.fileExists(atPath: batchURL.path) {
            try fileManager.removeItem(at: batchURL)
        }
    }
}

private struct ImportValidationMetadata {
    var durationSeconds: Double?
    var pixelWidth: Int?
    var pixelHeight: Int?
    var pageCount: Int?
}
