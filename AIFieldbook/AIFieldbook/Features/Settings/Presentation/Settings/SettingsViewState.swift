import Foundation

/// Render-ready state for the app-lifetime Settings screen.
enum SettingsViewState: Equatable {
    case content(SettingsContentState)
    case working(SettingsContentState)
    case exportReady(SettingsContentState)
    case failure(content: SettingsContentState, message: String)
}

/// Values prepared for direct rendering by the passive Settings content view.
struct SettingsContentState: Equatable {
    let storageDescription: String
    let exportURL: URL?
    let areMutatingActionsDisabled: Bool
}
