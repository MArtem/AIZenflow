import Foundation

/// Runtime status owned by the audio recorder model.
///
/// This state describes the recorder/session lifecycle and is intentionally separate from the
/// render-ready screen state consumed by SwiftUI.
enum AudioRecorderRuntimeStatus: Equatable {
    case idle
    case requestingPermission
    case recording
    case recorded
    case saving
    case permissionDenied
    case unavailable
}

/// Render-ready state for one audio-recording sheet.
enum AudioRecorderViewState: Equatable {
    case loading
    case ready(AudioRecorderFormState)
    case requestingPermission(AudioRecorderFormState)
    case recording(AudioRecorderFormState)
    case recorded(AudioRecorderFormState)
    case saving(AudioRecorderFormState)
    case permissionDenied(AudioRecorderFormState)
    case failure(form: AudioRecorderFormState, message: String)

    var form: AudioRecorderFormState? {
        switch self {
        case .loading:
            nil
        case let .ready(form),
             let .requestingPermission(form),
             let .recording(form),
             let .recorded(form),
             let .saving(form),
             let .permissionDenied(form),
             let .failure(form, _):
            form
        }
    }

    var canSave: Bool {
        form?.canSave == true
    }
}

struct AudioRecorderFormState: Equatable {
    static let empty = AudioRecorderFormState(
        selectedWorkspaceID: nil,
        workspaces: [],
        title: "",
        durationText: Duration.seconds(0).formatted(.time(pattern: .minuteSecond)),
        recordButtonTitle: String(localized: "Start Recording"),
        recordButtonSystemImage: "mic.circle.fill",
        isRecordButtonDisabled: true,
        canSave: false
    )

    let selectedWorkspaceID: UUID?
    let workspaces: [AudioRecorderWorkspaceOptionState]
    let title: String
    let durationText: String
    let recordButtonTitle: String
    let recordButtonSystemImage: String
    let isRecordButtonDisabled: Bool
    let canSave: Bool
}

struct AudioRecorderWorkspaceOptionState: Identifiable, Equatable {
    let id: UUID
    let title: String
}
