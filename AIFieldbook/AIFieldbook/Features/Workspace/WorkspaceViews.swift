import SwiftUI

/// Workspace tab list UI.
///
/// Responsibilities:
/// - renders loading, empty, failure, and populated workspace states;
/// - forwards create/open intents to app composition;
/// - keeps row rendering value-based through `WorkspaceSummary`.
struct WorkspaceListView: View {
    @Bindable var viewModel: WorkspaceListViewModel
    let createWorkspace: () -> Void
    let openWorkspace: (UUID) -> Void

    var body: some View {
        Group {
                if viewModel.isLoading && viewModel.workspaces.isEmpty {
                    ProgressView("Loading Workspaces")
                } else if let errorMessage = viewModel.errorMessage,
                          viewModel.workspaces.isEmpty {
                    ContentUnavailableView {
                        Label("Workspaces Unavailable", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Try Again") {
                            viewModel.reloadRequested()
                        }
                    }
                } else if viewModel.workspaces.isEmpty {
                    ContentUnavailableView {
                        Label("No Workspaces", systemImage: "square.grid.2x2")
                    } description: {
                        Text(String(localized: "Create a local workspace to organize your notes."))
                    } actions: {
                        Button("Create Workspace") {
                            createWorkspace()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(viewModel.workspaces) { workspace in
                        Button {
                            openWorkspace(workspace.id)
                        } label: {
                            WorkspaceRow(workspace: workspace)
                        }
                        .buttonStyle(.plain)
                    }
                    .refreshable {
                        viewModel.reloadRequested()
                    }
                }
        }
            .navigationTitle("Workspace")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create Workspace", systemImage: "plus") {
                            createWorkspace()
                    }
                }
            }
        .onAppear {
            viewModel.appeared()
        }
    }
}

/// Lightweight row for a workspace summary.
///
/// Rendering contract:
/// Uses only immutable summary values so list rows do not observe broad feature state.
private struct WorkspaceRow: View {
    let workspace: WorkspaceSummary

    var body: some View {
        VStack(alignment: .leading, spacing: FieldbookSpacing.compact) {
            Text(workspace.name)
                .font(.headline)
            Text(
                String.localizedStringWithFormat(
                    String(localized: "%lld items"),
                    workspace.itemCount
                )
            )
                .font(FieldbookTypography.supporting)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Detail UI for one workspace and its local items.
///
/// The view owns only confirmation UI state. Data loading and destructive file/database
/// coordination belong to `WorkspaceDetailViewModel`.
struct WorkspaceDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: WorkspaceDetailViewModel
    let openItem: (UUID, KnowledgeItemKind) -> Void
    let createTextNote: () -> Void
    let renameWorkspace: (UUID, String) -> Void
    @State private var showsDeleteConfirmation = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.detail == nil {
                ProgressView("Loading Workspace")
            } else if let errorMessage = viewModel.errorMessage,
                      viewModel.detail == nil {
                ContentUnavailableView {
                    Label("Workspace Unavailable", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try Again") {
                        viewModel.reloadRequested()
                    }
                }
            } else if let detail = viewModel.detail {
                List {
                    Section("Items") {
                        if detail.items.isEmpty {
                            Text(String(localized: "No items yet."))
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(detail.items) { item in
                                Button {
                                    openItem(item.id, item.kind)
                                } label: {
                                    KnowledgeItemRow(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.detail?.name ?? String(localized: "Workspace"))
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("New Text Note", systemImage: "square.and.pencil") {
                    createTextNote()
                }

                Menu("Workspace Actions", systemImage: "ellipsis.circle") {
                    Button("Rename", systemImage: "pencil") {
                        if let detail = viewModel.detail {
                            renameWorkspace(detail.id, detail.name)
                        }
                    }
                    Button("Delete Workspace", systemImage: "trash", role: .destructive) {
                        showsDeleteConfirmation = true
                    }
                }
            }
        }
        .alert("Delete Workspace?", isPresented: $showsDeleteConfirmation) {
            Button("Delete Workspace", role: .destructive) {
                Task {
                    if await viewModel.deleteConfirmed() {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(String(localized: "This permanently deletes the workspace and every contained item."))
        }
        .alert(
            "Action Failed",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil && viewModel.detail != nil },
                set: { if !$0 { viewModel.reloadRequested() } }
            )
        ) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.appeared()
        }
    }
}

/// Shared row for local knowledge item summaries.
///
/// Rendering contract:
/// The row accepts a narrow immutable snapshot and performs no file, database, or media work.
struct KnowledgeItemRow: View {
    let item: KnowledgeItemSummary

    var body: some View {
        HStack(spacing: FieldbookSpacing.standard) {
            Image(systemName: item.kind.systemImage)
                .font(.title3)
                .frame(width: 32)
                .foregroundStyle(FieldbookColor.accent)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: FieldbookSpacing.compact) {
                Text(item.displayTitle)
                    .font(.headline)
                Text(item.subtitle)
                    .font(FieldbookTypography.supporting)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(item.updatedAt, format: .dateTime.month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Sheet UI for creating or renaming a workspace.
///
/// Durable state changes are delegated to `WorkspaceEditorViewModel`; the view owns only focus
/// and discard-confirmation state.
struct WorkspaceEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: WorkspaceEditorViewModel
    @State private var showsDiscardConfirmation = false
    @FocusState private var nameIsFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Workspace Name") {
                    TextField("Name", text: $viewModel.name)
                        .focused($nameIsFocused)
                        .submitLabel(.done)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(FieldbookColor.destructive)
                            .accessibilityLabel("Error: \(errorMessage)")
                    }
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.hasUnsavedChanges {
                            showsDiscardConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.saveTapped() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                }
            }
            .confirmationDialog(
                "Discard Changes?",
                isPresented: $showsDiscardConfirmation,
                titleVisibility: .visible
            ) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            }
            .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
            .onAppear {
                nameIsFocused = true
            }
        }
    }
}
