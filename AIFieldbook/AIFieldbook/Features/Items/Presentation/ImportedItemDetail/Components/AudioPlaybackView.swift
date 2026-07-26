import SwiftUI

/// Playback controls for an imported audio item.
///
/// The view owns no `AVPlayer`; it binds only to `AudioPlaybackModel` state and intents.
struct AudioPlaybackView: View {
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
            .disabled(model.isPreparing || model.duration <= 0)

            if model.isPreparing {
                ProgressView("Preparing Audio")
            }

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
        .task(id: url) {
            await model.prepare(url: url)
        }
        .onDisappear {
            model.releaseResources()
        }
    }
}
