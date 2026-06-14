import XCTest
@testable import AppRemoteAssets

actor RecordingManifestTransport: RemoteAssetManifestDataTransport {
    private(set) var requested: [RemoteAssetManifestRequest] = []
    var response: RemoteAssetManifestDataResponse

    init(response: RemoteAssetManifestDataResponse) {
        self.response = response
    }

    func loadData(for request: RemoteAssetManifestRequest) async throws -> RemoteAssetManifestDataResponse {
        requested.append(request)
        return response
    }

    func requestCount() -> Int {
        requested.count
    }
}

final class AppRemoteAssetsTests: XCTestCase {
    func testIdentifierRejectsTraversalAndSeparators() throws {
        let traversal = "../hero"
        let forwardSeparator = "folder/hero"
        let backwardSeparator = "folder\\hero"
        let safe = "images.hero:v1"
        XCTAssertThrowsError(try RemoteAssetID(traversal))
        XCTAssertThrowsError(try RemoteAssetID(forwardSeparator))
        XCTAssertThrowsError(try RemoteAssetID(backwardSeparator))
        XCTAssertNoThrow(try RemoteAssetID(safe))
    }

    func testLocationRejectsUnsupportedURLScheme() throws {
        XCTAssertThrowsError(try RemoteAssetLocation(url: URL(string: "file:///private/asset.json")!))
        XCTAssertThrowsError(try RemoteAssetLocation(url: URL(string: "http://example.com/assets/hero.png")!))
        XCTAssertNoThrow(try RemoteAssetLocation(url: URL(string: "https://example.com/assets/hero.png?sig=123")!))
    }

    func testLocationAllowsInsecureSchemeOnlyWhenExplicitlyConfigured() throws {
        let location = try RemoteAssetLocation(
            url: URL(string: "http://localhost/assets/hero.png")!,
            allowedSchemes: ["https", "http"]
        )
        XCTAssertEqual(location.url.scheme, "http")
    }

    func testURLRedactorRemovesQueryFragmentAndUserInfo() throws {
        let url = URL(string: "https://user:credential@example.com/assets/manifest.json?signature=abc#part")!
        let redacted = RemoteAssetURLRedactor.redacted(url)
        XCTAssertTrue(redacted.contains("https://example.com/"))
        XCTAssertFalse(redacted.contains("assets/manifest.json"))
        XCTAssertFalse(redacted.contains("signature"))
        XCTAssertFalse(redacted.contains("part"))
        XCTAssertFalse(redacted.contains("credential"))
        XCTAssertFalse(redacted.contains("user@"))
    }

    func testChecksumRequiresAlgorithmSpecificHexLength() throws {
        XCTAssertNoThrow(try RemoteAssetChecksum(algorithm: .sha256, value: String(repeating: "a", count: 64)))
        XCTAssertThrowsError(try RemoteAssetChecksum(algorithm: .sha256, value: String(repeating: "a", count: 63)))
        XCTAssertThrowsError(try RemoteAssetChecksum(algorithm: .sha384, value: String(repeating: "a", count: 64)))
    }

    func testFailureContextIsSanitized() {
        let failure = RemoteAssetFailure(code: .transportFailed, context: "https://example.com/private?token=value")
        XCTAssertEqual(failure.context, "redacted")
        XCTAssertFalse(failure.description.contains("token"))
        XCTAssertFalse(failure.description.contains("https://"))
    }

    func testManifestRequestRejectsInvalidStatusRangeAndInsecureSchemeByDefault() throws {
        XCTAssertThrowsError(
            try RemoteAssetManifestRequest(
                url: URL(string: "https://example.com/assets/manifest.json")!,
                acceptedStatusCodes: 0...999
            )
        )
        XCTAssertThrowsError(
            try RemoteAssetManifestRequest(
                url: URL(string: "http://example.com/assets/manifest.json")!
            )
        )
        XCTAssertNoThrow(
            try RemoteAssetManifestRequest(
                url: URL(string: "http://localhost/assets/manifest.json")!,
                allowedSchemes: ["https", "http"]
            )
        )
    }

    func testDescriptorRejectsZeroExpectedByteCount() throws {
        XCTAssertThrowsError(
            try RemoteAssetDescriptor(
                id: try RemoteAssetID("asset.zero"),
                version: try RemoteAssetVersion("1"),
                location: try RemoteAssetLocation(url: URL(string: "https://example.com/assets/zero.bin")!),
                expectedByteCount: 0
            )
        )
    }

    func testManifestRejectsDuplicateAssetIDs() throws {
        let asset = try makeAsset(id: "asset.hero", version: "1")
        XCTAssertThrowsError(
            try RemoteAssetManifest(
                schemaVersion: try RemoteAssetVersion("1"),
                assets: [asset, asset]
            )
        )
    }

