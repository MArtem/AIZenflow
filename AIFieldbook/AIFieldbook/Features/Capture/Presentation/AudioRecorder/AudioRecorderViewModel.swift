import AVFoundation
import Foundation
import Observation
import SwiftUI

/// Owns microphone permission, recorder/session resources, draft cleanup, and save rollback.
///
/// Created by `AppComposition` for one record-audio sheet. `runtimeStatus` describes the media
/// lifecycle; `state` is the independent render-ready contract exposed to SwiftUI.
@MainActor
@Observable
final class AudioRecorderViewModel {
    private let repository: FieldbookRepository
    private let fileStore: AppFileStore
    private let stateBuilder: AudioRecorderViewStateBuilder
    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var draftURL: URL?
    private var didFinish = false
    private var selectedWorkspaceID: UUID?
    private var title = ""
    private var workspaces: [WorkspaceSummary] = []
    private var runtimeStatus: AudioRecorderRuntimeStatus = .idle
    private var duration: TimeInterval = 0
    private var errorMessage: String?
    @ObservationIgnored private var interruptionObserver: NSObjectProtocol?
    @ObservationIgnored private var routeChangeObserver: NSObjectProtocol?

    private(set) var state: AudioRecorderViewState

    init(
        repository: FieldbookRepository,
        fileStore: AppFileStore,
        stateBuilder: AudioRecorderViewStateBuilder = AudioRecorderViewStateBuilder()
    ) {
        self.repository = repository
        self.fileStore = fileStore
        self.stateBuilder = stateBuilder
        self.state = stateBuilder.loading()
    }

    func appeared() {
        guard state == .loading else { return }
        startObservingAudioSession()
        do {
            workspaces = try repository.fetchWorkspaces()
            selectedWorkspaceID = selectedWorkspaceID ?? workspaces.first?.id
            state = displayState()
        } catch {
            runtimeStatus = .unavailable
            errorMessage = String(localized: "Workspaces couldn’t be loaded.")
            state = displayState()
        }
    }

    func destinationChanged(_ workspaceID: UUID?) {
        selectedWorkspaceID = workspaceID
        state = displayState()
    }

    func titleChanged(_ title: String) {
        self.title = title
        state = displayState()
    }

    func recordTapped() async {
        guard runtimeStatus != .requestingPermission, runtimeStatus != .saving else { return }
        if runtimeStatus == .recording {
            stopRecording()
            return
        }

        if let draftURL {
            await fileStore.discardRecordingDraft(at: draftURL)
            self.draftURL = nil
            duration = 0
        }
        errorMessage = nil
        runtimeStatus = .requestingPermission
        state = displayState()

        let granted = await AVAudioApplication.requestRecordPermission()
        guard granted else {
            runtimeStatus = .permissionDenied
            state = displayState()
            return
        }

        var preparedDraftURL: URL?
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .spokenAudio)
            try session.setActive(true)
            let url = try await fileStore.prepareRecordingDraft()
            preparedDraftURL = url
            draftURL = url
            let recorder = try AVAudioRecorder(
                url: url,
                settings: [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44_100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
            )
            guard recorder.record() else { throw CocoaError(.fileWriteUnknown) }
            self.recorder = recorder
            duration = 0
            runtimeStatus = .recording
            state = displayState()
            startTimer()
        } catch {
            recorder = nil
            stopTimer()
            if let preparedDraftURL {
                await fileStore.discardRecordingDraft(at: preparedDraftURL)
            }
            draftURL = nil
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            runtimeStatus = .unavailable
            errorMessage = String(localized: "Audio recording isn’t available right now.")
            state = displayState()
        }
    }

    func saveTapped() async -> Bool {
        guard let workspaceID = selectedWorkspaceID, let draftURL else { return false }
        runtimeStatus = .saving
        errorMessage = nil
        state = displayState()

        do {
            let metadata = try await fileStore.importFile(at: draftURL, kind: .audio)
            do {
                try repository.createImportedItem(
                    workspaceID: workspaceID,
                    kind: .audio,
                    metadata: metadata,
                    title: title
                )
                await fileStore.discardRecordingDraft(at: draftURL)
                self.draftURL = nil
                didFinish = true
                stopObservingAudioSession()
                return true
            } catch {
                try? await fileStore.remove(metadata.reference)
                throw error
            }
        } catch {
            runtimeStatus = .recorded
            errorMessage = String(localized: "The recording couldn’t be saved.")
            state = displayState()
            return false
        }
    }

    func cancelled() async {
        stopObservingAudioSession()
        guard !didFinish else { return }
        stopRecording()
        if let draftURL {
            await fileStore.discardRecordingDraft(at: draftURL)
        }
        draftURL = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Stops recording when the scene can no longer safely own foreground audio capture.
    func scenePhaseChanged(_ phase: ScenePhase) {
        guard phase != .active, runtimeStatus == .recording else { return }
        stopRecording(
            errorMessage: String(localized: "Recording stopped because AI Fieldbook left the foreground.")
        )
    }

    private func stopRecording(errorMessage: String? = nil) {
        recorder?.stop()
        duration = recorder?.currentTime ?? duration
        recorder = nil
        stopTimer()
        runtimeStatus = duration > 0 ? .recorded : .idle
        self.errorMessage = errorMessage
        state = displayState()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                duration = recorder?.currentTime ?? 0
                state = displayState()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startObservingAudioSession() {
        guard interruptionObserver == nil, routeChangeObserver == nil else { return }
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            let rawValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
            Task { @MainActor [weak self] in
                guard rawValue.flatMap(AVAudioSession.InterruptionType.init(rawValue:)) == .began,
                      self?.runtimeStatus == .recording else { return }
                self?.stopRecording(
                    errorMessage: String(localized: "Recording stopped because the audio session was interrupted.")
                )
            }
        }
        routeChangeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            let rawValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt
            Task { @MainActor [weak self] in
                guard rawValue.flatMap(AVAudioSession.RouteChangeReason.init(rawValue:)) == .oldDeviceUnavailable,
                      self?.runtimeStatus == .recording else { return }
                self?.stopRecording(
                    errorMessage: String(localized: "Recording stopped because the audio input changed.")
                )
            }
        }
    }

    private func stopObservingAudioSession() {
        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
            self.interruptionObserver = nil
        }
        if let routeChangeObserver {
            NotificationCenter.default.removeObserver(routeChangeObserver)
            self.routeChangeObserver = nil
        }
    }

    private func displayState() -> AudioRecorderViewState {
        stateBuilder.state(
            status: runtimeStatus,
            form: stateBuilder.form(
                status: runtimeStatus,
                selectedWorkspaceID: selectedWorkspaceID,
                workspaces: workspaces,
                title: title,
                duration: duration
            ),
            errorMessage: errorMessage
        )
    }
}
