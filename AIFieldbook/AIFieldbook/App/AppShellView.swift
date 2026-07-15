import SwiftData
import SwiftUI

/// Root scene view that wires app composition into tab navigation.
///
/// Responsibilities:
/// - owns one `AppComposition` for the scene through SwiftUI state;
/// - renders the four app tabs and delegates route construction to the coordinator;
/// - hosts modal presentations and deep-link error UI at the app boundary.
///
/// Invariants:
/// Feature views receive state owners and intent callbacks from composition; they do not
/// create repositories, file stores, search actors, or navigation routers directly.
struct AppShellView: View {
    @State private var composition: AppComposition

    init(container: ModelContainer) {
        _composition = State(initialValue: AppComposition(container: container))
    }

    var body: some View {
        @Bindable var coordinator = composition.coordinator

        TabView(selection: $coordinator.selectedTab) {
            Tab("Workspace", systemImage: "square.grid.2x2", value: AppTab.workspace) {
                workspaceScene
            }

            Tab("Capture", systemImage: "plus.circle", value: AppTab.capture) {
                captureScene
            }

            Tab("Search", systemImage: "magnifyingglass", value: AppTab.search) {
                searchScene
            }

            Tab("Settings", systemImage: "gearshape", value: AppTab.settings) {
                settingsScene
            }
        }
        .tint(FieldbookColor.accent)
        .sheet(item: $coordinator.presentation, onDismiss: composition.presentationDismissed) { presentation in
            presentationView(presentation)
        }
        .task {
            await composition.started()
        }
        .onOpenURL(perform: composition.handleOpenURL)
        .alert(
            "Link Unavailable",
            isPresented: Binding(
                get: { composition.deepLinkErrorMessage != nil },
                set: { if !$0 { composition.deepLinkErrorDismissed() } }
            )
        ) {
            Button("OK") { composition.deepLinkErrorDismissed() }
        } message: {
            Text(composition.deepLinkErrorMessage ?? "")
        }
    }

    private var workspaceScene: some View {
        @Bindable var router = composition.coordinator.workspaceRouter
        return NavigationStack(path: $router.path) {
            WorkspaceListView(
                viewModel: composition.workspaceListModel,
                createWorkspace: composition.presentCreateWorkspace,
                openWorkspace: composition.coordinator.openWorkspace
            )
            .navigationDestination(for: WorkspaceRoute.self) { route in
                switch route {
                case let .workspace(id):
                    WorkspaceDetailView(
                        viewModel: composition.workspaceDetailModel(id: id),
                        openItem: { itemID, kind in
                            composition.coordinator.openItem(id: itemID, kind: kind, from: .workspace)
                        },
                        createTextNote: { composition.presentCreateTextNote(workspaceID: id) },
                        renameWorkspace: composition.presentRenameWorkspace
                    )
                case let .item(id, kind):
                    itemDetailView(id: id, kind: kind)
                }
            }
        }
    }

    private var captureScene: some View {
        @Bindable var router = composition.coordinator.captureRouter
        return NavigationStack(path: $router.path) {
            CaptureView(
                workspaceModel: composition.captureWorkspaceModel,
                createTextNote: { composition.presentCreateTextNote(workspaceID: nil) },
                importItem: composition.presentImport,
                createURLReference: composition.presentCreateURLReference,
                recordAudio: composition.presentAudioRecorder
            )
            .navigationDestination(for: CaptureRoute.self) { route in
                switch route {
                case let .item(id, kind): itemDetailView(id: id, kind: kind)
                }
            }
        }
    }

    private var searchScene: some View {
        @Bindable var router = composition.coordinator.searchRouter
        return NavigationStack(path: $router.path) {
            SearchView(
                viewModel: composition.searchModel,
                openItem: { id, kind in
                    composition.coordinator.openItem(id: id, kind: kind, from: .search)
                }
            )
            .navigationDestination(for: SearchRoute.self) { route in
                switch route {
                case let .item(id, kind): itemDetailView(id: id, kind: kind)
                }
            }
        }
    }

    private var settingsScene: some View {
        @Bindable var router = composition.coordinator.settingsRouter
        return NavigationStack(path: $router.path) {
            SettingsView(
                viewModel: composition.settingsModel,
                localDataResetCompleted: composition.localDataResetCompleted
            )
        }
    }

    @ViewBuilder
    private func itemDetailView(id: UUID, kind: KnowledgeItemKind) -> some View {
        if kind == .textNote {
            TextNoteDetailView(
                viewModel: composition.textDetailModel(id: id),
                editNote: { composition.presentEditTextNote(id: id) },
                manageTags: { composition.presentTagManager(itemID: id) },
                moveItem: { composition.presentMoveItem(id: id) }
            )
        } else if kind == .urlReference {
            URLReferenceDetailView(
                viewModel: composition.urlDetailModel(id: id),
                edit: { composition.presentEditURLReference(id: id) },
                manageTags: { composition.presentTagManager(itemID: id) },
                moveItem: { composition.presentMoveItem(id: id) }
            )
        } else {
            ImportedItemDetailView(
                viewModel: composition.importedDetailModel(id: id),
                manageTags: { composition.presentTagManager(itemID: id) },
                moveItem: { composition.presentMoveItem(id: id) }
            )
        }
    }

    @ViewBuilder
    private func presentationView(_ presentation: AppPresentation) -> some View {
        switch presentation {
        case .createWorkspace, .renameWorkspace:
            if let model = composition.workspaceEditorModel {
                WorkspaceEditorView(viewModel: model)
            }
        case .createTextNote, .editTextNote:
            if let model = composition.textEditorModel {
                TextNoteEditorView(viewModel: model)
            }
        case .manageTags:
            if let model = composition.tagManagerModel {
                TagManagerView(viewModel: model)
            }
        case .importItem:
            if let model = composition.importItemModel {
                ImportItemView(viewModel: model)
            }
        case .createURLReference, .editURLReference:
            if let model = composition.urlEditorModel {
                URLReferenceEditorView(viewModel: model)
            }
        case .recordAudio:
            if let model = composition.audioRecorderModel {
                AudioRecorderView(viewModel: model)
            }
        case .moveItem:
            if let model = composition.moveItemModel {
                MoveItemView(viewModel: model)
            }
        }
    }
}

/// Fallback destination for route types that are intentionally reserved for later flows.
///
/// This keeps route expansion explicit without silently navigating to an empty or wrong screen.
struct PlaceholderDestinationView: View {
    let title: LocalizedStringKey
    let systemImage: String
    let message: LocalizedStringKey

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(message))
            .navigationTitle(title)
    }
}

/// Startup failure surface shown when local SwiftData storage cannot be opened.
///
/// The view has no recovery side effects because persistence bootstrapping belongs to
/// `AIFieldbookApp`; users receive a clear blocking state instead of a partially functional UI.
struct PersistenceFailureView: View {
    var body: some View {
        ContentUnavailableView(
            "Local Storage Unavailable",
            systemImage: "externaldrive.badge.exclamationmark",
            description: Text(String(localized: "AI Fieldbook couldn’t open its local database. Close and reopen the app to try again."))
        )
    }
}
