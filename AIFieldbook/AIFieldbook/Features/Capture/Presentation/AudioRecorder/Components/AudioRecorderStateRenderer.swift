import SwiftUI

/// Selects the recorder surface for one explicit screen state.
struct AudioRecorderStateRenderer: View {
    let state: AudioRecorderViewState
    @Binding var selectedWorkspaceID: UUID?
    @Binding var title: String
    let record: () -> Void
    let openSettings: () -> Void

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Record Audio")
        case let .ready(form),
             let .requestingPermission(form),
             let .recording(form),
             let .recorded(form),
             let .saving(form):
            AudioRecorderFormView(
                form: form,
                selectedWorkspaceID: $selectedWorkspaceID,
                title: $title,
                errorMessage: nil,
                showsPermissionRecovery: false,
                record: record,
                openSettings: openSettings
            )
        case let .permissionDenied(form):
            AudioRecorderFormView(
                form: form,
                selectedWorkspaceID: $selectedWorkspaceID,
                title: $title,
                errorMessage: nil,
                showsPermissionRecovery: true,
                record: record,
                openSettings: openSettings
            )
        case let .failure(form, message):
            AudioRecorderFormView(
                form: form,
                selectedWorkspaceID: $selectedWorkspaceID,
                title: $title,
                errorMessage: message,
                showsPermissionRecovery: false,
                record: record,
                openSettings: openSettings
            )
        }
    }
}
