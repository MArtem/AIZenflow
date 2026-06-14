import XCTest
@testable import AppUploads

actor RecordingUploadTransport: UploadTransport {
    private(set) var sentUploads: [PreparedUpload] = []
    var responseByteCount: Int
    var statusCode: Int

    init(responseByteCount: Int = 0, statusCode: Int = 201) {
        self.responseByteCount = responseByteCount
        self.statusCode = statusCode
    }

    func send(
        _ upload: PreparedUpload,
        progress: (@Sendable (UploadProgress) -> Void)?
    ) async throws -> UploadResponse {
        sentUploads.append(upload)
        progress?(UploadProgress(id: upload.id, sentBytes: upload.expectedByteCount, expectedBytes: upload.expectedByteCount))
        return UploadResponse(id: upload.id, statusCode: statusCode, responseByteCount: responseByteCount)
    }

    func sentCount() -> Int {
        sentUploads.count
    }

    func firstUpload() -> PreparedUpload? {
        sentUploads.first
    }
}

actor FlakyUploadTransport: UploadTransport {
    private var remainingFailures: Int
    private(set) var sentUploads: [PreparedUpload] = []

    init(remainingFailures: Int) {
        self.remainingFailures = remainingFailures
    }

    func send(
        _ upload: PreparedUpload,
        progress: (@Sendable (UploadProgress) -> Void)?
    ) async throws -> UploadResponse {
        sentUploads.append(upload)
        if remainingFailures > 0 {
            remainingFailures -= 1
            throw UploadFailure(.transportUnavailable, operation: .transport)
        }
        return UploadResponse(id: upload.id, statusCode: 201, responseByteCount: 0)
    }

    func sentCount() -> Int {
        sentUploads.count
    }
}

actor RecordingRetrySleeper: UploadRetrySleeping {
    private(set) var sleeps: [UInt64] = []

    func sleep(nanoseconds: UInt64) async throws {
        sleeps.append(nanoseconds)
    }

    func recordedSleeps() -> [UInt64] {
        sleeps
    }
}

final class AppUploadsTests: XCTestCase {
    func testSafeUploadNameRejectsTraversalAndSeparators() throws {
        XCTAssertThrowsError(try SafeUploadName("../avatar.jpg"))
        XCTAssertThrowsError(try SafeUploadName("folder/avatar.jpg"))
        XCTAssertThrowsError(try SafeUploadName("folder\\avatar.jpg"))
        XCTAssertNoThrow(try SafeUploadName("avatar.jpg"))
    }

    func testRequestRejectsUnsupportedURLScheme() throws {
        let id = try UploadID("upload-1")
        let payload = UploadPayload.data(Data([1, 2, 3]), mediaType: .binary)
        XCTAssertThrowsError(
            try UploadRequest(
                id: id,
                url: URL(string: "file:///local/path")!,
                payload: payload
            )
        )
    }

    func testRequestRejectsInsecureSchemeByDefault() throws {
        let id = try UploadID("upload-http")
        let payload = UploadPayload.data(Data([1]), mediaType: .binary)
        XCTAssertThrowsError(
            try UploadRequest(
                id: id,
                url: URL(string: "http://example.com/upload")!,
                payload: payload
            )
        ) { error in
            XCTAssertEqual(error as? UploadFailure, UploadFailure(.invalidURL, operation: .validation))
        }
    }

    func testRequestAllowsInsecureSchemeOnlyWhenExplicitlyConfigured() throws {
        let id = try UploadID("upload-local")
        let payload = UploadPayload.data(Data([1]), mediaType: .binary)
        let request = try UploadRequest(
            id: id,
            url: URL(string: "http://localhost/upload")!,
            payload: payload,
            allowedSchemes: ["https", "http"]
        )
        XCTAssertEqual(request.url.scheme, "http")
    }

    func testRequestRejectsZeroSizeLimits() throws {
        let id = try UploadID("upload-zero")
        let payload = UploadPayload.data(Data([1]), mediaType: .binary)
        XCTAssertThrowsError(
            try UploadRequest(
                id: id,
                url: URL(string: "https://example.com/upload")!,
                payload: payload,
                maximumPayloadBytes: 0
            )
        )
        XCTAssertThrowsError(
            try UploadRequest(
                id: id,
                url: URL(string: "https://example.com/upload")!,
                payload: payload,
                maximumResponseBytes: 0
            )
        )
    }

    func testURLRedactorRemovesQueryAndFragment() throws {
        let url = URL(string: "https://example.com/upload/avatar?token=abc#frag")!
        let redacted = UploadURLRedactor.redacted(url)
        XCTAssertFalse(redacted.contains("token"))
        XCTAssertFalse(redacted.contains("frag"))
        XCTAssertTrue(redacted.contains("https://example.com"))
    }

