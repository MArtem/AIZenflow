import Foundation
import Observation
import TchopErrors
import TchopUIConfiguration

@MainActor
@Observable
final class ChannelCardStore {
    private(set) var cards: [ChannelCardContent] = []

    func publish(_ card: ChannelCardContent) {
        cards.insert(card, at: 0)
    }

    func cards(for channelID: String?) -> [ChannelCardContent] {
        guard let channelID else {
            return []
        }

        return cards.filter { $0.channelID == channelID }
    }
}

@MainActor
@Observable
final class FeedComposerViewModel {
    var selectedChannelID: String
    var text: String
    var headline: String
    var subheadline: String
    var source: String
    private(set) var visibleTextFieldKinds: Set<ChannelCardTextFieldKind>
    private(set) var media: ChannelCardMediaContent?
    private let channelsStore: ChannelsStore
    private let channelCardStore: ChannelCardStore

    init(
        selectedChannelID: String,
        channelsStore: ChannelsStore,
        channelCardStore: ChannelCardStore
    ) {
        self.selectedChannelID = selectedChannelID
        self.channelsStore = channelsStore
        self.channelCardStore = channelCardStore
        self.text = ""
        self.headline = ""
        self.subheadline = ""
        self.source = ""
        self.visibleTextFieldKinds = [.text]
    }

    var availableChannels: [AppChannel] {
        channelsStore.selectionSnapshot.availableChannels
    }

    var selectedChannelTitle: String {
        availableChannels.first(where: { $0.id == selectedChannelID })?.title ?? "Channel"
    }

    var canPublish: Bool {
        media != nil || normalized(text) != nil
    }

    var availableInsertions: [FeedComposerInsertion] {
        var insertions: [FeedComposerInsertion] = []

        switch media {
        case nil:
            insertions.append(.photoOrVideo)
            insertions.append(.audio)
            insertions.append(.pdf)
        case let .photos(items):
            if items.count < 10 {
                insertions.append(.photo)
            }
        case .file:
            break
        }

        if !visibleTextFieldKinds.contains(.text) {
            insertions.append(.text)
        }
        if !visibleTextFieldKinds.contains(.headline) {
            insertions.append(.headline)
        }
        if !visibleTextFieldKinds.contains(.subheadline) {
            insertions.append(.subheadline)
        }
        if !visibleTextFieldKinds.contains(.source) {
            insertions.append(.source)
        }

        return insertions
    }

    var orderedVisibleTextFieldKinds: [ChannelCardTextFieldKind] {
        ChannelCardTextFieldKind.allCases.filter { visibleTextFieldKinds.contains($0) }
    }

    var showsPhotoToolbarAction: Bool {
        media == nil || media?.kind == .photo
    }

    func selectChannel(id: String) {
        selectedChannelID = id
    }

    func applyInsertion(_ insertion: FeedComposerInsertion) {
        switch insertion {
        case .photoOrVideo:
            break
        case .photo:
            addPhoto()
        case .audio:
            selectMedia(.audio)
        case .pdf:
            selectMedia(.pdf)
        case .text, .headline, .subheadline, .source:
            visibleTextFieldKinds.insert(insertion.textFieldKind)
        }
    }

    func addPhoto() {
        switch media {
        case nil:
            media = .photos(items: [makePhotoItem(number: 1)])
        case let .photos(items):
            guard items.count < 10 else {
                return
            }
            media = .photos(items: items + [makePhotoItem(number: items.count + 1)])
        case .file:
            return
        }
        visibleTextFieldKinds.insert(.text)
    }

    func selectVideo() {
        selectMedia(.video)
    }

    func textValue(for kind: ChannelCardTextFieldKind) -> String {
        switch kind {
        case .text:
            return text
        case .headline:
            return headline
        case .subheadline:
            return subheadline
        case .source:
            return source
        }
    }

    func updateText(_ value: String, for kind: ChannelCardTextFieldKind) {
        switch kind {
        case .text:
            text = value
        case .headline:
            headline = value
        case .subheadline:
            subheadline = value
        case .source:
            source = value
        }
    }

