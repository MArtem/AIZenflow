import XCTest
@testable import AppImagePipeline

final class AppImagePipelineTests: XCTestCase {
    func testCacheKeyDescriptionIsRedacted() throws {
        let key = try ImageCacheKey("auth.access-token-image?token=secret")
        XCTAssertEqual(key.description, "ImageCacheKey(<redacted>)")
        XCTAssertFalse(key.description.contains("secret"))
        XCTAssertFalse(key.description.contains("auth.access-token"))
    }

    func testURLRequestRejectsUnsupportedScheme() throws {
        let url = try XCTUnwrap(URL(string: "file:///private/image.png"))
        XCTAssertThrowsError(try ImageRequest.url(url)) { error in
            XCTAssertEqual(error as? ImagePipelineError, .unsupportedURLScheme)
        }
    }

    func testMemoryCacheStoresAndReturnsMemorySource() async throws {
        let key = try ImageCacheKey("image-one")
        let cache = ImageMemoryCache()
        await cache.store(ImageResponse(data: Data([1, 2, 3]), source: .remoteFetch), for: key)
        let response = await cache.response(for: key)
        XCTAssertEqual(response?.data, Data([1, 2, 3]))
        XCTAssertEqual(response?.source, .memoryCache)
    }

    func testMemoryCacheEvictsLeastRecentlyUsedEntry() async throws {
        let key1 = try ImageCacheKey("one")
        let key2 = try ImageCacheKey("two")
        let cache = ImageMemoryCache(maximumEntryCount: 1, maximumTotalBytes: 100)
        await cache.store(ImageResponse(data: Data([1]), source: .remoteFetch), for: key1)
        await cache.store(ImageResponse(data: Data([2]), source: .remoteFetch), for: key2)
        let first = await cache.response(for: key1)
        let second = await cache.response(for: key2)
        XCTAssertNil(first)
        XCTAssertEqual(second?.data, Data([2]))
    }

    func testPipelineReturnsProvidedDataAndCachesIt() async throws {
        let key = try ImageCacheKey("provided")
        let pipeline = DefaultImagePipeline(fetcher: MockImageDataFetcher())
        let response = try await pipeline.image(for: .data(Data([9, 9]), cacheKey: key))
        XCTAssertEqual(response.source, .providedData)
        let cached = try await pipeline.image(for: ImageRequest(source: .url(URL(string: "https://example.com/a.png")!), cacheKey: key, cachePolicy: .returnCacheDataDontLoad))
        XCTAssertEqual(cached.source, .memoryCache)
        XCTAssertEqual(cached.data, Data([9, 9]))
    }

    func testPipelineFetchesAndThenUsesMemoryCache() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/image.png?token=secret"))
        let request = try ImageRequest.url(url)
        let key = try XCTUnwrap(request.cacheKey)
        let fetcher = MockImageDataFetcher(results: [key: .success(ImageFetchResult(data: Data([1, 2, 3]), contentType: "image/png"))])
        let pipeline = DefaultImagePipeline(fetcher: fetcher)

        let first = try await pipeline.image(for: request)
        let second = try await pipeline.image(for: request)

