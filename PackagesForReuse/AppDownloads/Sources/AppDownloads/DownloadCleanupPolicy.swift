import Foundation

public struct DownloadCleanupPolicy: Equatable, Sendable, Codable {
    public let maximumAge: TimeInterval?
    public let maximumTotalBytes: Int64?

    public init(maximumAge: TimeInterval? = nil, maximumTotalBytes: Int64? = nil) {
        self.maximumAge = maximumAge
        self.maximumTotalBytes = maximumTotalBytes
    }

    public static let disabled = DownloadCleanupPolicy()
}

public actor DownloadCleanupWorker {
    private let manager: FileManager

    public init(manager: FileManager = FileManager()) {
        self.manager = manager
    }

    public func cleanup(directory: DownloadDirectory, policy: DownloadCleanupPolicy, now: Date = Date()) throws -> Int {
        guard policy != .disabled else { return 0 }
        do {
            let urls = try manager.contentsOfDirectory(
                at: directory.url,
                includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey, .isRegularFileKey]
            )
            let candidates = try urls.compactMap { url -> CleanupCandidate? in
                let values = try url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey, .isRegularFileKey])
                guard values.isRegularFile == true else { return nil }
                return CleanupCandidate(url: url, modifiedAt: values.contentModificationDate, byteCount: Int64(values.fileSize ?? 0))
            }
            var removed = 0
            if let maximumAge = policy.maximumAge {
                for candidate in candidates {
                    if let modifiedAt = candidate.modifiedAt, now.timeIntervalSince(modifiedAt) > maximumAge {
                        try manager.removeItem(at: candidate.url)
                        removed += 1
                    }
                }
            }
            if let maximumTotalBytes = policy.maximumTotalBytes {
                let remaining = try manager.contentsOfDirectory(
                    at: directory.url,
                    includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey, .isRegularFileKey]
                ).compactMap { url -> CleanupCandidate? in
                    let values = try url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey, .isRegularFileKey])
                    guard values.isRegularFile == true else { return nil }
                    return CleanupCandidate(url: url, modifiedAt: values.contentModificationDate, byteCount: Int64(values.fileSize ?? 0))
                }.sorted { left, right in
                    (left.modifiedAt ?? .distantPast) < (right.modifiedAt ?? .distantPast)
                }
                var total = remaining.reduce(Int64(0)) { $0 + $1.byteCount }
                for candidate in remaining where total > maximumTotalBytes {
                    try manager.removeItem(at: candidate.url)
                    total -= candidate.byteCount
                    removed += 1
                }
            }
            return removed
        } catch {
            throw DownloadFailure(.cleanupFailed, operation: .cleanup)
        }
    }
}

private struct CleanupCandidate {
    let url: URL
    let modifiedAt: Date?
    let byteCount: Int64
}
