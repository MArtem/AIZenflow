import AVFoundation
import CoreGraphics
import CryptoKit
import Foundation
import ImageIO
import OSLog
import SwiftData
import UniformTypeIdentifiers

/// Bootstraps the app's local SwiftData container.
///
/// Behavior:
/// Returns a value result instead of throwing so the app entry point can render a stable
/// startup failure screen without constructing partial dependencies.
enum PersistenceBootstrap {
    case ready(ModelContainer)
    case failed(referenceID: String)

    @MainActor private static var cachedContainer: ModelContainer?

    private static let logger = Logger(
        subsystem: "com.zenflow.AIFieldbook",
        category: "Persistence"
    )

    @MainActor
    static func load() -> PersistenceBootstrap {
        if let cachedContainer {
            return .ready(cachedContainer)
        }

        let schema = Schema(AIFieldbookSchemaV2.models)
        let configuration = ModelConfiguration("AIFieldbook", schema: schema)

        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: AIFieldbookMigrationPlan.self,
                configurations: [configuration]
            )
            cachedContainer = container
            return .ready(container)
        } catch {
            let referenceID = UUID().uuidString
            let nsError = error as NSError
            logger.error(
                "SwiftData bootstrap failed [\(referenceID, privacy: .public)] domain=\(nsError.domain, privacy: .public) code=\(nsError.code)"
            )
            return .failed(referenceID: referenceID)
        }
    }
}

/// Durable relative reference to an app-owned file.
///
/// Invariant:
/// The path is normalized and must remain relative to the app-managed storage root. Absolute
/// paths and parent-directory escapes are rejected so picker/provider URLs never become
/// durable product state.
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

/// Validated metadata returned after a file has been copied into app-owned storage.
///
/// The value is safe to persist because it contains a `DurableFileReference`, not the original
/// temporary document-picker URL.
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

/// One durable file move recorded inside a staged deletion transaction.
struct StagedDeletion: Codable, Sendable {
    let originalReference: DurableFileReference
    let stagedRelativePath: String
}

/// Handle for one file-deletion transaction spanning app-owned storage and SwiftData.
///
/// The batch manifest is written before files move. If the process terminates before the
/// database mutation finishes, startup reconciliation uses current SwiftData references to
/// restore or finalize every recorded move without guessing from temporary-file age.
struct StagedDeletionBatch: Sendable {
    let batchRelativePath: String?
    let entries: [StagedDeletion]

    static let empty = StagedDeletionBatch(batchRelativePath: nil, entries: [])
}

/// Policy for destructive flows when a SwiftData record points at an already-missing file.
enum MissingFileDeletionPolicy: Sendable {
    case fail
    case ignoreMissing
}

/// User-selectable import category and its validation policy.
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

/// User-presentable failures produced by app-managed file validation and storage.
enum AppFileStoreError: LocalizedError {
    case invalidRelativePath
    case invalidFileExtension
    case notRegularFile
    case unsupportedType
    case fileTooLarge(maximumMegabytes: Int)
    case corruptFile
    case imageDimensionsTooLarge
    case tooManyImageFrames
    case tooManyPDFPages
    case unsupportedTextEncoding
    case audioTooLong
    case audioNotPlayable
    case missingFile
    case fileIntegrityMismatch
    case deletionRecoveryConflict
    case invalidDeletionManifest

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
        case .tooManyImageFrames:
            String(localized: "The image contains too many frames.")
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
        case .fileIntegrityMismatch:
            String(localized: "The local file failed its integrity check.")
        case .deletionRecoveryConflict:
            String(localized: "Local file cleanup needs recovery before it can continue.")
        case .invalidDeletionManifest:
            String(localized: "Local file recovery information is invalid.")
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
    private let logger = Logger(subsystem: "com.zenflow.AIFieldbook", category: "FileStorage")
    private let rootURL: URL
    private let contentURL: URL
    private let stagingURL: URL
    private let deletionStagingURL: URL
    private let exportsURL: URL

