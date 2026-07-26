import SwiftUI

/// Search-tab screen for local-only knowledge discovery.
///
/// It binds user criteria to explicit ViewModel intents and owns no persistence or search work.
struct SearchScreen: View {
    let viewModel: SearchViewModel
    let openItem: (UUID, KnowledgeItemKind) -> Void

    var body: some View {
        SearchStateRenderer(
            state: viewModel.state,
            selectedWorkspaceID: Binding(
                get: { viewModel.state.form.selectedWorkspaceID },
                set: { workspaceID in
                    viewModel.workspaceSelectionChanged(workspaceID)
                }
            ),
            selectedKind: Binding(
                get: { viewModel.state.form.selectedKind },
                set: { kind in
                    viewModel.kindSelectionChanged(kind)
                }
            ),
            selectedTagID: Binding(
                get: { viewModel.state.form.selectedTagID },
                set: { tagID in
                    viewModel.tagSelectionChanged(tagID)
                }
            ),
            clear: viewModel.clearTapped,
            retry: viewModel.retryTapped,
            openItem: openItem
        )
        .navigationTitle("Search")
        .searchable(
            text: Binding(
                get: { viewModel.state.form.query },
                set: { query in
                    viewModel.queryChanged(query)
                }
            ),
            prompt: "Title, text, filename, or tag"
        )
        .onAppear {
            viewModel.appeared()
        }
        .onDisappear {
            viewModel.disappeared()
        }
    }
}
