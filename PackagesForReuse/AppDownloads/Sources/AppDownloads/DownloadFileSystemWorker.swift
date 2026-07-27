import Foundation

public actor DownloadFileSystemWorker {
    private let manager: FileManager

    public init(manager: FileManager = FileManager()) {
        self.manager = manager
    }

    public func writeAtomically(data: Data, to destination: DownloadDestination) throws -> DownloadReceipt {
        do {
            try manager.createDirectory(at: destination.directory.url, withIntermediateDirectories: true)
            let finalURL = try resolvedDestinationURL(for: destination)
            let workURL = destination.directory.url.appendingPathComponent(".appdownloads-work-\(UUID().uuidString)", isDirectory: false)
            try data.write(to: workURL)
            defer {
                if manager.fileExists(atPath: workURL.path) {
                    try? manager.removeItem(at: workURL)
                }
            }
            if manager.fileExists(atPath: finalURL.path) {
                _ = try manager.replaceItemAt(finalURL, withItemAt: workURL, backupItemName: nil, options: [])
            } else {
                try manager.moveItem(at: workURL, to: finalURL)
            }
            return DownloadReceipt(
                id: .generated(),
                fileName: try SafeDownloadFileName(finalURL.lastPathComponent),
                directoryRole: destination.directory.role,
                byteCount: Int64(data.count),
                completedAt: Date()
            )
        } catch let failure as DownloadFailure {
            throw failure
        } catch {
            throw DownloadFailure(.writeFailed, operation: .fileSystem)
        }
    }

    public func removeFile(named fileName: SafeDownloadFileName, in directory: DownloadDirectory) throws {
        let targetURL = directory.url.appendingPathComponent(fileName.value, isDirectory: false)
        do {
            if manager.fileExists(atPath: targetURL.path) {
                try manager.removeItem(at: targetURL)
            }
        } catch {
            throw DownloadFailure(.cleanupFailed, operation: .cleanup)
        }
    }

    public func metadata(for fileName: SafeDownloadFileName, in directory: DownloadDirectory) throws -> DownloadedFileMetadata {
        let targetURL = directory.url.appendingPathComponent(fileName.value, isDirectory: false)
        do {
            let attributes = try manager.attributesOfItem(atPath: targetURL.path)
            let byteCount = (attributes[.size] as? NSNumber)?.int64Value ?? 0
            let modifiedAt = attributes[.modificationDate] as? Date
            return DownloadedFileMetadata(fileName: fileName, directoryRole: directory.role, byteCount: byteCount, modifiedAt: modifiedAt)
        } catch {
            throw DownloadFailure(.fileSystemUnavailable, operation: .fileSystem)
        }
    }

    private func resolvedDestinationURL(for destination: DownloadDestination) throws -> URL {
        let baseURL = destination.fileURL
        switch destination.replacementPolicy {
        case .replaceExisting:
            return baseURL
        case .failIfExists:
            if manager.fileExists(atPath: baseURL.path) {
                throw DownloadFailure(.invalidDestination, operation: .fileSystem)
            }
            return baseURL
        case .makeUniqueName:
            if manager.fileExists(atPath: baseURL.path) == false {
                return baseURL
            }
            let baseName = baseURL.deletingPathExtension().lastPathComponent
            let fileExtension = baseURL.pathExtension
            for index in 1...999 {
                let candidateName: String
                if fileExtension.isEmpty {
                    candidateName = "\(baseName)-\(index)"
                } else {
                    candidateName = "\(baseName)-\(index).\(fileExtension)"
                }
                let candidate = destination.directory.url.appendingPathComponent(candidateName, isDirectory: false)
                if manager.fileExists(atPath: candidate.path) == false {
                    return candidate
                }
            }
            throw DownloadFailure(.invalidDestination, operation: .fileSystem)
        }
    }
}

public struct DownloadedFileMetadata: Equatable, Sendable, Codable, CustomStringConvertible {
    public let fileName: SafeDownloadFileName
    public let directoryRole: DownloadDirectoryRole
    public let byteCount: Int64
    public let modifiedAt: Date?

    public init(fileName: SafeDownloadFileName, directoryRole: DownloadDirectoryRole, byteCount: Int64, modifiedAt: Date?) {
        self.fileName = fileName
        self.directoryRole = directoryRole
        self.byteCount = max(0, byteCount)
        self.modifiedAt = modifiedAt
    }

    public var description: String {
        "DownloadedFileMetadata(fileName: redacted, role: \(directoryRole), bytes: \(byteCount))"
    }
}
