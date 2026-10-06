import Foundation
import AVFoundation
import ImageIO
import UniformTypeIdentifiers

@main struct Frames {
    static func main() async throws {
        let asset = AVURLAsset(url: URL(fileURLWithPath: CommandLine.arguments[1]))
        let duration = try await asset.load(.duration).seconds
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        for offset in [1.0, 3.0, 6.0] {
            let time = CMTime(seconds: max(0, duration - offset), preferredTimescale: 600)
            let frame = try await generator.image(at: time).image
            let output = URL(fileURLWithPath: CommandLine.arguments[2] + "/frame-" + String(Int(offset)) + ".png")
            guard let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil) else { throw CocoaError(.fileWriteUnknown) }
            CGImageDestinationAddImage(destination, frame, nil)
            guard CGImageDestinationFinalize(destination) else { throw CocoaError(.fileWriteUnknown) }
            print(output.path)
        }
    }
}
