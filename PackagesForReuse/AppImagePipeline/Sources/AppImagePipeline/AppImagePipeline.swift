import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct ImageCacheKey: Hashable, Codable, Sendable, CustomStringConvertible {
    private let rawValue: String

    public init(_ rawValue: String) throws {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ImagePipelineError.invalidCacheKey
        }
        guard trimmed.rangeOfCharacter(from: .controlCharacters) == nil else {
            throw ImagePipelineError.invalidCacheKey
        }
        self.rawValue = trimmed
    }

    public static func url(_ url: URL) throws -> ImageCacheKey {
        guard let scheme = url.scheme?.lowercased(), scheme == "https" || scheme == "http" else {
            throw ImagePipelineError.unsupportedURLScheme
        }
        return try ImageCacheKey("url:\(url.absoluteString)")
    }

    public var description: String {
        "ImageCacheKey(<redacted>)"
    }

    var storageFileName: String {
        "image-\(Self.fnv1a64(rawValue)).bin"
    }

    private static func fnv1a64(_ value: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        let prime: UInt64 = 0x100000001b3
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= prime
        }
        return String(hash, radix: 16)
    }
}

public enum ImageSource: Sendable, Equatable {
    case url(URL)
    case data(Data)
}

public enum ImageCachePolicy: String, Codable, Sendable {
    case useCacheElseLoad
    case reloadIgnoringCache
    case returnCacheDataDontLoad
}

public struct ImageRequest: Sendable, Equatable, CustomStringConvertible {
    public let source: ImageSource
    public let cacheKey: ImageCacheKey?
    public let cachePolicy: ImageCachePolicy
    public let preferredContentTypes: Set<String>

    public init(
        source: ImageSource,
        cacheKey: ImageCacheKey? = nil,
        cachePolicy: ImageCachePolicy = .useCacheElseLoad,
        preferredContentTypes: Set<String> = []
    ) {
        self.source = source
        self.cacheKey = cacheKey
        self.cachePolicy = cachePolicy
        self.preferredContentTypes = preferredContentTypes
    }

    public static func url(
        _ url: URL,
        cacheKey: ImageCacheKey? = nil,
        cachePolicy: ImageCachePolicy = .useCacheElseLoad,
        preferredContentTypes: Set<String> = []
    ) throws -> ImageRequest {
        let resolvedKey = try cacheKey ?? ImageCacheKey.url(url)
        return ImageRequest(
            source: .url(url),
            cacheKey: resolvedKey,
            cachePolicy: cachePolicy,
            preferredContentTypes: preferredContentTypes
        )
    }

    public static func data(
        _ data: Data,
        cacheKey: ImageCacheKey? = nil,
        cachePolicy: ImageCachePolicy = .useCacheElseLoad
    ) -> ImageRequest {
        ImageRequest(source: .data(data), cacheKey: cacheKey, cachePolicy: cachePolicy)
    }

    public var description: String {
        "ImageRequest(source: <redacted>, hasCacheKey: \(cacheKey != nil), policy: \(cachePolicy.rawValue))"
    }
}

public enum ImageResponseSource: String, Codable, Sendable {
    case providedData
    case memoryCache
    case diskCache
    case remoteFetch
}

public struct ImageResponse: Sendable, Equatable {
    public let data: Data
    public let contentType: String?
    public let source: ImageResponseSource
    public let fetchedAt: Date

    public init(data: Data, contentType: String? = nil, source: ImageResponseSource, fetchedAt: Date = Date()) {
        self.data = data
        self.contentType = contentType
        self.source = source
        self.fetchedAt = fetchedAt
    }

    public var byteCount: Int { data.count }
}

public struct ImageFetchResult: Sendable, Equatable {
    public let data: Data
    public let contentType: String?

    public init(data: Data, contentType: String? = nil) {
        self.data = data
        self.contentType = contentType
    }
}

