import AVFoundation
import Foundation
import Observation
import SwiftUI

/// Owns microphone permission, recording session, and save flow for local audio notes.
///
/// Ownership:
/// Created by `AppComposition` for the record-audio sheet. One instance owns one draft
/// recording lifecycle.
///
/// Side effects:
/// Requests microphone permission, activates `AVAudioSession`, creates a temporary recording
/// draft through `AppFileStore`, and persists the final imported audio item through the
/// repository only after validation/copy succeeds.
///
/// Cancellation:
/// `cancelled()` must be called by dismiss flows that abandon the sheet so temporary audio
/// drafts and active audio sessions do not outlive the UI.
@MainActor
@Observable
final class AudioRecorderViewModel {
    enum State: Equatable {
        case idle
        case requestingPermission
        case recording
        case recorded
        case saving
        case permissionDenied
        case unavailable
    }

    private let repository: FieldbookRepository
    private let fileStore: AppFileStore
    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var draftURL: URL?
    private var didFinish = false
    @ObservationIgnored private var interruptionObserver: NSObjectProtocol?
    @ObservationIgnored private var routeChangeObserver: NSObjectProtocol?

    var selectedWorkspaceID: UUID?
    var title = ""
    private(set) var workspaces: [WorkspaceSummary] = []
    private(set) var state: State = .idle
    private(set) var duration: TimeInterval = 0
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository, fileStore: AppFileStore) {
        self.repository = repository
        self.fileStore = fileStore
    }

    var canSave: Bool { state == .recorded && selectedWorkspaceID != nil && duration > 0 }

    func appeared() {
        startObservingAudioSession()
        do {
            workspaces = try repository.fetchWorkspaces()
            selectedWorkspaceID = selectedWorkspaceID ?? workspaces.first?.id
        } catch {
            state = .unavailable
            errorMessage = String(localized: "Workspaces couldn’t be loaded.")
        }
    }

    func recordTapped() async {
        if state == .recording {
            stopRecording()
            return
        }
        if let draftURL {
            await fileStore.discardRecordingDraft(at: draftURL)
            self.draftURL = nil
            duration = 0
        }
        errorMessage = nil
        state = .requestingPermission
        let granted = await AVAudioApplication.requestRecordPermission()
        guard granted else { state = .permissionDenied; return }
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
            state = .recording
            startTimer()
        } catch {
            recorder = nil
            stopTimer()
            if let preparedDraftURL {
                await fileStore.discardRecordingDraft(at: preparedDraftURL)
            }
            draftURL = nil
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            state = .unavailable
            errorMessage = String(localized: "Audio recording isn’t available right now.")
        }
    }

    func saveTapped() async -> Bool {
        guard let workspaceID = selectedWorkspaceID, let draftURL else { return false }
        state = .saving
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
            state = .recorded
            errorMessage = String(localized: "The recording couldn’t be saved.")
            return false
        }
    }

    func cancelled() async {
        stopObservingAudioSession()
        guard !didFinish else { return }
        stopRecording()
        if let draftURL { await fileStore.discardRecordingDraft(at: draftURL) }
        draftURL = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Stops recording when the scene can no longer safely own foreground audio capture.
    func scenePhaseChanged(_ phase: ScenePhase) {
        guard phase != .active, state == .recording else { return }
        stopRecording()
        errorMessage = String(localized: "Recording stopped because AI Fieldbook left the foreground.")
    }

    private func stopRecording() {
        recorder?.stop()
        duration = recorder?.currentTime ?? duration
        recorder = nil
        stopTimer()
        state = duration > 0 ? .recorded : .idle
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.duration = self?.recorder?.currentTime ?? 0 }
        }
    }

    private func stopTimer() { timer?.invalidate(); timer = nil }

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
                      self?.state == .recording else { return }
                self?.stopRecording()
                self?.errorMessage = String(localized: "Recording stopped because the audio session was interrupted.")
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
                      self?.state == .recording else { return }
                self?.stopRecording()
                self?.errorMessage = String(localized: "Recording stopped because the audio input changed.")
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
}

/// Sheet UI for a single local audio recording flow.
///
/// The view owns no audio resources directly; it forwards user intents to
/// `AudioRecorderViewModel` and calls cleanup on cancellation.
struct AudioRecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var viewModel: AudioRecorderViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Destination") {
                    Picker("Workspace", selection: $viewModel.selectedWorkspaceID) {
                        Text(String(localized: "Choose a Workspace")).tag(UUID?.none)
                        ForEach(viewModel.workspaces) { Text($0.name).tag(Optional($0.id)) }
                    }
                    TextField("Title (optional)", text: $viewModel.title)
                }
                Section("Recorder") {
                    Text(Duration.seconds(viewModel.duration).formatted(.time(pattern: .minuteSecond)))
                        .font(.title.monospacedDigit())
                        .frame(maxWidth: .infinity)
                    Button(viewModel.state == .recording ? "Stop Recording" : "Start Recording", systemImage: viewModel.state == .recording ? "stop.circle.fill" : "mic.circle.fill") {
                        Task { await viewModel.recordTapped() }
                    }
                    .disabled(viewModel.state == .requestingPermission || viewModel.state == .saving)
                }
                if viewModel.state == .permissionDenied {
                    Section("Microphone Permission") {
                        Text(String(localized: "Allow microphone access in Settings to record audio."))
                        Button("Open Settings") { if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) } }
                    }
                }
                if let error = viewModel.errorMessage { Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(FieldbookColor.destructive) }
            }
            .navigationTitle("Record Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { Task { await viewModel.cancelled(); dismiss() } } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { Task { if await viewModel.saveTapped() { dismiss() } } }.disabled(!viewModel.canSave) }
            }
        }
        .onAppear { viewModel.appeared() }
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.scenePhaseChanged(newPhase)
        }
        .onDisappear { Task { await viewModel.cancelled() } }
    }
}
