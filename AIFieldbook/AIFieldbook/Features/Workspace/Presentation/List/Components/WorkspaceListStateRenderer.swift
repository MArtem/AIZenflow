import SwiftUI

/// Selects the Workspace List surface for one explicit render state.
struct WorkspaceListStateRenderer: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: WorkspaceListViewState
    let createWorkspace: () -> Void
    let openWorkspace: (UUID) -> Void
    let reload: () -> Void

    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView("Loading Workspaces")
            case let .unavailable(unavailable):
                accessibilityOverflowContainer {
                    ContentUnavailableView {
                        Label("Workspaces Unavailable", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(unavailable.message)
                    } actions: {
                        Button("Try Again", action: reload)
                    }
                }
            case .empty:
                accessibilityOverflowContainer {
                    ContentUnavailableView {
                        Label("No Workspaces", systemImage: "square.grid.2x2")
                    } description: {
                        Text(String(localized: "Create a local workspace to organize your notes."))
                    } actions: {
                        Button("Create Workspace", action: createWorkspace)
                            .buttonStyle(.borderedProminent)
                    }
                }
            case let .content(content):
                List(content.rows) { row in
                    Button {
                        openWorkspace(row.id)
                    } label: {
                        WorkspaceListRow(row: row)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
                .refreshable {
                    reload()
                }
            }
        }
    }

    @ViewBuilder
    private func accessibilityOverflowContainer<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView {
                content()
                    .frame(maxWidth: .infinity)
                    .safeAreaPadding(.bottom)
            }
        } else {
            content()
        }
    }
}