public enum ImagePipelineError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidCacheKey
    case unsupportedURLScheme
    case sourceRequiresRemoteFetcher
    case cacheMiss
    case emptyData
    case httpFailure(statusCode: Int)
    case fetchFailed(code: String)
    case storageFailed(code: String)

    public var description: String {
        switch self {
        case .invalidCacheKey:
            return "ImagePipelineError.invalidCacheKey"
        case .unsupportedURLScheme:
            return "ImagePipelineError.unsupportedURLScheme"
        case .sourceRequiresRemoteFetcher:
            return "ImagePipelineError.sourceRequiresRemoteFetcher"
        case .cacheMiss:
            return "ImagePipelineError.cacheMiss"
        case .emptyData:
            return "ImagePipelineError.emptyData"
        case let .httpFailure(statusCode):
            return "ImagePipelineError.httpFailure(statusCode: \(statusCode))"
        case let .fetchFailed(code):
            return "ImagePipelineError.fetchFailed(code: \(Self.sanitizedDiagnosticCode(code)))"
        case let .storageFailed(code):
            return "ImagePipelineError.storageFailed(code: \(Self.sanitizedDiagnosticCode(code)))"
        }
    }

    private static func sanitizedDiagnosticCode(_ code: String) -> String {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "unknown" }
        let allowedScalars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")
        guard trimmed.unicodeScalars.allSatisfy({ allowedScalars.contains($0) }) else {
            return "redacted"
        }
        return String(trimmed.prefix(64))
    }
}

public protocol ImageDataFetching: Sendable {
    func data(for request: ImageRequest) async throws -> ImageFetchResult
}

public struct URLSessionImageDataFetcher: ImageDataFetching {
    public init() {}

    public func data(for request: ImageRequest) async throws -> ImageFetchResult {
        guard case let .url(url) = request.source else {
            throw ImagePipelineError.sourceRequiresRemoteFetcher
        }
        guard let scheme = url.scheme?.lowercased(), scheme == "https" || scheme == "http" else {
            throw ImagePipelineError.unsupportedURLScheme
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard !data.isEmpty else { throw ImagePipelineError.emptyData }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw ImagePipelineError.httpFailure(statusCode: http.statusCode)
            }
            return ImageFetchResult(data: data, contentType: response.mimeType)
        } catch let error as ImagePipelineError {
            throw error
        } catch {
            throw ImagePipelineError.fetchFailed(code: "remote_fetch_failed")
        }
    }
}

public actor MockImageDataFetcher: ImageDataFetching {
    private var results: [ImageCacheKey: Result<ImageFetchResult, ImagePipelineError>]
    private(set) var requestedKeys: [ImageCacheKey] = []

    public init(results: [ImageCacheKey: Result<ImageFetchResult, ImagePipelineError>] = [:]) {
        self.results = results
    }

    public func setResult(_ result: Result<ImageFetchResult, ImagePipelineError>, for key: ImageCacheKey) {
        results[key] = result
    }

    public func requestCount(for key: ImageCacheKey) -> Int {
        requestedKeys.filter { $0 == key }.count
    }

    public func data(for request: ImageRequest) async throws -> ImageFetchResult {
        guard let key = request.cacheKey else {
            throw ImagePipelineError.invalidCacheKey
        }
        requestedKeys.append(key)
        guard let result = results[key] else {
            throw ImagePipelineError.fetchFailed(code: "mock_result_missing")
        }
        return try result.get()
    }
}

public protocol ImageMemoryCaching: Sendable {
    func response(for key: ImageCacheKey) async -> ImageResponse?
    func store(_ response: ImageResponse, for key: ImageCacheKey) async
    func removeResponse(for key: ImageCacheKey) async
    func removeAll() async
    func diagnostics() async -> ImageCacheDiagnostics
}

public struct ImageCacheDiagnostics: Sendable, Equatable {
    public let entryCount: Int
    public let totalBytes: Int

    public init(entryCount: Int, totalBytes: Int) {
        self.entryCount = entryCount
        self.totalBytes = totalBytes
    }
}

public actor ImageMemoryCache: ImageMemoryCaching {
    private struct Entry: Sendable {
        var response: ImageResponse
        var accessIndex: UInt64
    }

    private let maximumEntryCount: Int
    private let maximumTotalBytes: Int
    private var entries: [ImageCacheKey: Entry] = [:]
    private var accessCounter: UInt64 = 0
    private var totalBytes: Int = 0

    public init(maximumEntryCount: Int = 200, maximumTotalBytes: Int = 30 * 1024 * 1024) {
        self.maximumEntryCount = max(1, maximumEntryCount)
        self.maximumTotalBytes = max(1, maximumTotalBytes)
    }

    public func response(for key: ImageCacheKey) async -> ImageResponse? {
        guard var entry = entries[key] else { return nil }
        accessCounter &+= 1
        entry.accessIndex = accessCounter
        entries[key] = entry
        return ImageResponse(
            data: entry.response.data,
            contentType: entry.response.contentType,
            source: .memoryCache,
            fetchedAt: entry.response.fetchedAt
        )
    }

    public func store(_ response: ImageResponse, for key: ImageCacheKey) async {
        if let existing = entries[key] {
            totalBytes -= existing.response.byteCount
        }
        accessCounter &+= 1
        entries[key] = Entry(response: response, accessIndex: accessCounter)
        totalBytes += response.byteCount
        evictIfNeeded()
    }

    public func removeResponse(for key: ImageCacheKey) async {
        if let existing = entries.removeValue(forKey: key) {
            totalBytes -= existing.response.byteCount
        }
    }

    public func removeAll() async {
        entries.removeAll()
        totalBytes = 0
    }

    public func diagnostics() async -> ImageCacheDiagnostics {
        ImageCacheDiagnostics(entryCount: entries.count, totalBytes: totalBytes)
    }

    private func evictIfNeeded() {
        while entries.count > maximumEntryCount || totalBytes > maximumTotalBytes {
            guard let victim = entries.min(by: { $0.value.accessIndex < $1.value.accessIndex }) else { return }
            entries.removeValue(forKey: victim.key)
            totalBytes -= victim.value.response.byteCount
        }
    }
}