    private static let deletionManifestFilename = "deletion-manifest.json"

    init(
        fileManager: FileManager = .default,
        rootURL: URL = URL.applicationSupportDirectory
            .appending(path: "AIFieldbook", directoryHint: .isDirectory)
    ) {
        self.fileManager = fileManager
        self.rootURL = rootURL
        self.contentURL = rootURL.appending(path: "Content", directoryHint: .isDirectory)
        self.stagingURL = rootURL.appending(path: "Staging", directoryHint: .isDirectory)
        self.deletionStagingURL = stagingURL.appending(path: "Deletion", directoryHint: .isDirectory)
        self.exportsURL = rootURL.appending(path: "Exports", directoryHint: .isDirectory)
    }

    func prepareRecordingDraft() throws -> URL {
        try prepareDirectories()
        let url = stagingURL.appending(path: "recording-\(UUID().uuidString).m4a")
        guard fileManager.createFile(atPath: url.path, contents: nil) else {
            throw CocoaError(.fileWriteUnknown)
        }
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
        let storedFile = try copyDurably(
            from: sourceURL,
            kind: kind,
            contentType: contentType
        )

        return ImportedFileMetadata(
            reference: storedFile.reference,
            originalFilename: sanitizedDisplayFilename(sourceURL.lastPathComponent),
            contentType: contentType.identifier,
            byteCount: storedFile.byteCount,
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
        try applyProtectionAndBackupPolicy(to: url)
        if let expectedDigest = embeddedIntegrityDigest(in: url),
           try sha256Digest(of: url) != expectedDigest {
            logger.error("App-owned file integrity verification failed")
            throw AppFileStoreError.fileIntegrityMismatch
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
    ) throws -> StagedDeletionBatch {
        guard !references.isEmpty else { return .empty }
        try prepareDirectories()

        let batchRelativePath = "Staging/Deletion/\(UUID().uuidString)"
        var seenReferences = Set<DurableFileReference>()
        var entries: [StagedDeletion] = []
        for reference in references where seenReferences.insert(reference).inserted {
            let sourceURL: URL
            do {
                sourceURL = try resolvedURL(for: reference)
            } catch AppFileStoreError.missingFile where missingFilePolicy == .ignoreMissing {
                continue
            }
            entries.append(
                StagedDeletion(
                    originalReference: reference,
                    stagedRelativePath: "\(batchRelativePath)/\(entries.count)-\(sourceURL.lastPathComponent)"
                )
            )
        }
        guard !entries.isEmpty else { return .empty }

        let batch = StagedDeletionBatch(batchRelativePath: batchRelativePath, entries: entries)
        let batchURL = try validatedBatchURL(for: batch)
        try createManagedDirectory(batchURL)
        try writeDeletionManifest(for: batch, at: batchURL)

        do {
            for entry in entries {
                let sourceURL = rootURL.appending(path: entry.originalReference.relativePath)
                let destinationURL = rootURL.appending(path: entry.stagedRelativePath)
                try fileManager.moveItem(at: sourceURL, to: destinationURL)
                try applyProtectionAndBackupPolicy(to: destinationURL)
            }
            return batch
        } catch {
            let stagingError = error
            do {
                try rollbackDeletion(batch)
            } catch {
                logger.error("Staged deletion rollback requires relaunch recovery")
                throw AppFileStoreError.deletionRecoveryConflict
            }
            throw stagingError
        }
    }

    /// Restores all files recorded by a prepared deletion and removes its durable manifest.
    ///
    /// Failure behavior:
    /// A conflicting original file is never overwritten. The manifest and staged content are
    /// preserved so startup reconciliation or a later support flow can recover them safely.
    func rollbackDeletion(_ batch: StagedDeletionBatch) throws {
        guard !batch.entries.isEmpty else { return }
        let batchURL = try validatedBatchURL(for: batch)
        for entry in batch.entries.reversed() {
            let stagedURL = rootURL.appending(path: entry.stagedRelativePath)
            let originalURL = rootURL.appending(path: entry.originalReference.relativePath)
            guard fileManager.fileExists(atPath: stagedURL.path) else { continue }
            guard !fileManager.fileExists(atPath: originalURL.path) else {
                throw AppFileStoreError.deletionRecoveryConflict
            }
            try fileManager.createDirectory(
                at: originalURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try fileManager.moveItem(at: stagedURL, to: originalURL)
            try applyProtectionAndBackupPolicy(to: originalURL)
        }
        if fileManager.fileExists(atPath: batchURL.path) {
            try fileManager.removeItem(at: batchURL)
        }
    }

    /// Finalizes a deletion only after its SwiftData mutation has committed successfully.
    func commitDeletion(_ batch: StagedDeletionBatch) throws {
        guard !batch.entries.isEmpty else { return }
        let batchURL = try validatedBatchURL(for: batch)
        if fileManager.fileExists(atPath: batchURL.path) {
            try fileManager.removeItem(at: batchURL)
        }
    }

    /// Reconciles interrupted deletions and removes only regenerable, non-transaction staging.
    ///
    /// SwiftData references are authoritative: referenced files are restored, while files from
    /// committed record deletions are finalized. Invalid or conflicting batches are retained and
    /// surfaced as errors instead of being destroyed by a blanket startup cleanup.
    func recoverAbandonedStaging(activeReferences: [DurableFileReference]) throws {
        try prepareDirectories()
        let activeReferences = Set(activeReferences)
        if fileManager.fileExists(atPath: deletionStagingURL.path) {
            let batchURLs = try fileManager.contentsOfDirectory(
                at: deletionStagingURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            for batchURL in batchURLs {
                do {
                    try reconcileDeletionBatch(at: batchURL, activeReferences: activeReferences)
                } catch {
                    let nsError = error as NSError
                    logger.error(
                        "Deletion recovery stopped domain=\(nsError.domain, privacy: .public) code=\(nsError.code)"
                    )
                    throw error
                }
            }
        }
        try cleanupTransientStaging()
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
        try Task.checkCancellation()
        cleanupExports()
        try createManagedDirectory(exportsURL)
        let exportURL = exportsURL.appending(path: "AIFieldbook-Export-\(UUID().uuidString)", directoryHint: .isDirectory)
        try createManagedDirectory(exportURL)
        try manifest.write(to: exportURL.appending(path: "manifest.json"), options: .atomic)
        try applyProtectionAndBackupPolicy(to: exportURL.appending(path: "manifest.json"))
        if fileManager.fileExists(atPath: contentURL.path) {
            try Task.checkCancellation()
            let exportedContentURL = exportURL.appending(path: "Content", directoryHint: .isDirectory)
            try fileManager.copyItem(at: contentURL, to: exportedContentURL)
            try applyProtectionAndBackupPolicy(to: exportedContentURL)
        }
        try Task.checkCancellation()
        return exportURL
    }

    func cleanupExports() {
        try? fileManager.removeItem(at: exportsURL)
    }

    private func copyDurably(
        from sourceURL: URL,
        kind: ImportKind,
        contentType: UTType
    ) throws -> StoredFile {
        try prepareDirectories()

        let normalizedExtension = contentType.preferredFilenameExtension?.lowercased() ?? ""
        guard !normalizedExtension.isEmpty,
              normalizedExtension.count <= 12,
              normalizedExtension.unicodeScalars.allSatisfy(CharacterSet.alphanumerics.contains) else {
            throw AppFileStoreError.invalidFileExtension
        }

        let identifier = UUID().uuidString
        let stagedURL = stagingURL.appending(path: "\(identifier).\(normalizedExtension)")
        var destinationURL: URL?

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
                [.protectionKey: FileProtectionType.complete],
                ofItemAtPath: stagedURL.path
            )
            try applyProtectionAndBackupPolicy(to: stagedURL)
            let digest = try sha256Digest(of: stagedURL)
            let filename = "\(identifier)-\(digest).\(normalizedExtension)"
            let finalURL = contentURL.appending(path: filename)
            destinationURL = finalURL
            try fileManager.moveItem(at: stagedURL, to: finalURL)
            try applyProtectionAndBackupPolicy(to: finalURL)
            let values = try finalURL.resourceValues(forKeys: [.fileSizeKey])
            return StoredFile(
                reference: try DurableFileReference(relativePath: "Content/\(filename)"),
                byteCount: Int64(values.fileSize ?? 0)
            )
        } catch {
            try? fileManager.removeItem(at: stagedURL)
            if let destinationURL {
                try? fileManager.removeItem(at: destinationURL)
            }
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
            guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil) else {
                throw AppFileStoreError.corruptFile
            }
            let frameCount = CGImageSourceGetCount(source)
            guard frameCount > 0 else {
                throw AppFileStoreError.corruptFile
            }
            guard frameCount <= 100 else {
                throw AppFileStoreError.tooManyImageFrames
            }
            guard
                  let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
                  let width = properties[kCGImagePropertyPixelWidth] as? Int,
                  let height = properties[kCGImagePropertyPixelHeight] as? Int else {
                throw AppFileStoreError.corruptFile
            }
            for frameIndex in 0..<frameCount {
                guard let frameProperties = CGImageSourceCopyPropertiesAtIndex(
                    source,
                    frameIndex,
                    nil
                ) as? [CFString: Any],
                let frameWidth = frameProperties[kCGImagePropertyPixelWidth] as? Int,
                let frameHeight = frameProperties[kCGImagePropertyPixelHeight] as? Int,
                frameWidth > 0,
                frameHeight > 0,
                frameWidth <= 20_000,
                frameHeight <= 20_000,
                Int64(frameWidth) * Int64(frameHeight) <= 100_000_000 else {
                    throw AppFileStoreError.imageDimensionsTooLarge
                }
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
        try createManagedDirectory(deletionStagingURL)
    }

    private func createManagedDirectory(_ url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        try applyProtectionAndBackupPolicy(to: url)
    }

    private func applyProtectionAndBackupPolicy(to url: URL) throws {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.setAttributes(
                [.protectionKey: FileProtectionType.complete],
                ofItemAtPath: url.path
            )
        }
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        var mutableURL = url
        try mutableURL.setResourceValues(resourceValues)
    }

    private func writeDeletionManifest(for batch: StagedDeletionBatch, at batchURL: URL) throws {
        let manifest = DeletionManifest(version: 1, entries: batch.entries)
        let data = try JSONEncoder().encode(manifest)
        let manifestURL = batchURL.appending(path: Self.deletionManifestFilename)
        try data.write(to: manifestURL, options: .atomic)
        try applyProtectionAndBackupPolicy(to: manifestURL)
    }

    private func validatedBatchURL(for batch: StagedDeletionBatch) throws -> URL {
        guard let relativePath = batch.batchRelativePath else {
            throw AppFileStoreError.invalidDeletionManifest
        }
        let validated = try DurableFileReference(relativePath: relativePath)
        let batchURL = rootURL.appending(path: validated.relativePath, directoryHint: .isDirectory)
        guard batchURL.deletingLastPathComponent().standardizedFileURL == deletionStagingURL.standardizedFileURL else {
            throw AppFileStoreError.invalidDeletionManifest
        }
        return batchURL
    }

    private func reconcileDeletionBatch(
        at batchURL: URL,
        activeReferences: Set<DurableFileReference>
    ) throws {
        let values = try batchURL.resourceValues(forKeys: [.isDirectoryKey])
        guard values.isDirectory == true else {
            throw AppFileStoreError.invalidDeletionManifest
        }
        let manifestURL = batchURL.appending(path: Self.deletionManifestFilename)
        guard let data = try? readDeletionManifestData(at: manifestURL),
              let manifest = try? JSONDecoder().decode(DeletionManifest.self, from: data),
              manifest.version == 1 else {
            throw AppFileStoreError.invalidDeletionManifest
        }
        let batchRelativePath = "Staging/Deletion/\(batchURL.lastPathComponent)"
        let batch = StagedDeletionBatch(batchRelativePath: batchRelativePath, entries: manifest.entries)
        _ = try validatedBatchURL(for: batch)

        for entry in batch.entries {
            let originalReference = try DurableFileReference(
                relativePath: entry.originalReference.relativePath
            )
            let validatedStagedReference = try DurableFileReference(relativePath: entry.stagedRelativePath)
            guard validatedStagedReference.relativePath.hasPrefix("\(batchRelativePath)/") else {
                throw AppFileStoreError.invalidDeletionManifest
            }
            let originalURL = rootURL.appending(path: originalReference.relativePath)
            let stagedURL = rootURL.appending(path: validatedStagedReference.relativePath)
            let originalExists = fileManager.fileExists(atPath: originalURL.path)
            let stagedExists = fileManager.fileExists(atPath: stagedURL.path)

            if activeReferences.contains(originalReference) {
                if !originalExists, stagedExists {
                    try fileManager.createDirectory(
                        at: originalURL.deletingLastPathComponent(),
                        withIntermediateDirectories: true
                    )
                    try fileManager.moveItem(at: stagedURL, to: originalURL)
                    try applyProtectionAndBackupPolicy(to: originalURL)
                } else if originalExists, stagedExists {
                    throw AppFileStoreError.deletionRecoveryConflict
                } else if !originalExists, !stagedExists {
                    throw AppFileStoreError.deletionRecoveryConflict
                }
            } else if originalExists {
                throw AppFileStoreError.deletionRecoveryConflict
            }
        }

        try fileManager.removeItem(at: batchURL)
    }

    private func cleanupTransientStaging() throws {
        let children = try fileManager.contentsOfDirectory(
            at: stagingURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        for child in children where child.standardizedFileURL != deletionStagingURL.standardizedFileURL {
            try fileManager.removeItem(at: child)
        }
    }

    private func readDeletionManifestData(at url: URL) throws -> Data {
        let maximumManifestBytes = 1_048_576
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        guard values.isRegularFile == true,
              let fileSize = values.fileSize,
              fileSize > 0,
              fileSize <= maximumManifestBytes else {
            throw AppFileStoreError.invalidDeletionManifest
        }
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        guard let data = try handle.read(upToCount: maximumManifestBytes + 1),
              data.count == fileSize else {
            throw AppFileStoreError.invalidDeletionManifest
        }
        return data
    }

    private func sha256Digest(of url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while let chunk = try handle.read(upToCount: 1_048_576), !chunk.isEmpty {
            hasher.update(data: chunk)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func embeddedIntegrityDigest(in url: URL) -> String? {
        let stem = url.deletingPathExtension().lastPathComponent
        guard let separator = stem.lastIndex(of: "-") else { return nil }
        let digest = String(stem[stem.index(after: separator)...])
        guard digest.count == 64,
              digest.unicodeScalars.allSatisfy({
                  CharacterSet(charactersIn: "0123456789abcdef").contains($0)
              })
        else { return nil }
        return digest
    }
}

private struct DeletionManifest: Codable {
    let version: Int
    let entries: [StagedDeletion]
}

private struct ImportValidationMetadata {
    var durationSeconds: Double?
    var pixelWidth: Int?
    var pixelHeight: Int?
    var pageCount: Int?
}

private struct StoredFile {
    let reference: DurableFileReference
    let byteCount: Int64
}
