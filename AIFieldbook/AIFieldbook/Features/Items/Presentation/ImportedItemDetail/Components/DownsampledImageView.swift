import SwiftUI

/// Displays an imported image from a bounded off-render-path decode.
struct DownsampledImageView: View {
    let url: URL
    @State private var image: CGImage?
    @State private var failed = false

    var body: some View {
        Group {
            if let image {
                Image(image, scale: 1, label: Text(String(localized: "Imported Image")))
                    .resizable()
                    .scaledToFit()
            } else if failed {
                ContentUnavailableView(
                    "Image Unavailable",
                    systemImage: "photo.badge.exclamationmark",
                    description: Text(String(localized: "The local image couldn’t be decoded."))
                )
            } else {
                ProgressView("Loading Image")
            }
        }
        .task(id: url) {
            failed = false
            image = nil
            let loadedImage = await ImageDownsampler.shared.image(at: url)
            guard !Task.isCancelled else { return }
            image = loadedImage
            failed = loadedImage == nil
        }
    }
}
