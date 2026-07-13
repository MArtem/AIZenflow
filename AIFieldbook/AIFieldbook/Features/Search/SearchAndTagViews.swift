import SwiftUI

struct SearchView: View {
    @Bindable var viewModel: SearchViewModel
    let openItem: (UUID, KnowledgeItemKind) -> Void

    var body: some View {
        List {
                Section("Filters") {
                    Picker("Workspace", selection: $viewModel.selectedWorkspaceID) {
                        Text("All Workspaces").tag(UUID?.none)
                        ForEach(viewModel.workspaces) { workspace in
                            Text(workspace.name).tag(Optional(workspace.id))
                        }
                    }

                    Picker("Item Type", selection: $viewModel.selectedKind) {
                        Text("All Types").tag(KnowledgeItemKind?.none)
                        ForEach(KnowledgeItemKind.allCases, id: \.self) { kind in
                            Text(kind.displayName).tag(Optional(kind))
                        }
                    }

                    Picker("Tag", selection: $viewModel.selectedTagID) {
                        Text("All Tags").tag(UUID?.none)
                        ForEach(viewModel.tags) { tag in
                            Text(tag.name).tag(Optional(tag.id))
                        }
                    }

                    if viewModel.hasActiveCriteria {
                        Button("Clear Search", systemImage: "xmark.circle") {
                            viewModel.clearTapped()
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(FieldbookColor.destructive)
                            .accessibilityLabel("Error: \(errorMessage)")
                    }
                } else if !viewModel.hasActiveCriteria {
                    Section {
                        ContentUnavailableView(
                            "Search Local Content",
                            systemImage: "magnifyingglass",
                            description: Text("Enter text or choose a filter. Search stays on this device.")
                        )
                    }
                } else if viewModel.hasSearched && viewModel.results.isEmpty {
                    Section {
                        ContentUnavailableView.search(text: viewModel.query)
                    }
                } else {
                    Section("Results") {
                        ForEach(viewModel.results) { item in
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
            .navigationTitle("Search")
            .searchable(text: $viewModel.query, prompt: "Title, text, filename, or tag")
        .onAppear {
            viewModel.appeared()
        }
        .onChange(of: viewModel.query) {
            viewModel.searchCriteriaChanged()
        }
        .onChange(of: viewModel.selectedWorkspaceID) {
            viewModel.searchCriteriaChanged()
        }
        .onChange(of: viewModel.selectedKind) {
            viewModel.searchCriteriaChanged()
        }
        .onChange(of: viewModel.selectedTagID) {
            viewModel.searchCriteriaChanged()
        }
    }
}

struct TagManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TagManagerViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Create Tag") {
                    TextField("Tag Name", text: $viewModel.newTagName)
                    Button("Create and Assign", systemImage: "plus") {
                        viewModel.createTagTapped()
                    }
                    .disabled(!viewModel.canCreateTag)
                }

                Section("Assigned Tags") {
                    if viewModel.tags.isEmpty {
                        Text("No tags created yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.tags) { tag in
                            Toggle(
                                tag.name,
                                isOn: Binding(
                                    get: { viewModel.assignedTagIDs.contains(tag.id) },
                                    set: { isAssigned in
                                        viewModel.assignmentChanged(
                                            tagID: tag.id,
                                            isAssigned: isAssigned
                                        )
                                    }
                                )
                            )
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(FieldbookColor.destructive)
                            .accessibilityLabel("Error: \(errorMessage)")
                    }
                }
            }
            .navigationTitle("Manage Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.appeared()
        }
    }
}

struct TagListView: View {
    let tags: [TagSummary]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: FieldbookSpacing.compact) {
                ForEach(tags) { tag in
                    Label(tag.name, systemImage: "tag.fill")
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.horizontal, FieldbookSpacing.standard)
                        .padding(.vertical, FieldbookSpacing.compact)
                        .background(FieldbookColor.surface)
                        .clipShape(.capsule)
                }
            }
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tags")
    }
}
