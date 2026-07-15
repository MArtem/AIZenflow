import SwiftUI

/// Sheet UI for moving an item to another workspace.
///
/// The view owns no persistence state; it renders workspace choices and forwards the move
/// intent to `MoveItemViewModel`.
struct MoveItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: MoveItemViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Destination Workspace") {
                    Picker("Workspace", selection: $viewModel.selectedWorkspaceID) {
                        Text(String(localized: "Choose a Workspace")).tag(UUID?.none)
                        ForEach(viewModel.workspaces) { Text($0.name).tag(Optional($0.id)) }
                    }
                }
                if let error = viewModel.errorMessage { Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(FieldbookColor.destructive) }
            }
            .navigationTitle("Move Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Move") { if viewModel.moveTapped() { dismiss() } }.disabled(viewModel.selectedWorkspaceID == nil) }
            }
        }
        .onAppear { viewModel.appeared() }
    }
}
