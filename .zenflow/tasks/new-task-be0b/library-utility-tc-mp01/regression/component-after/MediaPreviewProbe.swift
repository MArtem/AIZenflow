import Foundation
import AVFoundation
import CoreGraphics
import CoreVideo
import ImageIO
import PDFKit
import UniformTypeIdentifiers
enum FeedMediaPreviewKind: String, Hashable, Sendable {
    case image
    case video
    case pdf
}

enum FeedMediaPreviewRenderer {
    private static let maxPreviewPixelSize: CGFloat = 1200

    static func previewData(fileURLString: String?, kind: FeedMediaPreviewKind) async -> Data? {
        guard let fileURL = ComposerMediaPathResolver.resolve(fileURLString: fileURLString) else {
            return nil
        }

        switch kind {
        case .image:
            return await detachedData {
                downsampledImageData(at: fileURL, maxPixelSize: maxPreviewPixelSize)
            }
        case .video:
            return await videoPreviewData(at: fileURL)
        case .pdf:
            return await pdfPreviewData(at: fileURL)
        }
    }

    private static func downsampledImageData(at url: URL, maxPixelSize: CGFloat) -> Data? {
        let options = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(url as CFURL, options) else {
            return nil
        }

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
            return nil
        }

        return encodedPNGData(for: cgImage)
    }

    private static func videoPreviewData(at url: URL) async -> Data? {
        let operation = Task.detached(priority: .utility) { () -> Data? in
            do {
                try Task.checkCancellation()
                let asset = AVURLAsset(url: url)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.maximumSize = CGSize(width: maxPreviewPixelSize, height: maxPreviewPixelSize)
                let result = try await generator.image(at: .zero)
                try Task.checkCancellation()
                return encodedPNGData(for: result.image)
            } catch {
                return nil
            }
        }

        return await withTaskCancellationHandler(operation: {
            await operation.value
        }, onCancel: {
            operation.cancel()
        })
    }

    private static func pdfPreviewData(at url: URL) async -> Data? {
        await detachedData {
            do {
                let handle = try FileHandle(forReadingFrom: url)
                defer { try? handle.close() }
                let data = try handle.readToEnd() ?? Data()
                try Task.checkCancellation()
                return pdfThumbnailData(from: data)
            } catch {
                return nil
            }
        }
    }

    private static func pdfThumbnailData(from data: Data) -> Data? {
        guard let document = PDFDocument(data: data),
              let page = document.page(at: 0) else {
            return nil
        }

        let pageBounds = page.bounds(for: .mediaBox)
        guard pageBounds.width > 0, pageBounds.height > 0 else {
            return nil
        }

        let targetSize = CGSize(width: 640, height: 420)
        let scale = min(targetSize.width / pageBounds.width, targetSize.height / pageBounds.height)
        let pixelWidth = max(Int(ceil(pageBounds.width * scale)), 1)
        let pixelHeight = max(Int(ceil(pageBounds.height * scale)), 1)
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                  data: nil,
                  width: pixelWidth,
                  height: pixelHeight,
                  bitsPerComponent: 8,
                  bytesPerRow: 0,
                  space: colorSpace,
                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else {
            return nil
        }

        context.setFillColor(gray: 1, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
        context.saveGState()
        context.translateBy(x: 0, y: CGFloat(pixelHeight))
        context.scaleBy(x: scale, y: -scale)
        context.translateBy(x: -pageBounds.minX, y: -pageBounds.minY)
        page.draw(with: .mediaBox, to: context)
        context.restoreGState()

        guard let cgImage = context.makeImage() else {
            return nil
        }
        return encodedPNGData(for: cgImage)
    }

    private static func encodedPNGData(for image: CGImage) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return data as Data
    }

    private static func detachedData(
        _ operationBody: @escaping @Sendable () -> Data?
    ) async -> Data? {
        let operation = Task.detached(priority: .utility) { () -> Data? in
            do {
                try Task.checkCancellation()
                let data = operationBody()
                try Task.checkCancellation()
                return data
            } catch {
                return nil
            }
        }

        return await withTaskCancellationHandler(operation: {
            await operation.value
        }, onCancel: {
            operation.cancel()
        })
    }
}