    func testPlannerFetchesMissingAndKeepsImmutableCurrentAsset() throws {
        let missing = try makeAsset(id: "asset.missing", version: "1", cachePolicy: .immutable)
        let current = try makeAsset(id: "asset.current", version: "2", cachePolicy: .immutable)
        let manifest = try RemoteAssetManifest(
            schemaVersion: try RemoteAssetVersion("1"),
            assets: [missing, current]
        )
        let local = try RemoteAssetLocalRecord(
            id: try RemoteAssetID("asset.current"),
            version: try RemoteAssetVersion("2"),
            storedAt: Date(timeIntervalSince1970: 100)
        )

        let plan = RemoteAssetFetchPlanner().makePlan(
            manifest: manifest,
            localRecords: [local],
            now: Date(timeIntervalSince1970: 200)
        )

        XCTAssertEqual(plan.actions.count, 2)
        XCTAssertEqual(plan.fetchActions.count, 1)
        XCTAssertEqual(plan.keepActions.count, 1)
        if case let .fetch(asset, reason) = plan.fetchActions[0] {
            XCTAssertEqual(asset.id, try RemoteAssetID("asset.missing"))
            XCTAssertEqual(reason, .missingLocalRecord)
        } else {
            XCTFail("Expected fetch action")
        }
    }

    func testPlannerRefreshesExpiredAssetAndRemovesOrphansWhenRequested() throws {
        let asset = try makeAsset(
            id: "asset.hero",
            version: "1",
            cachePolicy: .refreshAfter(seconds: 10)
        )
        let manifest = try RemoteAssetManifest(
            schemaVersion: try RemoteAssetVersion("1"),
            assets: [asset]
        )
        let local = try RemoteAssetLocalRecord(
            id: try RemoteAssetID("asset.hero"),
            version: try RemoteAssetVersion("1"),
            storedAt: Date(timeIntervalSince1970: 0),
            validatedAt: Date(timeIntervalSince1970: 20)
        )
        let orphan = try RemoteAssetLocalRecord(
            id: try RemoteAssetID("asset.old"),
            version: try RemoteAssetVersion("1"),
            storedAt: Date(timeIntervalSince1970: 0)
        )

        let plan = RemoteAssetFetchPlanner(removesLocalRecordsMissingFromManifest: true).makePlan(
            manifest: manifest,
            localRecords: [local, orphan],
            now: Date(timeIntervalSince1970: 40)
        )

        XCTAssertEqual(plan.fetchActions.count, 1)
        XCTAssertEqual(plan.removeActions.count, 1)
        if case let .fetch(_, reason) = plan.fetchActions[0] {
            XCTAssertEqual(reason, .refreshWindowExpired)
        } else {
            XCTFail("Expected refresh action")
        }
    }

    func testManifestServiceDecodesThroughTransportAndRejectsOversize() async throws {
        let manifest = try RemoteAssetManifest(
            schemaVersion: try RemoteAssetVersion("1"),
            assets: [try makeAsset(id: "asset.hero", version: "1")]
        )
        let data = try JSONEncoder().encode(manifest)
        let transport = RecordingManifestTransport(
            response: RemoteAssetManifestDataResponse(statusCode: 200, payload: data)
        )
        let service = RemoteAssetManifestService(transport: transport)
        let request = try RemoteAssetManifestRequest(
            url: URL(string: "https://example.com/assets/manifest.json?signature=abc")!,
            maximumResponseBytes: data.count
        )

        let loaded = try await service.loadManifest(request)

        XCTAssertEqual(loaded.assets.count, 1)
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 1)

        let tooSmallRequest = try RemoteAssetManifestRequest(
            url: URL(string: "https://example.com/assets/manifest.json")!,
            maximumResponseBytes: data.count - 1
        )
        do {
            _ = try await service.loadManifest(tooSmallRequest)
            XCTFail("Expected response size failure")
        } catch let failure as RemoteAssetFailure {
            XCTAssertEqual(failure.code, .responseTooLarge)
        }
    }

    func testDescriptionsDoNotExposeSensitiveInputs() throws {
        let asset = try makeAsset(
            id: "asset.private.hero",
            version: "release-2026",
            url: "https://example.com/assets/hero.png?signature=abc#debug"
        )
        let manifest = try RemoteAssetManifest(
            schemaVersion: try RemoteAssetVersion("schema-private"),
            assets: [asset]
        )

        XCTAssertFalse(asset.description.contains("asset.private.hero"))
        XCTAssertFalse(asset.description.contains("release-2026"))
        XCTAssertFalse(asset.description.contains("signature"))
        XCTAssertFalse(asset.description.contains("debug"))
        XCTAssertFalse(manifest.description.contains("schema-private"))
    }

    private func makeAsset(
        id: String,
        version: String,
        url: String = "https://example.com/assets/file.bin?signature=abc#fragment",
        cachePolicy: RemoteAssetCachePolicy = .revalidateOnLaunch
    ) throws -> RemoteAssetDescriptor {
        try RemoteAssetDescriptor(
            id: try RemoteAssetID(id),
            version: try RemoteAssetVersion(version),
            location: try RemoteAssetLocation(url: URL(string: url)!),
            kind: .data,
            mediaType: .binary,
            expectedByteCount: 128,
            checksum: nil,
            cachePolicy: cachePolicy
        )
    }
}