public protocol ImageDiskCaching: Sendable {
    func response(for key: ImageCacheKey) async throws -> ImageResponse?
    func store(_ response: ImageResponse, for key: ImageCacheKey) async throws
    func removeResponse(for key: ImageCacheKey) async throws
    func removeAll() async throws
    func diagnostics() async throws -> ImageCacheDiagnostics
}

public actor ImageDiskCache: ImageDiskCaching {
    private let rootDirectory: URL
    private let maximumEntryCount: Int
    private let maximumTotalBytes: Int

    public init(
        rootDirectory: URL,
        maximumEntryCount: Int = 500,
        maximumTotalBytes: Int = 100 * 1024 * 1024
    ) {
        self.rootDirectory = rootDirectory
        self.maximumEntryCount = max(1, maximumEntryCount)
        self.maximumTotalBytes = max(1, maximumTotalBytes)
    }

    public func response(for key: ImageCacheKey) async throws -> ImageResponse? {
        let fileURL = url(for: key)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try await AsyncFileDataReader.read(from: fileURL)
            guard !data.isEmpty else { return nil }
            try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
            return ImageResponse(data: data, source: .diskCache)
        } catch let error as CancellationError {
            throw error
        } catch {
            throw ImagePipelineError.storageFailed(code: "disk_read_failed")
        }
    }

    public func store(_ response: ImageResponse, for key: ImageCacheKey) async throws {
        do {
            try FileManager.default.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
            try response.data.write(to: url(for: key), options: [.atomic])
            try evictIfNeeded()
        } catch {
            throw ImagePipelineError.storageFailed(code: "disk_write_failed")
        }
    }

    public func removeResponse(for key: ImageCacheKey) async throws {
        let fileURL = url(for: key)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            throw ImagePipelineError.storageFailed(code: "disk_remove_failed")
        }
    }

    public func removeAll() async throws {
        guard FileManager.default.fileExists(atPath: rootDirectory.path) else { return }
        do {
            try FileManager.default.removeItem(at: rootDirectory)
        } catch {
            throw ImagePipelineError.storageFailed(code: "disk_remove_all_failed")
        }
    }

    public func diagnostics() async throws -> ImageCacheDiagnostics {
        guard FileManager.default.fileExists(atPath: rootDirectory.path) else {
            return ImageCacheDiagnostics(entryCount: 0, totalBytes: 0)
        }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: rootDirectory, includingPropertiesForKeys: [.fileSizeKey])
            var bytes = 0
            var count = 0
            for url in urls where url.pathExtension == "bin" {
                let values = try url.resourceValues(forKeys: [.fileSizeKey])
                bytes += values.fileSize ?? 0
                count += 1
            }
            return ImageCacheDiagnostics(entryCount: count, totalBytes: bytes)
        } catch {
            throw ImagePipelineError.storageFailed(code: "disk_diagnostics_failed")
        }
    }

    private func url(for key: ImageCacheKey) -> URL {
        rootDirectory.appendingPathComponent(key.storageFileName, isDirectory: false)
    }

    private struct DiskEntry {
        let url: URL
        let byteCount: Int
        let modifiedAt: Date
    }

    private func evictIfNeeded() throws {
        var entries = try diskEntries()
        var totalBytes = entries.reduce(0) { $0 + $1.byteCount }
        entries.sort {
            if $0.modifiedAt == $1.modifiedAt {
                return $0.url.lastPathComponent < $1.url.lastPathComponent
            }
            return $0.modifiedAt < $1.modifiedAt
        }
        while entries.count > maximumEntryCount || totalBytes > maximumTotalBytes {
            let victim = entries.removeFirst()
            try FileManager.default.removeItem(at: victim.url)
            totalBytes -= victim.byteCount
        }
    }

    private func diskEntries() throws -> [DiskEntry] {
        guard FileManager.default.fileExists(atPath: rootDirectory.path) else { return [] }
        let urls = try FileManager.default.contentsOfDirectory(
            at: rootDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]
        )
        return try urls.compactMap { url in
            guard url.pathExtension == "bin" else { return nil }
            let values = try url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
            return DiskEntry(
                url: url,
                byteCount: values.fileSize ?? 0,
                modifiedAt: values.contentModificationDate ?? .distantPast
            )
        }
    }
}

