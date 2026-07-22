import AppIntents
import Foundation
import SwiftData
import UIKit

/// Privacy-minimal, detached workspace value exposed to App Intents.
private struct WorkspaceIntentSnapshot: Sendable {
    let id: UUID
    let name: String
}

/// Read-only SwiftData boundary used by workspace App Intents.
///
/// The actor returns detached values only. Note bodies, attachment metadata, and live
/// SwiftData models never cross into the system integration layer.
@ModelActor
private actor WorkspaceIntentDataSource {
    private let maximumSuggestionCount = 20
    private let maximumNameSearchCount = 100

    func workspaces(with identifiers: [UUID]) throws -> [WorkspaceIntentSnapshot] {
        var snapshots: [WorkspaceIntentSnapshot] = []
        snapshots.reserveCapacity(identifiers.count)

        for identifier in identifiers {
            try Task.checkCancellation()
            var descriptor = FetchDescriptor<WorkspaceRecord>(
                predicate: #Predicate { $0.id == identifier }
            )
            descriptor.fetchLimit = 1

            if let workspace = try modelContext.fetch(descriptor).first {
                snapshots.append(snapshot(for: workspace))
            }
        }

        return snapshots
    }

    func workspaces(matching query: String) throws -> [WorkspaceIntentSnapshot] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return try suggestedWorkspaces()
        }

        var descriptor = FetchDescriptor<WorkspaceRecord>(
            sortBy: [SortDescriptor(\WorkspaceRecord.name)]
        )
        descriptor.fetchLimit = maximumNameSearchCount

        var snapshots: [WorkspaceIntentSnapshot] = []
        for workspace in try modelContext.fetch(descriptor) {
            try Task.checkCancellation()
            guard workspace.name.localizedStandardContains(trimmedQuery) else { continue }
            snapshots.append(snapshot(for: workspace))
            if snapshots.count == maximumSuggestionCount { break }
        }
        return snapshots
    }

    func suggestedWorkspaces() throws -> [WorkspaceIntentSnapshot] {
        var descriptor = FetchDescriptor<WorkspaceRecord>(
            sortBy: [SortDescriptor(\WorkspaceRecord.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = maximumSuggestionCount

        return try modelContext.fetch(descriptor).map(snapshot(for:))
    }

    private func snapshot(for workspace: WorkspaceRecord) -> WorkspaceIntentSnapshot {
        WorkspaceIntentSnapshot(id: workspace.id, name: workspace.name)
    }
}

/// Process-local source provider that reuses the app's cached SwiftData container.
@MainActor
private enum WorkspaceIntentDataSourceProvider {
    private static var cachedSource: WorkspaceIntentDataSource?

    static func source() throws -> WorkspaceIntentDataSource {
        if let cachedSource { return cachedSource }

        guard case let .ready(container) = PersistenceBootstrap.load() else {
            throw WorkspaceIntentError.persistenceUnavailable
        }

        let source = WorkspaceIntentDataSource(modelContainer: container)
        cachedSource = source
        return source
    }
}

private enum WorkspaceIntentError: LocalizedError {
    case persistenceUnavailable
    case workspaceUnavailable
    case openFailed

    var errorDescription: String? {
        switch self {
        case .persistenceUnavailable:
            String(localized: "Workspaces couldn’t be loaded.")
        case .workspaceUnavailable:
            String(localized: "The selected workspace no longer exists.")
        case .openFailed:
            String(localized: "AI Fieldbook couldn’t open the selected workspace.")
        }
    }
}

struct WorkspaceEntity: AppEntity {
    typealias ID = UUID

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Workspace")
    }

    static var defaultQuery: WorkspaceEntityQuery {
        WorkspaceEntityQuery()
    }

    let id: ID
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct WorkspaceEntityQuery: EntityStringQuery {
    init() {}

    func entities(for identifiers: [UUID]) async throws -> [WorkspaceEntity] {
        let source = try await WorkspaceIntentDataSourceProvider.source()
        return try await source.workspaces(with: identifiers).map {
            WorkspaceEntity(snapshot: $0)
        }
    }

    func entities(matching string: String) async throws -> [WorkspaceEntity] {
        let source = try await WorkspaceIntentDataSourceProvider.source()
        return try await source.workspaces(matching: string).map {
            WorkspaceEntity(snapshot: $0)
        }
    }

    func suggestedEntities() async throws -> [WorkspaceEntity] {
        let source = try await WorkspaceIntentDataSourceProvider.source()
        return try await source.suggestedWorkspaces().map {
            WorkspaceEntity(snapshot: $0)
        }
    }
}

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

        let source = try await WorkspaceIntentDataSourceProvider.source()
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

private extension WorkspaceEntity {
    init(snapshot: WorkspaceIntentSnapshot) {
        self.init(id: snapshot.id, name: snapshot.name)
    }
}
