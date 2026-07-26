import Foundation

/// Pure mapper from recorder runtime values into the screen render contract.
struct AudioRecorderViewStateBuilder {
    func loading() -> AudioRecorderViewState {
        .loading
    }

    func state(
        status: AudioRecorderRuntimeStatus,
        form: AudioRecorderFormState,
        errorMessage: String?
    ) -> AudioRecorderViewState {
        if let errorMessage {
            return .failure(form: form, message: errorMessage)
        }

        switch status {
        case .idle:
            return .ready(form)
        case .requestingPermission:
            return .requestingPermission(form)
        case .recording:
            return .recording(form)
        case .recorded:
            return .recorded(form)
        case .saving:
            return .saving(form)
        case .permissionDenied:
            return .permissionDenied(form)
        case .unavailable:
            return .failure(
                form: form,
                message: String(localized: "Audio recording isn’t available right now.")
            )
        }
    }

    func form(
        status: AudioRecorderRuntimeStatus,
        selectedWorkspaceID: UUID?,
        workspaces: [WorkspaceSummary],
        title: String,
        duration: TimeInterval
    ) -> AudioRecorderFormState {
        let isRecording = status == .recording
        return AudioRecorderFormState(
            selectedWorkspaceID: selectedWorkspaceID,
            workspaces: workspaces.map {
                AudioRecorderWorkspaceOptionState(id: $0.id, title: $0.name)
            },
            title: title,
            durationText: Duration.seconds(duration).formatted(.time(pattern: .minuteSecond)),
            recordButtonTitle: isRecording
                ? String(localized: "Stop Recording")
                : String(localized: "Start Recording"),
            recordButtonSystemImage: isRecording ? "stop.circle.fill" : "mic.circle.fill",
            isRecordButtonDisabled: status == .requestingPermission || status == .saving,
            canSave: status == .recorded && selectedWorkspaceID != nil && duration > 0
        )
    }
}
