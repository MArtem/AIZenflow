import AVFoundation
import ImageIO
import Observation
import QuickLook
import SwiftUI

struct ImportItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ImportItemViewModel
    @State private var showsFileImporter = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Destination") {
                    Picker("Workspace", selection: $viewModel.selectedWorkspaceID) {
                        Text(String(localized: "Choose a Workspace")).tag(UUID?.none)
                        ForEach(viewModel.workspaces) { workspace in
                            Text(workspace.name).tag(Optional(workspace.id))
                        }
                    }
                }

                Section("Import") {
                    Button("Choose \(viewModel.kind.title)", systemImage: "folder") {
                        showsFileImporter = true
                    }
                    .disabled(!viewModel.canChooseFile)

                    ImportLimitDescription(kind: viewModel.kind)
                }

                if viewModel.isImporting {
                    Section {
                        ProgressView("Validating and Copying")
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(FieldbookColor.destructive)
                            .accessibilityLabel("Error: \(errorMessage)")
                    }
                }
            }
            .navigationTitle("Import \(viewModel.kind.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isImporting)
                }
            }
            .fileImporter(
                isPresented: $showsFileImporter,
                allowedContentTypes: viewModel.kind.allowedContentTypes,
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case let .success(urls):
                    guard let url = urls.first else { return }
                    Task {
                        if await viewModel.fileSelected(url) {
                            dismiss()
                        }
                    }
                case .failure:
                    break
                }
            }
        }
        .interactiveDismissDisabled(viewModel.isImporting)
        .onAppear {
            viewModel.appeared()
        }
    }
}

private struct ImportLimitDescription: View {
    let kind: ImportKind

    var body: some View {
        Text(description)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private var description: String {
        switch kind {
        case .image:
            String(localized: "Images up to 25 MB and 20,000 pixels per side.")
        case .pdf:
            String(localized: "PDFs up to 50 MB and 500 pages.")
        case .plainTextDocument:
            String(localized: "UTF-8 plain-text files up to 10 MB.")
        case .audio:
            String(localized: "Playable audio up to 100 MB and four hours.")
        }
    }
}

struct ImportedItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ImportedItemDetailViewModel
    let manageTags: () -> Void
    let moveItem: () -> Void
    @State private var showsDeleteConfirmation = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.detail == nil {
                ProgressView("Loading Item")
            } else if let errorMessage = viewModel.errorMessage,
                      viewModel.detail == nil {
                ContentUnavailableView {
                    Label("Item Unavailable", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try Again") {
                        Task { await viewModel.reloadRequested() }
                    }
                }
            } else if let detail = viewModel.detail, let fileURL = viewModel.fileURL {
                ScrollView {
                    VStack(alignment: .leading, spacing: FieldbookSpacing.section) {
                        ImportedContentPreview(
                            detail: detail,
                            fileURL: fileURL,
                            playbackModel: viewModel.playbackModel
                        )

                        if !detail.tags.isEmpty {
                            TagListView(tags: detail.tags)
                        }

                        ImportedMetadataView(detail: detail)
                    }
                    .padding(FieldbookSpacing.standard)
                }
                .background(FieldbookColor.canvas)
            }
        }
        .navigationTitle(viewModel.detail?.displayTitle ?? String(localized: "Item"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Manage Tags", systemImage: "tag") {
                    manageTags()
                }
                Button("Move Item", systemImage: "folder", action: moveItem)
                if let fileURL = viewModel.fileURL { ShareLink(item: fileURL) { Label("Share", systemImage: "square.and.arrow.up") } }
                Button("Delete Item", systemImage: "trash", role: .destructive) {
                    showsDeleteConfirmation = true
                }
            }
        }
        .alert("Delete Item?", isPresented: $showsDeleteConfirmation) {
            Button("Delete Item", role: .destructive) {
                Task {
                    if await viewModel.deleteConfirmed() {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(String(localized: "This permanently deletes the item and its app-owned local file."))
        }
        .task {
            await viewModel.appeared()
        }
    }
}

private struct ImportedContentPreview: View {
    let detail: ImportedItemDetailState
    let fileURL: URL
    let playbackModel: AudioPlaybackModel

    var body: some View {
        switch detail.kind {
        case .image:
            DownsampledImageView(url: fileURL)
                .frame(maxWidth: .infinity, minHeight: 240)
        case .pdf:
            QuickLookPreviewView(url: fileURL)
                .frame(height: 520)
                .clipShape(.rect(cornerRadius: FieldbookRadius.card))
        case .plainTextDocument:
            QuickLookPreviewView(url: fileURL)
                .frame(height: 520)
                .clipShape(.rect(cornerRadius: FieldbookRadius.card))
        case .audio:
            AudioPlaybackView(url: fileURL, model: playbackModel)
                .fieldbookCard()
        case .textNote:
            EmptyView()
        case .urlReference:
            EmptyView()
        }
    }
}

private struct ImportedMetadataView: View {
    let detail: ImportedItemDetailState

    var body: some View {
        VStack(alignment: .leading, spacing: FieldbookSpacing.compact) {
            Label(detail.kind.displayName, systemImage: detail.kind.systemImage)
            Text(detail.originalFilename)
                .textSelection(.enabled)
            Text(ByteCountFormatter.string(fromByteCount: detail.byteCount, countStyle: .file))
                .foregroundStyle(.secondary)

            if let width = detail.pixelWidth, let height = detail.pixelHeight {
                Text(
                    String.localizedStringWithFormat(
                        String(localized: "%lld × %lld pixels"),
                        width,
                        height
                    )
                )
                    .foregroundStyle(.secondary)
            }
            if let pageCount = detail.pageCount {
                Text(
                    String.localizedStringWithFormat(
                        String(localized: "%lld pages"),
                        pageCount
                    )
                )
                    .foregroundStyle(.secondary)
            }
            if let duration = detail.durationSeconds {
                Text(Duration.seconds(duration).formatted(.time(pattern: .minuteSecond)))
                    .foregroundStyle(.secondary)
            }
        }
        .font(FieldbookTypography.supporting)
        .fieldbookCard()
        .accessibilityElement(children: .combine)
    }
}

private actor ImageDownsampler {
    static let shared = ImageDownsampler()

    func image(at url: URL, maximumPixelSize: Int = 1_600) -> CGImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
            return nil
        }
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true
        ] as CFDictionary
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options)
    }
}

