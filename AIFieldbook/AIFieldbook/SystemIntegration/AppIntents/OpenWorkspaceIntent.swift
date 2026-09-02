import AppIntents
import Foundation
import UIKit

/// Opens one selected workspace through the app's validated deep-link boundary.
@available(iOS 26.0, *)
struct OpenWorkspaceIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Workspace"
    static let description = IntentDescription("Open a workspace in AI Fieldbook.")
    static let supportedModes: IntentModes = .foreground(.immediate)
    static let isDiscoverable = true

    @Parameter(title: "Workspace")
    var workspace: WorkspaceEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$workspace)")
    }

    init() {}

    func perform() async throws -> some IntentResult {
        try Task.checkCancellation()

        let source = try await FieldbookIntentDataSourceProvider.source()
        guard try await source.workspaces(with: [workspace.id]).first != nil else {
            throw WorkspaceIntentError.workspaceUnavailable
        }
        guard let url = workspaceURL else {
            throw WorkspaceIntentError.openFailed
        }
        guard await openWorkspace(url) else {
            throw WorkspaceIntentError.openFailed
        }

        return .result()
    }

    private var workspaceURL: URL? {
        var components = URLComponents()
        components.scheme = "aifieldbook"
        components.host = "workspace"
        components.path = "/\(workspace.id.uuidString)"
        return components.url
    }

    @MainActor
    private func openWorkspace(_ url: URL) async -> Bool {
        await UIApplication.shared.open(url)
    }
}

/// Registers AI Fieldbook as a Shortcuts app and exposes the workspace-opening action.
///
/// The action intentionally leaves workspace selection to the system parameter UI. It does
/// not donate user-specific shortcuts or expose additional workspace metadata.
@available(iOS 26.0, *)
struct AIFieldbookShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenWorkspaceIntent(),
            phrases: [
                "Open a workspace in \(.applicationName)",
                "Open \(.applicationName)"
            ],
            shortTitle: "Open Workspace",
            systemImageName: "square.grid.2x2"
        )
    }
}

private enum WorkspaceIntentError: LocalizedError {
    case workspaceUnavailable
    case openFailed

    var errorDescription: String? {
        switch self {
        case .workspaceUnavailable:
            String(localized: "The selected workspace no longer exists.")
        case .openFailed:
            String(localized: "AI Fieldbook couldn’t open the selected workspace.")
        }
    }
}
