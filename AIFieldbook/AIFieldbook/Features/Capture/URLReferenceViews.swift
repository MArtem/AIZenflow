import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class URLReferenceEditorViewModel {
    enum Mode {
        case create
        case edit(UUID)
    }

    private let repository: FieldbookRepository
    private let mode: Mode
    var selectedWorkspaceID: UUID?
    var title = ""
    var urlText = ""
    var notes = ""
    private(set) var workspaces: [WorkspaceSummary] = []
    private(set) var errorMessage: String?
    private(set) var isSaving = false

    init(repository: FieldbookRepository, mode: Mode) {
        self.repository = repository
        self.mode = mode
    }

    var navigationTitle: String {
        switch mode {
        case .create: String(localized: "New Web Link")
        case .edit: String(localized: "Edit Web Link")
        }
    }

    var canSave: Bool { normalizedURL != nil && selectedWorkspaceID != nil && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func appeared() {
        guard workspaces.isEmpty else { return }
        do {
            workspaces = try repository.fetchWorkspaces()
            switch mode {
            case .create:
                selectedWorkspaceID = workspaces.first?.id
            case let .edit(id):
                let detail = try repository.fetchURLReference(id: id)
                selectedWorkspaceID = detail.workspaceID
                title = detail.title
                urlText = detail.url.absoluteString
                notes = detail.notes
            }
        } catch {
            errorMessage = String(localized: "The web link editor couldn’t be loaded.")
        }
    }

    func saveTapped() -> Bool {
        guard let workspaceID = selectedWorkspaceID, let url = normalizedURL else {
            errorMessage = String(localized: "Enter a complete http or https address.")
            return false
        }
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            errorMessage = String(localized: "Enter a title.")
            return false
        }
        isSaving = true
        defer { isSaving = false }
        do {
            switch mode {
            case .create:
                try repository.createURLReference(workspaceID: workspaceID, title: cleanTitle, url: url, notes: notes)
            case let .edit(id):
                try repository.updateURLReference(id: id, title: cleanTitle, url: url, notes: notes)
            }
            return true
        } catch {
            errorMessage = String(localized: "The web link couldn’t be saved.")
            return false
        }
    }

    private var normalizedURL: URL? {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed),
              let scheme = components.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              components.host?.isEmpty == false else { return nil }
        components.scheme = scheme
        return components.url
    }
}

@MainActor
@Observable
final class URLReferenceDetailViewModel {
    private let repository: FieldbookRepository
    let itemID: UUID
    private(set) var detail: URLReferenceDetailState?
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository, itemID: UUID) {
        self.repository = repository
        self.itemID = itemID
    }

    func appeared() { reloadRequested() }

    func reloadRequested() {
        do { detail = try repository.fetchURLReference(id: itemID); errorMessage = nil }
        catch { detail = nil; errorMessage = String(localized: "This web link couldn’t be loaded.") }
    }

    func deleteConfirmed() -> Bool {
        do { try repository.deleteItem(id: itemID); return true }
        catch { errorMessage = String(localized: "The web link couldn’t be deleted."); return false }
    }
}

struct URLReferenceEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: URLReferenceEditorViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Destination") {
                    Picker("Workspace", selection: $viewModel.selectedWorkspaceID) {
                        Text("Choose a Workspace").tag(UUID?.none)
                        ForEach(viewModel.workspaces) { Text($0.name).tag(Optional($0.id)) }
                    }
                }
                Section("Web Link") {
                    TextField("Title", text: $viewModel.title)
                    TextField("https://example.com", text: $viewModel.urlText)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                    TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...8)
                }
                if let error = viewModel.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(FieldbookColor.destructive)
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { if viewModel.saveTapped() { dismiss() } }
                        .disabled(!viewModel.canSave || viewModel.isSaving)
                }
            }
        }
        .onAppear { viewModel.appeared() }
    }
}

struct URLReferenceDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: URLReferenceDetailViewModel
    let edit: () -> Void
    let manageTags: () -> Void
    let moveItem: () -> Void
    @State private var confirmsDelete = false

    var body: some View {
        Group {
            if let detail = viewModel.detail {
                List {
                    Section("Address") {
                        Link(destination: detail.url) {
                            Label(detail.url.absoluteString, systemImage: "safari")
                        }
                    }
                    if !detail.notes.isEmpty { Section("Notes") { Text(detail.notes) } }
                    if !detail.tags.isEmpty { Section("Tags") { TagListView(tags: detail.tags) } }
                    Section("Metadata") { Text(detail.updatedAt, format: .dateTime) }
                }
            } else if let error = viewModel.errorMessage {
                ContentUnavailableView("Web Link Unavailable", systemImage: "link.badge.plus", description: Text(error))
            } else { ProgressView("Loading Web Link") }
        }
        .navigationTitle(viewModel.detail?.title ?? String(localized: "Web Link"))
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit", systemImage: "pencil", action: edit)
                Button("Manage Tags", systemImage: "tag", action: manageTags)
                Button("Move", systemImage: "folder", action: moveItem)
                if let detail = viewModel.detail { ShareLink(item: detail.url) { Label("Share", systemImage: "square.and.arrow.up") } }
                Button("Delete", systemImage: "trash", role: .destructive) { confirmsDelete = true }
            }
        }
        .alert("Delete Web Link?", isPresented: $confirmsDelete) {
            Button("Delete", role: .destructive) { if viewModel.deleteConfirmed() { dismiss() } }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear { viewModel.appeared() }
    }
}