        XCTAssertEqual(first.source, .remoteFetch)
        XCTAssertEqual(second.source, .memoryCache)
        let requestCount = await fetcher.requestCount(for: key)
        XCTAssertEqual(requestCount, 1)
    }

    func testPipelineRejectsUnexpectedContentType() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/image.svg"))
        let key = try ImageCacheKey.url(url)
        let fetcher = MockImageDataFetcher(results: [key: .success(ImageFetchResult(data: Data([1]), contentType: "image/svg+xml"))])
        let pipeline = DefaultImagePipeline(fetcher: fetcher)

        do {
            _ = try await pipeline.image(for: try ImageRequest.url(url, preferredContentTypes: ["image/png"]))
            XCTFail("Expected unsupported content type failure")
        } catch let error as ImagePipelineError {
            XCTAssertEqual(error, .fetchFailed(code: "unsupported_content_type"))
            XCTAssertEqual(error.description, "ImagePipelineError.fetchFailed(code: unsupported_content_type)")
        }
    }

    func testReloadIgnoringCacheRefetches() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/reload.png"))
        let key = try ImageCacheKey.url(url)
        let fetcher = MockImageDataFetcher(results: [key: .success(ImageFetchResult(data: Data([1])))])
        let pipeline = DefaultImagePipeline(fetcher: fetcher)

        _ = try await pipeline.image(for: try ImageRequest.url(url))
        await fetcher.setResult(.success(ImageFetchResult(data: Data([2]))), for: key)
        let reloaded = try await pipeline.image(for: try ImageRequest.url(url, cachePolicy: .reloadIgnoringCache))

        XCTAssertEqual(reloaded.data, Data([2]))
        let requestCount = await fetcher.requestCount(for: key)
        XCTAssertEqual(requestCount, 2)
    }

    func testReturnCacheDataDontLoadThrowsOnMiss() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/missing.png"))
        let pipeline = DefaultImagePipeline(fetcher: MockImageDataFetcher())
        do {
            _ = try await pipeline.image(for: try ImageRequest.url(url, cachePolicy: .returnCacheDataDontLoad))
            XCTFail("Expected cache miss")
        } catch let error as ImagePipelineError {
            XCTAssertEqual(error, .cacheMiss)
        }
    }

    func testDiskCachePersistsResponse() async throws {
        let root = try makeScratchDirectory(named: "disk-cache")
        defer { try? FileManager.default.removeItem(at: root) }
        let key = try ImageCacheKey("disk")
        let cache = ImageDiskCache(rootDirectory: root)
        try await cache.store(ImageResponse(data: Data([4, 5, 6]), source: .remoteFetch), for: key)

        let newCache = ImageDiskCache(rootDirectory: root)
        let response = try await newCache.response(for: key)
        XCTAssertEqual(response?.data, Data([4, 5, 6]))
        XCTAssertEqual(response?.source, .diskCache)
    }

    func testDiskCacheEvictsOldestEntryWhenEntryLimitIsExceeded() async throws {
        let root = try makeScratchDirectory(named: "disk-eviction")
        defer { try? FileManager.default.removeItem(at: root) }
        let firstKey = try ImageCacheKey("first")
        let secondKey = try ImageCacheKey("second")
        let cache = ImageDiskCache(rootDirectory: root, maximumEntryCount: 1, maximumTotalBytes: 100)

        try await cache.store(ImageResponse(data: Data([1]), source: .remoteFetch), for: firstKey)
        try await cache.store(ImageResponse(data: Data([2]), source: .remoteFetch), for: secondKey)

        let first = try await cache.response(for: firstKey)
        let second = try await cache.response(for: secondKey)
        XCTAssertNil(first)
        XCTAssertEqual(second?.data, Data([2]))
    }

    func testPipelineUsesDiskCacheWhenMemoryIsEmpty() async throws {
        let root = try makeScratchDirectory(named: "pipeline-disk")
        defer { try? FileManager.default.removeItem(at: root) }
        let url = try XCTUnwrap(URL(string: "https://example.com/disk.png"))
        let key = try ImageCacheKey.url(url)
        let fetcher = MockImageDataFetcher(results: [key: .success(ImageFetchResult(data: Data([7])))])

        let firstPipeline = DefaultImagePipeline(fetcher: fetcher, diskCache: ImageDiskCache(rootDirectory: root))
        _ = try await firstPipeline.image(for: try ImageRequest.url(url))

        let secondPipeline = DefaultImagePipeline(fetcher: fetcher, diskCache: ImageDiskCache(rootDirectory: root))
        let cached = try await secondPipeline.image(for: try ImageRequest.url(url))
        XCTAssertEqual(cached.source, .diskCache)
        let requestCount = await fetcher.requestCount(for: key)
        XCTAssertEqual(requestCount, 1)
    }

    func testDiagnosticsReportsCacheSizes() async throws {
        let key = try ImageCacheKey("diagnostics")
        let cache = ImageMemoryCache()
        await cache.store(ImageResponse(data: Data([1, 2, 3, 4]), source: .remoteFetch), for: key)
        let diagnostics = await cache.diagnostics()
        XCTAssertEqual(diagnostics.entryCount, 1)
        XCTAssertEqual(diagnostics.totalBytes, 4)
    }

    func testRemoveAllClearsCaches() async throws {
        let key = try ImageCacheKey("remove-all")
        let pipeline = DefaultImagePipeline(fetcher: MockImageDataFetcher())
        _ = try await pipeline.image(for: .data(Data([1]), cacheKey: key))
        try await pipeline.removeAllCachedImages()
        let diagnostics = try await pipeline.diagnostics()
        XCTAssertEqual(diagnostics.memory.entryCount, 0)
    }

    func testErrorDescriptionsAreSanitized() {
        XCTAssertEqual(ImagePipelineError.fetchFailed(code: "remote_fetch_failed").description, "ImagePipelineError.fetchFailed(code: remote_fetch_failed)")
        XCTAssertFalse(ImagePipelineError.fetchFailed(code: "remote_fetch_failed").description.contains("https://"))
        XCTAssertEqual(ImagePipelineError.storageFailed(code: "https://example.com/private.png?token=secret").description, "ImagePipelineError.storageFailed(code: redacted)")
    }

    private func makeScratchDirectory(named name: String) throws -> URL {
        let current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let root = current.deletingLastPathComponent()
            .appendingPathComponent("WorktreeScratch", isDirectory: true)
            .appendingPathComponent("AppImagePipeline", isDirectory: true)
            .appendingPathComponent("TestData", isDirectory: true)
            .appendingPathComponent(name + "-" + UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }
}