private struct DownsampledImageView: View {
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

private struct QuickLookPreviewView: UIViewControllerRepresentable {
    let url: URL

    /// Presents app-owned imported files through Quick Look.
    ///
    /// Rationale:
    /// Quick Look avoids constructing heavyweight PDF/media documents synchronously during
    /// SwiftUI update passes. The file URL must already point to durable app-owned storage.
    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: QLPreviewController, context: Context) {
        context.coordinator.url = url
        controller.reloadData()
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        var url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> any QLPreviewItem {
            url as NSURL
        }
    }
}

@Observable
@MainActor
final class AudioPlaybackModel {
    private var player: AVAudioPlayer?
    private var timer: Timer?

    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    private(set) var errorMessage: String?

    func prepare(url: URL) {
        guard player == nil else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            self.player = player
            duration = player.duration
        } catch {
            errorMessage = String(localized: "The audio player couldn’t be prepared.")
        }
    }

    func playPauseTapped() {
        guard let player else { return }
        if player.isPlaying {
            player.pause()
            stopTimer()
        } else {
            player.play()
            startTimer()
        }
        isPlaying = player.isPlaying
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }

    func stopped() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let player = self.player else { return }
                self.currentTime = player.currentTime
                self.isPlaying = player.isPlaying
                if !player.isPlaying {
                    self.stopTimer()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

private struct AudioPlaybackView: View {
    let url: URL
    @Bindable var model: AudioPlaybackModel

    var body: some View {
        VStack(alignment: .leading, spacing: FieldbookSpacing.standard) {
            Button(
                model.isPlaying ? "Pause" : "Play",
                systemImage: model.isPlaying ? "pause.fill" : "play.fill"
            ) {
                model.playPauseTapped()
            }
            .buttonStyle(.borderedProminent)

            Slider(
                value: Binding(
                    get: { model.currentTime },
                    set: { model.seek(to: $0) }
                ),
                in: 0...max(model.duration, 0.01)
            ) {
                Text(String(localized: "Playback Position"))
            }

            HStack {
                Text(Duration.seconds(model.currentTime).formatted(.time(pattern: .minuteSecond)))
                Spacer()
                Text(Duration.seconds(model.duration).formatted(.time(pattern: .minuteSecond)))
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)

            if let errorMessage = model.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(FieldbookColor.destructive)
            }
        }
        .onAppear {
            model.prepare(url: url)
        }
        .onDisappear {
            model.stopped()
        }
    }
}