private enum ComposerMediaPathResolver {
    static func resolve(fileURLString: String?) -> URL? {
        guard let fileURLString, let url = URL(string: fileURLString), url.isFileURL,
              FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }
}
private enum FixtureFailure: Error { case condition, missingValue }
private func require(_ condition: Bool) throws {
    guard condition else { throw FixtureFailure.condition }
}
private func require<T>(_ value: T?) throws -> T {
    guard let value else { throw FixtureFailure.missingValue }
    return value
}
@main
@MainActor
private struct MediaPreviewProbe {
    static func main() async {
        let probe = MediaPreviewProbe()
        var failures = 0
        var assertions = 0
        do {
            let directory = try probe.makeFixtureDirectory()
            defer { try? FileManager.default.removeItem(at: directory) }
            for rotated in [false, true] {
                let url = directory.appendingPathComponent(rotated ? "rotated.mov" : "normal.mov")
                try await probe.writeVideo(to: url, rotated: rotated)
                let data = try require(await FeedMediaPreviewRenderer.previewData(fileURLString: url.absoluteString, kind: .video))
                let imageSource = try require(CGImageSourceCreateWithData(data as CFData, nil))
                let image = try require(CGImageSourceCreateImageAtIndex(imageSource, 0, nil))
                let aspect = Double(image.width) / Double(image.height)
                let checks = [image.width > 0 && image.height > 0,
                              max(image.width, image.height) <= 1200,
                              abs(aspect - (rotated ? 0.75 : 4.0 / 3.0)) < 0.005,
                              rotated ? image.height > image.width : image.width > image.height]
                failures += checks.filter { !$0 }.count
                assertions += checks.count
                print(String(data: try JSONSerialization.data(withJSONObject: ["case": rotated ? "rotated" : "normal", "width": image.width, "height": image.height, "checks": checks]), encoding: .utf8)!)
            }
            let malformed = directory.appendingPathComponent("malformed")
            try Data("Not a media file".utf8).write(to: malformed)
            for kind in [FeedMediaPreviewKind.image, .video, .pdf] {
                for (label, url) in [("missing", directory.appendingPathComponent("missing")), ("malformed", malformed)] {
                    let data = await FeedMediaPreviewRenderer.previewData(fileURLString: url.absoluteString, kind: kind)
                    assertions += 1
                    if data != nil { failures += 1 }
                    print("CASE " + kind.rawValue + " " + label + " " + (data == nil ? "PASS" : "FAIL"))
                }
            }
            print("RESULT assertions=" + String(assertions) + " failures=" + String(failures))
            exit(failures == 0 ? 0 : 1)
        } catch {
            print("FIXTURE_OR_DECODE_FAILURE " + String(describing: error))
            exit(2)
        }
    }
    private func makeFixtureDirectory() throws -> URL {
        // These files belong only to the running Simulator test app, not the user's media.
        let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
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
        try require(writer.canAdd(input))
        writer.add(input)
        try require(writer.startWriting())
        writer.startSession(atSourceTime: .zero)

        var buffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &buffer
        )
        try require(status == kCVReturnSuccess)
        let pixelBuffer = try require(buffer)
        try require(CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess)
        do {
            defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
            let base = try require(CVPixelBufferGetBaseAddress(pixelBuffer))
            base.initializeMemory(
                as: UInt8.self,
                repeating: 0,
                count: CVPixelBufferGetBytesPerRow(pixelBuffer) * height
            )
        }

        try require(input.isReadyForMoreMediaData)
        try require(adapter.append(pixelBuffer, withPresentationTime: .zero))
        input.markAsFinished()
        writer.endSession(atSourceTime: CMTime(value: 1, timescale: 30))
        await withCheckedContinuation { continuation in
            writer.finishWriting { continuation.resume() }
        }
        try require(writer.status == .completed)
    }
}