    func handleBackspaceOnEmptyField(_ kind: ChannelCardTextFieldKind) {
        guard textValue(for: kind).isEmpty else {
            return
        }

        if kind == .text && media == nil {
            return
        }

        visibleTextFieldKinds.remove(kind)
    }

    func removeFieldIfOptionalAndEmpty(_ kind: ChannelCardTextFieldKind) {
        guard normalized(textValue(for: kind)) == nil else {
            return
        }

        if kind == .text && media == nil {
            return
        }

        visibleTextFieldKinds.remove(kind)
    }

    func fieldPlaceholder(for kind: ChannelCardTextFieldKind) -> String {
        kind.placeholder
    }

    func fieldIsRequired(_ kind: ChannelCardTextFieldKind) -> Bool {
        kind == .text && media == nil
    }

    func fieldSupportsRemoval(_ kind: ChannelCardTextFieldKind) -> Bool {
        visibleTextFieldKinds.contains(kind) && !(kind == .text && media == nil)
    }

    func publish() -> ChannelCardContent? {
        guard canPublish else {
            return nil
        }

        let resolvedKind: ChannelCardKind
        switch media {
        case .photos:
            resolvedKind = .photo
        case let .file(file):
            resolvedKind = switch file.kind {
            case .photo: .photo
            case .video: .video
            case .audio: .audio
            case .pdf: .pdf
            }
        case nil:
            resolvedKind = .text
        }

        let card = ChannelCardContent(
            id: UUID().uuidString,
            channelID: selectedChannelID,
            createdAt: Date(),
            kind: resolvedKind,
            text: visibleTextFieldKinds.contains(.text) ? normalized(text) : nil,
            headline: visibleTextFieldKinds.contains(.headline) ? normalized(headline) : nil,
            subheadline: visibleTextFieldKinds.contains(.subheadline) ? normalized(subheadline) : nil,
            source: visibleTextFieldKinds.contains(.source) ? normalized(source) : nil,
            media: media
        )
        channelCardStore.publish(card)
        return card
    }

    private func selectMedia(_ kind: ChannelCardMediaKind) {
        guard media == nil else {
            return
        }

        switch kind {
        case .photo:
            media = .photos(items: [makePhotoItem(number: 1)])
        case .video:
            media = .file(makeFileMedia(kind: .video))
        case .audio:
            media = .file(makeFileMedia(kind: .audio))
        case .pdf:
            media = .file(makeFileMedia(kind: .pdf))
        }
        visibleTextFieldKinds.insert(.text)
    }

    private func makePhotoItem(number: Int) -> ChannelCardPhotoItem {
        ChannelCardPhotoItem(
            id: UUID().uuidString,
            displayTitle: "Photo \(number)",
            caption: nil,
            copyright: nil
        )
    }

    private func makeFileMedia(kind: ChannelCardMediaKind) -> ChannelCardFileMediaContent {
        let displayTitle = switch kind {
        case .photo:
            "Photo"
        case .video:
            "Video"
        case .audio:
            "Audio"
        case .pdf:
            "PDF"
        }

        return ChannelCardFileMediaContent(
            kind: kind,
            displayTitle: displayTitle,
            teaserImage: nil,
            caption: nil
        )
    }