    func testServiceUploadsDataThroughTransport() async throws {
        let transport = RecordingUploadTransport(responseByteCount: 12, statusCode: 201)
        let service = UploadService(transport: transport)
        let request = try UploadRequest(
            id: try UploadID("upload-data"),
            url: URL(string: "https://example.com/upload")!,
            payload: .data(Data([1, 2, 3]), mediaType: .binary),
            maximumPayloadBytes: 10,
            maximumResponseBytes: 20
        )

        let response = try await service.upload(request)

        XCTAssertEqual(response.statusCode, 201)
        XCTAssertEqual(response.responseByteCount, 12)
        let sentCount = await transport.sentCount()
        let firstUpload = await transport.firstUpload()
        XCTAssertEqual(sentCount, 1)
        let prepared = try XCTUnwrap(firstUpload)
        XCTAssertEqual(prepared.expectedByteCount, 3)
    }

    func testServiceRejectsOversizedPayloadBeforeTransport() async throws {
        let transport = RecordingUploadTransport()
        let service = UploadService(transport: transport)
        let request = try UploadRequest(
            id: try UploadID("upload-size"),
            url: URL(string: "https://example.com/upload")!,
            payload: .data(Data([1, 2, 3]), mediaType: .binary),
            maximumPayloadBytes: 2
        )

        do {
            _ = try await service.upload(request)
            XCTFail("Expected payload size failure")
        } catch let failure as UploadFailure {
            XCTAssertEqual(failure.code, .payloadTooLarge)
        }
        let sentCount = await transport.sentCount()
        XCTAssertEqual(sentCount, 0)
    }

    func testFileDeclaredSizeRejectsOversizedPayloadBeforeFileRead() async throws {
        let file = try UploadFileReference(
            fileURL: URL(fileURLWithPath: "/missing/large.bin"),
            fieldName: try SafeUploadName("file"),
            fileName: try SafeUploadName("large.bin"),
            mediaType: .binary,
            declaredByteCount: 10
        )
        let request = try UploadRequest(
            id: try UploadID("upload-declared-size"),
            url: URL(string: "https://example.com/upload")!,
            payload: .file(file),
            maximumPayloadBytes: 5
        )

        do {
            _ = try await UploadBodyLoadWorker().prepare(request)
            XCTFail("Expected payloadTooLarge before file read")
        } catch let failure as UploadFailure {
            XCTAssertEqual(failure, UploadFailure(.payloadTooLarge, operation: .validation))
        }
    }

    func testRetryUsesInjectedSleeper() async throws {
        let transport = FlakyUploadTransport(remainingFailures: 1)
        let sleeper = RecordingRetrySleeper()
        let service = UploadService(transport: transport, retrySleeper: sleeper)
        let retryPolicy = try UploadRetryPolicy(maximumAttempts: 2, delayNanoseconds: 123)
        let request = try UploadRequest(
            id: try UploadID("upload-retry"),
            url: URL(string: "https://example.com/upload")!,
            payload: .data(Data([1]), mediaType: .binary),
            retryPolicy: retryPolicy
        )

        let response = try await service.upload(request)

        let sentCount = await transport.sentCount()
        let sleeps = await sleeper.recordedSleeps()
        XCTAssertEqual(response.statusCode, 201)
        XCTAssertEqual(sentCount, 2)
        XCTAssertEqual(sleeps, [123])
    }

    func testMultipartPreparationUsesWorkerBoundary() async throws {
        let scratch = try makeScratchDirectory(named: "multipart")
        let fileURL = scratch.appendingPathComponent("avatar.bin")
        try Data([4, 5, 6]).write(to: fileURL, options: .atomic)

        let file = try UploadFileReference(
            fileURL: fileURL,
            fieldName: try SafeUploadName("file"),
            fileName: try SafeUploadName("avatar.bin"),
            mediaType: .binary
        )
        let form = try UploadMultipartForm(
            fields: [try UploadFormField(name: try SafeUploadName("kind"), value: "avatar")],
            files: [file]
        )
        let request = try UploadRequest(
            id: try UploadID("upload-multipart"),
            url: URL(string: "https://example.com/upload")!,
            payload: .multipart(form)
        )
        let prepared = try await UploadBodyLoadWorker().prepare(request)

        XCTAssertTrue(prepared.mediaType.value.contains("multipart/form-data"))
        XCTAssertGreaterThan(prepared.expectedByteCount, 3)
    }

    func testDescriptionsAreRedacted() throws {
        let file = try UploadFileReference(
            fileURL: URL(fileURLWithPath: "/Users/example/private/avatar.bin"),
            fieldName: try SafeUploadName("file"),
            fileName: try SafeUploadName("avatar.bin"),
            mediaType: .binary
        )
        let field = try UploadFormField(name: try SafeUploadName("note"), value: "private-value")

        XCTAssertFalse(file.description.contains("/Users/example"))
        XCTAssertFalse(file.description.contains("avatar.bin"))
        XCTAssertFalse(field.description.contains("private-value"))
    }

    private func makeScratchDirectory(named name: String) throws -> URL {
        let packageURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let scratchURL = packageURL
            .deletingLastPathComponent()
            .appendingPathComponent("TestScratch", isDirectory: true)
            .appendingPathComponent(name, isDirectory: true)
        try? FileManager.default.removeItem(at: scratchURL)
        try FileManager.default.createDirectory(at: scratchURL, withIntermediateDirectories: true)
        return scratchURL
    }
}
