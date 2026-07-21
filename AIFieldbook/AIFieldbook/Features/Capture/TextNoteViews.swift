import SwiftUI

/// Capture tab entry screen for manually creating local content.
///
/// Responsibilities:
/// - gates capture actions behind workspace availability;
/// - forwards create/import/record intents to app composition;
/// - renders loading, empty, and failure states from the workspace model.
struct CaptureView: View {
    @Bindable var workspaceModel: WorkspaceListViewModel
    let createTextNote: () -> Void
    let importItem: (ImportKind) -> Void
    let createURLReference: () -> Void
    let recordAudio: () -> Void

    var body: some View {
        Group {
                if workspaceModel.isLoading && workspaceModel.workspaces.isEmpty {
                    ProgressView("Loading Capture Options")
                } else if let errorMessage = workspaceModel.errorMessage,
                          workspaceModel.workspaces.isEmpty {
                    ContentUnavailableView {
                        Label("Capture Unavailable", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Try Again") {
                            workspaceModel.reloadRequested()
                        }
                    }
                } else if workspaceModel.workspaces.isEmpty {
                    ContentUnavailableView(
                        "Create a Workspace First",
                        systemImage: "square.grid.2x2",
                        description: Text(String(localized: "Every note belongs to a local workspace. Create one from the Workspace tab."))
                    )
                } else {
                    List {
                        Section("Available Now") {
                            Button {
                                createTextNote()
                            } label: {
                                Label("New Text Note", systemImage: "square.and.pencil")
                            }

                            Button {
                                createURLReference()
                            } label: {
                                Label("New Web Link", systemImage: "link.badge.plus")
                            }

                            Button {
                                recordAudio()
                            } label: {
                                Label("Record Audio", systemImage: "mic.circle")
                            }

                            ForEach(ImportKind.allCases) { kind in
                                Button {
                                    importItem(kind)
                                } label: {
                                    Label("Import \(kind.title)", systemImage: kind.systemImage)
                                }
                            }
                        }
                    }
                }
        }
        .navigationTitle("Capture")
        .onAppear {
            workspaceModel.appeared()
        }
    }
}

/// Form UI for creating or editing a text note.
///
/// The view owns only transient focus/discard-confirmation UI state. Durable form state and
/// persistence side effects belong to `TextNoteEditorViewModel`.
struct TextNoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TextNoteEditorViewModel
    @State private var showsDiscardConfirmation = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case title
        case body
    }

    var body: some View {
        NavigationStack {
            Form {
                if viewModel.showsWorkspacePicker {
                    Section("Workspace") {
                        Picker("Workspace", selection: $viewModel.selectedWorkspaceID) {
                            Text(String(localized: "Choose a Workspace")).tag(UUID?.none)
                            ForEach(viewModel.workspaces) { workspace in
                                Text(workspace.name).tag(Optional(workspace.id))
                            }
                        }
                    }
                }

                Section("Note") {
                    TextField("Title", text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .body
                        }

                    TextEditor(text: $viewModel.body)
                        .focused($focusedField, equals: .body)
                        .frame(minHeight: 220)
                        .accessibilityLabel("Note Text")
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
                viewModel.appeared()
                focusedField = .title
            }
        }
    }
}

/// Detail UI for a locally stored text note.
///
/// The view renders repository snapshots and forwards edit/tag/delete intents upward; it does
/// not hold SwiftData records or perform persistence itself.
struct TextNoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TextNoteDetailViewModel
    let editNote: () -> Void
    let manageTags: () -> Void
    let moveItem: () -> Void
    @State private var showsDeleteConfirmation = false

    var body: some View {
        Group {
            if let detail = viewModel.detail {
                ScrollView {
                    VStack(alignment: .leading, spacing: FieldbookSpacing.section) {
                        Text(detail.body.isEmpty ? String(localized: "No note text.") : detail.body)
                            .font(FieldbookTypography.body)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if !detail.tags.isEmpty {
                            TagListView(tags: detail.tags)
                        }

                        Text(
                            String.localizedStringWithFormat(
                                String(localized: "Updated %@"),
                                detail.updatedAt.formatted(date: .abbreviated, time: .shortened)
                            )
                        )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(FieldbookSpacing.screen)
                }
                .background(FieldbookColor.canvas)
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView {
                    Label("Note Unavailable", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try Again") {
                        viewModel.reloadRequested()
                    }
                }
            } else {
                ProgressView("Loading Note")
            }
        }
        .navigationTitle(viewModel.detail?.displayTitle ?? String(localized: "Text Note"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit Note", systemImage: "pencil") {
                    editNote()
                }
                Button("Manage Tags", systemImage: "tag") {
                    manageTags()
                }
                Button("Move Note", systemImage: "folder") { moveItem() }
                if let detail = viewModel.detail {
                    ShareLink(item: detail.body, subject: Text(detail.displayTitle)) { Label("Share", systemImage: "square.and.arrow.up") }
                }
                Button("Delete Note", systemImage: "trash", role: .destructive) {
                    showsDeleteConfirmation = true
                }
            }
        }
        .alert("Delete Note?", isPresented: $showsDeleteConfirmation) {
            Button("Delete Note", role: .destructive) {
                if viewModel.deleteConfirmed() {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(String(localized: "This permanently deletes the note."))
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
        .task(id: viewModel.noteID) {
            viewModel.appeared()
        }
    }
}