    private func normalized(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private extension FeedComposerInsertion {
    var textFieldKind: ChannelCardTextFieldKind {
        switch self {
        case .text:
            return .text
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .source:
            return .source
        case .photoOrVideo, .photo, .audio, .pdf:
            return .text
        }
    }
}

/// View model for the authenticated shell.
///
/// Owns shell-scoped UI state such as the menu visibility and exposes child
/// feature view models required by the tab content.
@MainActor
@Observable
final class AppShellViewModel {
    /// Whether the side menu is currently open.
    var isMenuOpen: Bool

    /// Footer text shown in the side menu.
    let sideMenuFooterText: String

    /// View model for the news feed feature.
    let newsFeedViewModel: NewsFeedViewModel

    /// Whether the floating action button should be rendered for the active shell.
    private(set) var showsFloatingActionButton: Bool

    /// Whether the news feed list is currently close enough to the top to allow the floating action button.
    private(set) var isNewsFeedNearTop: Bool

    private let uiConfigurationManager: any UIConfigurationManaging
    private let errorManager: any AppErrorManaging
    let channelsStore: ChannelsStore
    private let channelCardStore: ChannelCardStore
    private(set) var activeComposer: FeedComposerViewModel?

    /// Creates the shell view model from repository-backed content.
    init(
        channelsStore: ChannelsStore,
        channelCardStore: ChannelCardStore = ChannelCardStore(),
        newsFeedViewModel: NewsFeedViewModel,
        errorManager: any AppErrorManaging,
        uiConfigurationManager: any UIConfigurationManaging,
        isMenuOpen: Bool = false,
        sideMenuFooterText: String = AppLocalization.text("shell.sideMenu.footer")
    ) {
        self.isMenuOpen = isMenuOpen
        self.channelsStore = channelsStore
        self.channelCardStore = channelCardStore
        self.sideMenuFooterText = sideMenuFooterText
        self.newsFeedViewModel = newsFeedViewModel
        self.showsFloatingActionButton = true
        self.isNewsFeedNearTop = true
        self.errorManager = errorManager
        self.uiConfigurationManager = uiConfigurationManager

        startUIConfigurationLoad()
    }

    /// Toggles the side menu state.
    func toggleMenu() {
        isMenuOpen.toggle()
    }

    /// Closes the side menu explicitly.
    func closeMenu() {
        isMenuOpen = false
    }

    /// Applies one new active channel choice to the shared runtime store.
    func selectChannel(id: String) {
        if channelsStore.selectChannel(id: id) {
            newsFeedViewModel.handleSelectedChannelChange()
        }
    }

    func presentComposer() {
        let selectedChannelID = channelsStore.selectionSnapshot.selectedChannelID
            ?? channelsStore.selectionSnapshot.selectedChannel?.id
            ?? AppChannel.defaultChannel.id

        activeComposer = FeedComposerViewModel(
            selectedChannelID: selectedChannelID,
            channelsStore: channelsStore,
            channelCardStore: channelCardStore
        )
    }

    func dismissComposer() {
        activeComposer = nil
    }

    func publishComposer() {
        newsFeedViewModel.handleLocalChannelCardsChanged()
        activeComposer = nil
    }

    /// Updates shell runtime visibility state for the news-feed floating action button.
    ///
    /// The shell owns the button itself, but the scroll-position signal comes from the news list.
    func setNewsFeedNearTop(_ isNearTop: Bool) {
        guard isNewsFeedNearTop != isNearTop else {
            return
        }

        isNewsFeedNearTop = isNearTop
    }

    /// Starts the asynchronous shell configuration bootstrap sequence.
    ///
    /// The shell first applies cached configuration and then asks for a refreshed snapshot so
    /// first paint stays fast even when remote configuration is slow or unavailable.
    private func startUIConfigurationLoad() {
        Task {
            await loadUIConfiguration()
        }
    }

    /// Loads cached and refreshed shell configuration in order.
    private func loadUIConfiguration() async {
        let currentConfiguration = await uiConfigurationManager.currentConfiguration()
        applyShellConfiguration(currentConfiguration)
        await refreshUIConfiguration()
    }

    /// Refreshes shell configuration from the remote-backed configuration manager.
    private func refreshUIConfiguration() async {
        do {
            let refreshedConfiguration = try await uiConfigurationManager.refreshConfiguration()
            applyShellConfiguration(refreshedConfiguration)
        } catch {
            handleUIConfigurationRefreshFailure(error)
        }
    }

    /// Applies shell-specific UI settings from a full configuration snapshot.
    private func applyShellConfiguration(_ configuration: UIConfigurationSnapshot) {
        showsFloatingActionButton = configuration.shell.showsFloatingActionButton
    }

    /// Handles non-fatal refresh failures after the cached configuration has already been applied.
    private func handleUIConfigurationRefreshFailure(_ error: any Error) {
        Task { [errorManager] in
            let presentation = await errorManager.presentableError(
                from: error,
                context: AppErrorContext(
                    operation: "refreshUIConfiguration",
                    feature: "appShell"
                )
            )
            assertionFailure("Failed to fetch UI configuration: \(presentation.error.debugDescription)")
        }
    }
}
