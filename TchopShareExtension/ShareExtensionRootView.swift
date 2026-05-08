import SwiftUI
import TchopShareSupport

struct ShareExtensionImportSummary: Equatable {
    let textCount: Int
    let imageCount: Int
    let videoCount: Int
    let pdfCount: Int
    let audioCount: Int
    let fileCount: Int

    init(items: [ShareImportedItem]) {
        var textCount = 0
        var imageCount = 0
        var videoCount = 0
        var pdfCount = 0
        var audioCount = 0
        var fileCount = 0

        for item in items {
            switch item {
            case .text:
                textCount += 1
            case let .file(file):
                switch file.kind {
                case .image:
                    imageCount += 1
                case .video:
                    videoCount += 1
                case .pdf:
                    pdfCount += 1
                case .audio:
                    audioCount += 1
                case .file:
                    fileCount += 1
                }
            }
        }

        self.textCount = textCount
        self.imageCount = imageCount
        self.videoCount = videoCount
        self.pdfCount = pdfCount
        self.audioCount = audioCount
        self.fileCount = fileCount
    }
}

struct ShareExtensionRootView: View {
    enum State: Equatable {
        case loading
        case ready(summary: ShareExtensionImportSummary)
        case failed(message: String)
    }

    let state: State
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                switch state {
                case .loading:
                    ProgressView("Preparing share…")
                case let .ready(summary):
                    Text("Share extension scaffold is ready.")
                        .font(.headline)
                    ShareExtensionSummaryView(summary: summary)
                case let .failed(message):
                    Text(message)
                        .foregroundStyle(.red)
                }

                Spacer(minLength: 0)
            }
            .padding(20)
            .navigationTitle("Share")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
            }
        }
    }
}

private struct ShareExtensionSummaryView: View {
    let summary: ShareExtensionImportSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Imported content")
                .font(.subheadline.weight(.semibold))
            Text("Text: \(summary.textCount)")
            Text("Images: \(summary.imageCount)")
            Text("Video: \(summary.videoCount)")
            Text("PDF: \(summary.pdfCount)")
            Text("Audio: \(summary.audioCount)")
            Text("Other files: \(summary.fileCount)")
        }
        .font(.body)
    }
}