/// Performs blocking file reads away from the caller's actor executor.
///
/// The detached operation captures only the sendable URL and propagates cancellation before and
/// after the blocking read. The disk-cache actor remains the owner of cache identity and eviction.
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

public protocol ImagePipelineManaging: Sendable {
    func image(for request: ImageRequest) async throws -> ImageResponse
    func prefetch(_ requests: [ImageRequest]) async
    func removeCachedImage(for key: ImageCacheKey) async throws
    func removeAllCachedImages() async throws
    func diagnostics() async throws -> ImagePipelineDiagnostics
}

public struct ImagePipelineDiagnostics: Sendable, Equatable {
    public let memory: ImageCacheDiagnostics
    public let disk: ImageCacheDiagnostics?

    public init(memory: ImageCacheDiagnostics, disk: ImageCacheDiagnostics?) {
        self.memory = memory
        self.disk = disk
    }
}

public actor DefaultImagePipeline: ImagePipelineManaging {
    private let fetcher: any ImageDataFetching
    private let memoryCache: any ImageMemoryCaching
    private let diskCache: (any ImageDiskCaching)?

    public init(
        fetcher: any ImageDataFetching = URLSessionImageDataFetcher(),
        memoryCache: any ImageMemoryCaching = ImageMemoryCache(),
        diskCache: (any ImageDiskCaching)? = nil
    ) {
        self.fetcher = fetcher
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }

    public func image(for request: ImageRequest) async throws -> ImageResponse {
        if case let .data(data) = request.source {
            guard !data.isEmpty else { throw ImagePipelineError.emptyData }
            let response = ImageResponse(data: data, source: .providedData)
            if let key = request.cacheKey {
                await memoryCache.store(response, for: key)
                try await diskCache?.store(response, for: key)
            }
            return response
        }

        guard let key = request.cacheKey else {
            throw ImagePipelineError.invalidCacheKey
        }

        if request.cachePolicy != .reloadIgnoringCache {
            if let memory = await memoryCache.response(for: key) {
                return memory
            }
            if let disk = try await diskCache?.response(for: key) {
                await memoryCache.store(disk, for: key)
                return disk
            }
        }

        if request.cachePolicy == .returnCacheDataDontLoad {
            throw ImagePipelineError.cacheMiss
        }

        let fetched = try await fetcher.data(for: request)
        guard !fetched.data.isEmpty else { throw ImagePipelineError.emptyData }
        guard Self.isAllowedContentType(fetched.contentType, preferredContentTypes: request.preferredContentTypes) else {
            throw ImagePipelineError.fetchFailed(code: "unsupported_content_type")
        }
        let response = ImageResponse(data: fetched.data, contentType: fetched.contentType, source: .remoteFetch)
        await memoryCache.store(response, for: key)
        try await diskCache?.store(response, for: key)
        return response
    }

    public func prefetch(_ requests: [ImageRequest]) async {
        for request in requests {
            guard !Task.isCancelled else { return }
            _ = try? await image(for: request)
        }
    }

    public func removeCachedImage(for key: ImageCacheKey) async throws {
        await memoryCache.removeResponse(for: key)
        try await diskCache?.removeResponse(for: key)
    }

    public func removeAllCachedImages() async throws {
        await memoryCache.removeAll()
        try await diskCache?.removeAll()
    }

    public func diagnostics() async throws -> ImagePipelineDiagnostics {
        let memory = await memoryCache.diagnostics()
        let disk = try await diskCache?.diagnostics()
        return ImagePipelineDiagnostics(memory: memory, disk: disk)
    }

    private static func isAllowedContentType(_ contentType: String?, preferredContentTypes: Set<String>) -> Bool {
        guard !preferredContentTypes.isEmpty else { return true }
        guard let contentType else { return false }
        let normalizedContentType = contentType
            .split(separator: ";", maxSplits: 1, omittingEmptySubsequences: true)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let normalizedPreferred = Set(preferredContentTypes.map { $0.lowercased() })
        guard let normalizedContentType else { return false }
        return normalizedPreferred.contains(normalizedContentType)
    }
}
