import SwiftUI

/// Renders filters and one explicit local-search result state.
struct SearchStateRenderer: View {
    let state: SearchViewState
    @Binding var selectedWorkspaceID: UUID?
    @Binding var selectedKind: KnowledgeItemKind?
    @Binding var selectedTagID: UUID?
    let clear: () -> Void
    let retry: () -> Void
    let openItem: (UUID, KnowledgeItemKind) -> Void

    var body: some View {
        List {
            SearchFilterView(
                form: state.form,
                selectedWorkspaceID: $selectedWorkspaceID,
                selectedKind: $selectedKind,
                selectedTagID: $selectedTagID,
                clear: clear
            )

            switch state {
            case .criteria:
                Section {
                    ContentUnavailableView(
                        "Search Local Content",
                        systemImage: "magnifyingglass",
                        description: Text(String(localized: "Enter text or choose a filter. Search stays on this device."))
                    )
                }
            case let .searching(_, existingRows):
                if existingRows.isEmpty {
                    Section {
                        ProgressView("Searching Local Content")
                    }
                } else {
                    SearchResultsView(rows: existingRows, openItem: openItem)
                    Section {
                        ProgressView("Searching Local Content")
                    }
                }
            case let .results(_, rows):
                SearchResultsView(rows: rows, openItem: openItem)
            case let .empty(form):
                Section {
                    ContentUnavailableView.search(text: form.query)
                }
            case let .failure(_, message):
                Section {
                    Label(message, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(FieldbookColor.destructive)
                        .accessibilityLabel("Error: \(message)")
                    Button("Try Again", action: retry)
                }
            }
        }
    }
}
