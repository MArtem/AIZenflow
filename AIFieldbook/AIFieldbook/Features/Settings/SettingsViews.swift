import Foundation
import Observation
import SwiftUI
import UIKit

@MainActor
@Observable
final class SettingsViewModel {
    private let repository: FieldbookRepository
    private let fileStore: AppFileStore
    private(set) var storageBytes: Int64 = 0
    private(set) var exportURL: URL?
    private(set) var errorMessage: String?
    private(set) var isWorking = false

    init(repository: FieldbookRepository, fileStore: AppFileStore) {
        self.repository = repository
        self.fileStore = fileStore
    }

    func appeared() async { storageBytes = await fileStore.storageByteCount() }

    func cleanupTemporaryFilesTapped() async {
        await fileStore.cleanupAbandonedStaging()
        await fileStore.cleanupExports()
        exportURL = nil
        storageBytes = await fileStore.storageByteCount()
    }

    func exportTapped() async {
        isWorking = true
        defer { isWorking = false }
        do {
            exportURL = try await fileStore.createExport(manifest: repository.exportManifestData())
            storageBytes = await fileStore.storageByteCount()
        } catch { errorMessage = String(localized: "Local data couldn’t be exported.") }
    }

    func deleteAllConfirmed() async -> Bool {
        isWorking = true
        defer { isWorking = false }
        var staged: [StagedDeletion] = []
        do {
            staged = try await fileStore.stageDeletion(repository.allFileReferences())
            do { try repository.deleteAllData() }
            catch { try? await fileStore.rollbackDeletion(staged); throw error }
            await fileStore.commitDeletion(staged)
            await fileStore.cleanupExports()
            exportURL = nil
            storageBytes = await fileStore.storageByteCount()
            return true
        } catch {
            errorMessage = String(localized: "Local data couldn’t be deleted completely.")
            return false
        }
    }
}

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Bindable var viewModel: SettingsViewModel
    @State private var confirmsDeleteAll = false

    var body: some View {
        List {
            Section("Privacy") {
                Label("All content stays on this device.", systemImage: "lock.shield")
                Text("AI Fieldbook has no account, backend, analytics, or cloud processing in Iteration 1.")
                    .font(FieldbookTypography.supporting)
                    .foregroundStyle(.secondary)
            }
            Section("Storage") {
                LabeledContent("App-owned data", value: ByteCountFormatter.string(fromByteCount: viewModel.storageBytes, countStyle: .file))
                Button("Clean Temporary Files", systemImage: "trash.slash") { Task { await viewModel.cleanupTemporaryFilesTapped() } }
            }
            Section("Export") {
                Button("Prepare Local Export", systemImage: "square.and.arrow.up") { Task { await viewModel.exportTapped() } }
                    .disabled(viewModel.isWorking)
                if let url = viewModel.exportURL { ShareLink(item: url) { Label("Share Export Folder", systemImage: "square.and.arrow.up") } }
            }
            Section("Permissions") {
                Button("Open App Settings", systemImage: "gear") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
                Text("Microphone access is requested only when you start recording.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Data Lifecycle") {
                Button("Delete All Local Data", systemImage: "trash", role: .destructive) { confirmsDeleteAll = true }
            }
            if let error = viewModel.errorMessage { Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(FieldbookColor.destructive) }
        }
        .navigationTitle("Settings")
        .alert("Delete All Local Data?", isPresented: $confirmsDeleteAll) {
            Button("Delete Everything", role: .destructive) { Task { _ = await viewModel.deleteAllConfirmed() } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This permanently deletes every workspace, item, tag, and app-owned file.") }
        .task { await viewModel.appeared() }
    }
}
