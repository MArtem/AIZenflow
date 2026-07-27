import AVFoundation
import Foundation
import Observation

/// Owns audio playback state for an imported local audio file.
///
/// Created by `ImportedItemDetailViewModel` and reused while that detail model is alive. The
/// model holds a streaming `AVPlayer` and bounded UI timer; callers release resources when the
/// containing view disappears or its cached detail model is evicted.
@Observable
@MainActor
final class AudioPlaybackModel {
    private var player: AVPlayer?
    private var timer: Timer?
    private var preparedURL: URL?

    private(set) var isPlaying = false
    private(set) var isPreparing = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    private(set) var errorMessage: String?

    func prepare(url: URL) async {
        guard preparedURL != url || player == nil else { return }
        releaseResources()
        isPreparing = true
        errorMessage = nil
        defer { isPreparing = false }

        do {
            let asset = AVURLAsset(url: url)
            let isPlayable = try await asset.load(.isPlayable)
            let loadedDuration = try await asset.load(.duration).seconds
            try Task.checkCancellation()
            guard isPlayable, loadedDuration.isFinite, loadedDuration > 0 else {
                throw AppFileStoreError.audioNotPlayable
            }
            player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            preparedURL = url
            duration = loadedDuration
        } catch {
            guard !(error is CancellationError) else { return }
            errorMessage = String(localized: "The audio player couldn’t be prepared.")
        }
    }

    func playPauseTapped() {
        guard let player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
            stopTimer()
        } else {
            if currentTime >= duration {
                seek(to: 0)
            }
            player.play()
            isPlaying = true
            startTimer()
        }
    }

    func seek(to time: TimeInterval) {
        let boundedTime = min(max(time, 0), duration)
        player?.seek(
            to: CMTime(seconds: boundedTime, preferredTimescale: 600),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
        currentTime = boundedTime
    }

    func releaseResources() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        preparedURL = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        stopTimer()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let player = self.player else { return }
                let seconds = player.currentTime().seconds
                if seconds.isFinite {
                    self.currentTime = min(max(seconds, 0), self.duration)
                }
                let playbackActive = player.rate > 0 || player.timeControlStatus == .waitingToPlayAtSpecifiedRate
                self.isPlaying = playbackActive
                if !playbackActive, self.currentTime >= max(self.duration - 0.1, 0) {
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
