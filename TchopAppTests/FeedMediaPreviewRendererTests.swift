import AVFoundation
import CoreGraphics
import CoreVideo
import Foundation
import ImageIO
import Testing
@testable import TchopApp

@Suite
@MainActor
struct FeedMediaPreviewRendererTests {
    @Test(arguments: [false, true])
    func videoThumbnailFitsPreviewEnvelope(rotated: Bool) async throws {
        let directory = try makeFixtureDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let movieURL = directory.appendingPathComponent("preview.mov")
        try await writeVideo(to: movieURL, rotated: rotated)

        let data = try #require(await FeedMediaPreviewRenderer.previewData(
            fileURLString: movieURL.absoluteString,
            kind: .video
        ))
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))

        #expect(image.width > 0 && image.height > 0)
        #expect(max(image.width, image.height) <= 1200)
        let expectedAspectRatio = rotated ? 0.75 : 4.0 / 3.0
        let aspectRatio = Double(image.width) / Double(image.height)
        #expect(abs(aspectRatio - expectedAspectRatio) < 0.005)
        #expect(rotated ? image.height > image.width : image.width > image.height)
    }

    @Test(arguments: [FeedMediaPreviewKind.image, .video, .pdf])
    func missingMediaKeepsFallback(kind: FeedMediaPreviewKind) async throws {
        let directory = try makeFixtureDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let missingURL = directory.appendingPathComponent("missing")

        let data = await FeedMediaPreviewRenderer.previewData(
            fileURLString: missingURL.absoluteString,
            kind: kind
        )
        #expect(data == nil)
    }

    @Test(arguments: [FeedMediaPreviewKind.image, .video, .pdf])
    func malformedMediaKeepsFallback(kind: FeedMediaPreviewKind) async throws {
        let directory = try makeFixtureDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let malformedURL = directory.appendingPathComponent("malformed")
        try Data("Not a media file".utf8).write(to: malformedURL)

        let data = await FeedMediaPreviewRenderer.previewData(
            fileURLString: malformedURL.absoluteString,
            kind: kind
        )
        #expect(data == nil)
    }

    private func makeFixtureDirectory() throws -> URL {
        // These files belong only to the running Simulator test app, not the user's media.
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("TC-MP01-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func writeVideo(to url: URL, rotated: Bool) async throws {
        let width = 2048
        let height = 1536
        let writer = try AVAssetWriter(outputURL: url, fileType: .mov)
        defer {
            if writer.status == .writing {
                writer.cancelWriting()
            }
        }
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ])
        input.expectsMediaDataInRealTime = false
        if rotated {
            input.transform = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: CGFloat(height), ty: 0)
        }
        let adapter = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
        )
        try #require(writer.canAdd(input))
        writer.add(input)
        try #require(writer.startWriting())
        writer.startSession(atSourceTime: .zero)

        var buffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &buffer
        )
        try #require(status == kCVReturnSuccess)
        let pixelBuffer = try #require(buffer)
        try #require(CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess)
        do {
            defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
            let base = try #require(CVPixelBufferGetBaseAddress(pixelBuffer))
            base.initializeMemory(
                as: UInt8.self,
                repeating: 0,
                count: CVPixelBufferGetBytesPerRow(pixelBuffer) * height
            )
        }

        try #require(input.isReadyForMoreMediaData)
        try #require(adapter.append(pixelBuffer, withPresentationTime: .zero))
        input.markAsFinished()
        writer.endSession(atSourceTime: CMTime(value: 1, timescale: 30))
        await withCheckedContinuation { continuation in
            writer.finishWriting { continuation.resume() }
        }
        try #require(writer.status == .completed)
    }
}
