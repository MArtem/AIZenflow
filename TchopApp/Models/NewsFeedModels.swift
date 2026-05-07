import Foundation

enum ChannelCardKind: String, Equatable, Sendable {
    case text
    case photo
    case video
    case audio
    case pdf
}

enum ChannelCardMediaKind: String, Equatable, Sendable {
    case photo
    case video
    case audio
    case pdf
}

struct ChannelCardSourceContent: Equatable, Sendable {
    let text: String
    let resourceURLString: String?
}

struct ChannelCardPhotoItem: Equatable, Sendable, Identifiable {
    let id: String
    let displayTitle: String
    let caption: String?
    let copyright: String?
}

struct ChannelCardTeaserImageContent: Equatable, Sendable, Identifiable {
    let id: String
    let displayTitle: String
    let copyright: String?
}

struct ChannelCardFileMediaContent: Equatable, Sendable {
    let kind: ChannelCardMediaKind
    let displayTitle: String
    let teaserImage: ChannelCardTeaserImageContent?
    let caption: String?
}

enum ChannelCardMediaContent: Equatable, Sendable {
    case photos(items: [ChannelCardPhotoItem])
    case file(ChannelCardFileMediaContent)

    var kind: ChannelCardMediaKind {
        switch self {
        case .photos:
            return .photo
        case let .file(file):
            return file.kind
        }
    }

    var displayTitle: String {
        switch self {
        case let .photos(items):
            let count = items.count
            return count == 1 ? "1 Photo" : "\(count) Photos"
        case let .file(file):
            return file.displayTitle
        }
    }

    var photoCount: Int {
        switch self {
        case let .photos(items):
            return items.count
        case .file:
            return 0
        }
    }

    var teaserImage: ChannelCardTeaserImageContent? {
        switch self {
        case .photos:
            return nil
        case let .file(file):
            return file.teaserImage
        }
    }

    var caption: String? {
        switch self {
        case .photos:
            return nil
        case let .file(file):
            return file.caption
        }
    }
}

enum ChannelCardTextFieldKind: String, CaseIterable, Equatable, Sendable, Identifiable {
    case text
    case headline
    case subheadline
    case source

    var id: String { rawValue }

    var sortOrder: Int {
        switch self {
        case .text:
            return 0
        case .headline:
            return 1
        case .subheadline:
            return 2
        case .source:
            return 3
        }
    }

    var title: String {
        switch self {
        case .text: return "Text"
        case .headline: return "Headline"
        case .subheadline: return "Subheadline"
        case .source: return "Source"
        }
    }

    var placeholder: String {
        switch self {
        case .text: return "Enter card text..."
        case .headline: return "Add headline"
        case .subheadline: return "Add subheadline"
        case .source: return "Add source"
        }
    }
}

enum FeedComposerInsertion: Equatable, Sendable, Identifiable {
    case photoOrVideo
    case photo
    case audio
    case pdf
    case text
    case headline
    case subheadline
    case source

    var id: String { title }

    var title: String {
        switch self {
        case .photoOrVideo: return "Photo or Video"
        case .photo: return "Photo"
        case .audio: return "Audio"
        case .pdf: return "PDF"
        case .text: return "Text"
        case .headline: return "Headline"
        case .subheadline: return "Subheadline"
        case .source: return "Source"
        }
    }
}

struct FeedComposerDraft: Equatable, Sendable {
    var selectedChannelID: String
    private(set) var visibleTextFieldKinds: Set<ChannelCardTextFieldKind>
    private(set) var textValues: [ChannelCardTextFieldKind: String]
    private(set) var media: ChannelCardMediaContent?
    private(set) var isFileCaptionFieldVisible: Bool
    private(set) var isTeaserCopyrightFieldVisible: Bool
    private(set) var visiblePhotoCaptionFieldIDs: Set<String>
    private(set) var visiblePhotoCopyrightFieldIDs: Set<String>

    init(selectedChannelID: String) {
        self.selectedChannelID = selectedChannelID
        self.visibleTextFieldKinds = [.text]
        self.textValues = [
            .text: "",
            .headline: "",
            .subheadline: "",
            .source: ""
        ]
        self.media = nil
        self.isFileCaptionFieldVisible = false
        self.isTeaserCopyrightFieldVisible = false
        self.visiblePhotoCaptionFieldIDs = []
        self.visiblePhotoCopyrightFieldIDs = []
    }

    var canPublish: Bool {
        media != nil || normalizedText(for: .text) != nil
    }

    var effectiveKind: ChannelCardKind? {
        guard canPublish else {
            return nil
        }

        switch media?.kind {
        case .photo:
            return .photo
        case .video:
            return .video
        case .audio:
            return .audio
        case .pdf:
            return .pdf
        case nil:
            return .text
        }
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

    func textValue(for kind: ChannelCardTextFieldKind) -> String {
        textValues[kind] ?? ""
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

    mutating func selectChannel(id: String) {
        selectedChannelID = id
    }

    mutating func applyInsertion(_ insertion: FeedComposerInsertion) {
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

    mutating func addPhoto() {
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

    mutating func selectVideo() {
        selectMedia(.video)
    }

    mutating func removeMedia() {
        media = nil
        isFileCaptionFieldVisible = false
        isTeaserCopyrightFieldVisible = false
        visiblePhotoCaptionFieldIDs = []
        visiblePhotoCopyrightFieldIDs = []
    }

    mutating func removePhoto(id: String) {
        guard case let .photos(items) = media else {
            return
        }

        let remainingItems = items.filter { $0.id != id }
        visiblePhotoCaptionFieldIDs.remove(id)
        visiblePhotoCopyrightFieldIDs.remove(id)
        media = remainingItems.isEmpty ? nil : .photos(items: remainingItems)
    }

    mutating func showPhotoCaptionField(id: String) {
        guard photoItem(id: id) != nil else {
            return
        }

        visiblePhotoCaptionFieldIDs.insert(id)
    }

    mutating func removePhotoCaptionFieldIfEmpty(id: String) {
        guard photoCaptionText(id: id) == nil else {
            return
        }

        visiblePhotoCaptionFieldIDs.remove(id)
    }

    mutating func showFileCaptionField() {
        guard case .file = media else {
            return
        }

        isFileCaptionFieldVisible = true
    }

    mutating func removeFileCaptionFieldIfEmpty() {
        guard fileCaptionText == nil else {
            return
        }

        isFileCaptionFieldVisible = false
    }

    mutating func updatePhotoCaption(_ value: String?, id: String) {
        guard case let .photos(items) = media else {
            return
        }

        media = .photos(
            items: items.map { item in
                guard item.id == id else {
                    return item
                }

                return ChannelCardPhotoItem(
                    id: item.id,
                    displayTitle: item.displayTitle,
                    caption: normalizedOptionalText(value),
                    copyright: item.copyright
                )
            }
        )
    }

    mutating func updatePhotoCopyright(_ value: String?, id: String) {
        guard case let .photos(items) = media else {
            return
        }

        media = .photos(
            items: items.map { item in
                guard item.id == id else {
                    return item
                }

                return ChannelCardPhotoItem(
                    id: item.id,
                    displayTitle: item.displayTitle,
                    caption: item.caption,
                    copyright: normalizedOptionalText(value)
                )
            }
        )
    }

    mutating func updateFileCaption(_ value: String?) {
        guard case let .file(file) = media else {
            return
        }

        media = .file(
            ChannelCardFileMediaContent(
                kind: file.kind,
                displayTitle: file.displayTitle,
                teaserImage: file.teaserImage,
                caption: normalizedOptionalText(value)
            )
        )
    }

    mutating func showPhotoCopyrightField(id: String) {
        guard photoItem(id: id) != nil else {
            return
        }

        visiblePhotoCopyrightFieldIDs.insert(id)
    }

    mutating func removePhotoCopyrightFieldIfEmpty(id: String) {
        guard photoCopyrightText(id: id) == nil else {
            return
        }

        visiblePhotoCopyrightFieldIDs.remove(id)
    }

    mutating func addOrReplaceTeaserImage(displayTitle: String = "Teaser image") {
        guard case let .file(file) = media else {
            return
        }

        media = .file(
            ChannelCardFileMediaContent(
                kind: file.kind,
                displayTitle: file.displayTitle,
                teaserImage: ChannelCardTeaserImageContent(
                    id: UUID().uuidString,
                    displayTitle: displayTitle,
                    copyright: file.teaserImage?.copyright
                ),
                caption: file.caption
            )
        )
    }

    mutating func showTeaserCopyrightField() {
        guard case let .file(file) = media, file.teaserImage != nil else {
            return
        }

        isTeaserCopyrightFieldVisible = true
    }

    mutating func removeTeaserImage() {
        guard case let .file(file) = media else {
            return
        }

        media = .file(
            ChannelCardFileMediaContent(
                kind: file.kind,
                displayTitle: file.displayTitle,
                teaserImage: nil,
                caption: file.caption
            )
        )
        isTeaserCopyrightFieldVisible = false
    }

    mutating func removeTeaserCopyrightFieldIfEmpty() {
        guard teaserCopyrightText == nil else {
            return
        }

        isTeaserCopyrightFieldVisible = false
    }

    mutating func updateTeaserCopyright(_ value: String?) {
        guard case let .file(file) = media else {
            return
        }

        guard let teaserImage = file.teaserImage else {
            return
        }

        media = .file(
            ChannelCardFileMediaContent(
                kind: file.kind,
                displayTitle: file.displayTitle,
                teaserImage: ChannelCardTeaserImageContent(
                    id: teaserImage.id,
                    displayTitle: teaserImage.displayTitle,
                    copyright: normalizedOptionalText(value)
                ),
                caption: file.caption
            )
        )
    }

    mutating func updateText(_ value: String, for kind: ChannelCardTextFieldKind) {
        textValues[kind] = value
    }

    var fileCaptionText: String? {
        guard case let .file(file) = media else {
            return nil
        }

        return file.caption
    }

    var photoItems: [ChannelCardPhotoItem] {
        guard case let .photos(items) = media else {
            return []
        }

        return items
    }

    func photoCaptionText(id: String) -> String? {
        photoItem(id: id)?.caption
    }

    func photoCopyrightText(id: String) -> String? {
        photoItem(id: id)?.copyright
    }

    var teaserCopyrightText: String? {
        guard case let .file(file) = media else {
            return nil
        }

        return file.teaserImage?.copyright
    }

    mutating func handleBackspaceOnEmptyField(_ kind: ChannelCardTextFieldKind) {
        guard textValue(for: kind).isEmpty else {
            return
        }

        if kind == .text && media == nil {
            return
        }

        visibleTextFieldKinds.remove(kind)
    }

    mutating func removeFieldIfOptionalAndEmpty(_ kind: ChannelCardTextFieldKind) {
        guard normalizedText(for: kind) == nil else {
            return
        }

        if kind == .text && media == nil {
            return
        }

        visibleTextFieldKinds.remove(kind)
    }

    func makeCard(id: String = UUID().uuidString, createdAt: Date = Date()) -> ChannelCardContent? {
        guard let resolvedKind = effectiveKind else {
            return nil
        }

        return ChannelCardContent(
            id: id,
            channelID: selectedChannelID,
            createdAt: createdAt,
            kind: resolvedKind,
            text: visibleTextFieldKinds.contains(.text) ? normalizedText(for: .text) : nil,
            headline: visibleTextFieldKinds.contains(.headline) ? normalizedText(for: .headline) : nil,
            subheadline: visibleTextFieldKinds.contains(.subheadline) ? normalizedText(for: .subheadline) : nil,
            source: visibleTextFieldKinds.contains(.source) ? normalizedText(for: .source) : nil,
            media: media
        )
    }

    private func normalizedText(for kind: ChannelCardTextFieldKind) -> String? {
        let trimmed = textValue(for: kind).trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func normalizedOptionalText(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func photoItem(id: String) -> ChannelCardPhotoItem? {
        guard case let .photos(items) = media else {
            return nil
        }

        return items.first(where: { $0.id == id })
    }

    private mutating func selectMedia(_ kind: ChannelCardMediaKind) {
        guard media == nil else {
            return
        }

        isFileCaptionFieldVisible = false
        isTeaserCopyrightFieldVisible = false

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
}

struct ChannelCardTextContent: Equatable, Sendable, Identifiable {
    let kind: ChannelCardTextFieldKind
    let text: String

    var id: ChannelCardTextFieldKind { kind }
}

struct ChannelCardContent: Identifiable, Equatable, Sendable {
    let id: String
    let channelID: String
    let createdAt: Date
    let kind: ChannelCardKind
    let text: String?
    let headline: String?
    let subheadline: String?
    let sourceContent: ChannelCardSourceContent?
    let mediaContent: ChannelCardMediaContent?

    init(
        id: String,
        channelID: String,
        createdAt: Date,
        kind: ChannelCardKind,
        text: String?,
        headline: String?,
        subheadline: String?,
        source: String?,
        sourceURLString: String? = nil,
        media: ChannelCardMediaContent?
    ) {
        self.id = id
        self.channelID = channelID
        self.createdAt = createdAt
        self.kind = kind
        self.text = text
        self.headline = headline
        self.subheadline = subheadline
        self.sourceContent = source.map {
            ChannelCardSourceContent(text: $0, resourceURLString: sourceURLString)
        }
        self.mediaContent = media
    }

    var source: String? {
        sourceContent?.text
    }

    var media: ChannelCardMediaContent? {
        mediaContent
    }

    var mediaKind: ChannelCardMediaKind? {
        media?.kind
    }

    var orderedTextContent: [ChannelCardTextContent] {
        ChannelCardTextFieldKind.allCases.compactMap { kind in
            guard let value = textValue(for: kind) else {
                return nil
            }

            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                return nil
            }

            return ChannelCardTextContent(kind: kind, text: trimmed)
        }
    }

    var orderedTextBlocks: [String] {
        orderedTextContent.map(\.text)
    }

    var serviceHeadline: String {
        orderedTextBlocks.first ?? kind.rawValue.capitalized
    }

    private func textValue(for kind: ChannelCardTextFieldKind) -> String? {
        switch kind {
        case .text:
            return text
        case .headline:
            return headline
        case .subheadline:
            return subheadline
        case .source:
            return sourceContent?.text
        }
    }
}

struct LocalFeedCardModel: Identifiable, Equatable, Sendable {
    let id: String
    let channelID: String
    let createdAt: Date
    let kind: ChannelCardKind
    let orderedTextContent: [ChannelCardTextContent]
    let sourceContent: ChannelCardSourceContent?
    let mediaContent: ChannelCardMediaContent?

    var serviceHeadline: String {
        orderedTextContent.first?.text ?? kind.rawValue.capitalized
    }

    var searchFields: [NewsFeedCardSearchField] {
        [
            NewsFeedCardSearchField(priority: 500, value: textValue(for: .text) ?? ""),
            NewsFeedCardSearchField(priority: 400, value: textValue(for: .headline) ?? ""),
            NewsFeedCardSearchField(priority: 300, value: textValue(for: .subheadline) ?? ""),
            NewsFeedCardSearchField(priority: 200, value: sourceContent?.text ?? "")
        ]
    }

    func textValue(for kind: ChannelCardTextFieldKind) -> String? {
        orderedTextContent.first(where: { $0.kind == kind })?.text
    }
}

/// Origin metadata for the feed content currently shown to the user.
enum NewsFeedAvailability: Equatable, Sendable {
    case live
    /// Content restored from local persistence rather than a fresh network-backed refresh.
    case cached(lastSyncedAt: Date?, reason: NewsFeedCacheReason)
}

/// Reason why the current feed content comes from persisted storage.
enum NewsFeedCacheReason: Equatable, Sendable {
    case bootstrap
    case offline
}

/// Root presentation model for the news tab feed.
struct NewsFeedContent: Equatable, Sendable {
    /// Ordered card list shown in the feed.
    let cards: [NewsFeedCard]
    let availability: NewsFeedAvailability

    /// Headline best suited for service consumers such as widgets.
    var primaryServiceHeadline: String? {
        cards.first?.serviceHeadline
    }

    /// Returns only the cards belonging to the provided channel while preserving availability metadata.
    func scoped(to channelID: String?) -> NewsFeedContent {
        guard let channelID else {
            return NewsFeedContent(cards: [], availability: availability)
        }

        return NewsFeedContent(
            cards: cards.filter { $0.channelID == channelID },
            availability: availability
        )
    }
}

/// Stable feed card categories used by cross-card UI logic such as search and create/edit flows.
enum NewsFeedCardKind: String, Equatable, Sendable {
    case text
    case photo
    case video
    case audio
    case pdf
}

/// Search field metadata used to rank card matches without hardcoding search behavior inside each screen.
struct NewsFeedCardSearchField: Equatable, Sendable {
    let priority: Int
    let value: String
}

enum NewsFeedPhotoCardContent: Identifiable, Equatable, Sendable {
    case remote(PhotoCardModel)
    case local(LocalFeedCardModel)

    var id: String {
        switch self {
        case let .remote(card):
            return card.id
        case let .local(card):
            return card.id
        }
    }

    var channelID: String {
        switch self {
        case let .remote(card):
            return card.channelID
        case let .local(card):
            return card.channelID
        }
    }

    var serviceHeadline: String {
        switch self {
        case let .remote(card):
            return card.serviceHeadline
        case let .local(card):
            return card.serviceHeadline
        }
    }

    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .remote(card):
            return [
                NewsFeedCardSearchField(priority: 500, value: card.headline),
                NewsFeedCardSearchField(priority: 400, value: card.summary),
                NewsFeedCardSearchField(priority: 300, value: card.sourceTitle),
                NewsFeedCardSearchField(priority: 250, value: card.brandTitle),
                NewsFeedCardSearchField(priority: 200, value: card.metadataLine),
                NewsFeedCardSearchField(priority: 150, value: card.translationLabel)
            ]
        case let .local(card):
            return card.searchFields
        }
    }
}

enum NewsFeedTextCardContent: Identifiable, Equatable, Sendable {
    case remote(TextCardModel)
    case local(LocalFeedCardModel)

    var id: String {
        switch self {
        case let .remote(card):
            return card.id
        case let .local(card):
            return card.id
        }
    }

    var channelID: String {
        switch self {
        case let .remote(card):
            return card.channelID
        case let .local(card):
            return card.channelID
        }
    }

    var serviceHeadline: String {
        switch self {
        case let .remote(card):
            return card.serviceHeadline
        case let .local(card):
            return card.serviceHeadline
        }
    }

    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .remote(card):
            return [
                NewsFeedCardSearchField(priority: 500, value: card.headline),
                NewsFeedCardSearchField(priority: 300, value: card.categoryTitle),
                NewsFeedCardSearchField(
                    priority: 120,
                    value: card.participants.map(\.initials).joined(separator: " ")
                )
            ]
        case let .local(card):
            return card.searchFields
        }
    }
}

enum NewsFeedVideoCardContent: Identifiable, Equatable, Sendable {
    case local(LocalFeedCardModel)

    var id: String {
        switch self {
        case let .local(card):
            return card.id
        }
    }

    var channelID: String {
        switch self {
        case let .local(card):
            return card.channelID
        }
    }

    var serviceHeadline: String {
        switch self {
        case let .local(card):
            return card.serviceHeadline
        }
    }

    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .local(card):
            return card.searchFields
        }
    }
}

enum NewsFeedAudioCardContent: Identifiable, Equatable, Sendable {
    case local(LocalFeedCardModel)

    var id: String {
        switch self {
        case let .local(card):
            return card.id
        }
    }

    var channelID: String {
        switch self {
        case let .local(card):
            return card.channelID
        }
    }

    var serviceHeadline: String {
        switch self {
        case let .local(card):
            return card.serviceHeadline
        }
    }

    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .local(card):
            return card.searchFields
        }
    }
}

enum NewsFeedPDFCardContent: Identifiable, Equatable, Sendable {
    case local(LocalFeedCardModel)

    var id: String {
        switch self {
        case let .local(card):
            return card.id
        }
    }

    var channelID: String {
        switch self {
        case let .local(card):
            return card.channelID
        }
    }

    var serviceHeadline: String {
        switch self {
        case let .local(card):
            return card.serviceHeadline
        }
    }

    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .local(card):
            return card.searchFields
        }
    }
}

/// Feed card variants currently supported by the home timeline.
enum NewsFeedCard: Identifiable, Equatable, Sendable {
    case photo(NewsFeedPhotoCardContent)
    case text(NewsFeedTextCardContent)
    case video(NewsFeedVideoCardContent)
    case audio(NewsFeedAudioCardContent)
    case pdf(NewsFeedPDFCardContent)

    /// Stable identity forwarded from the underlying card model.
    var id: String {
        switch self {
        case let .photo(card):
            return card.id
        case let .text(card):
            return card.id
        case let .video(card):
            return card.id
        case let .audio(card):
            return card.id
        case let .pdf(card):
            return card.id
        }
    }

    /// Stable card category used by generic feed flows.
    var kind: NewsFeedCardKind {
        switch self {
        case .photo:
            return .photo
        case .text:
            return .text
        case .video:
            return .video
        case .audio:
            return .audio
        case .pdf:
            return .pdf
        }
    }

    /// Owning channel for the card.
    var channelID: String {
        switch self {
        case let .photo(card):
            return card.channelID
        case let .text(card):
            return card.channelID
        case let .video(card):
            return card.channelID
        case let .audio(card):
            return card.channelID
        case let .pdf(card):
            return card.channelID
        }
    }

    /// Service-facing headline derived from the underlying card content.
    var serviceHeadline: String {
        switch self {
        case let .photo(card):
            return card.serviceHeadline
        case let .text(card):
            return card.serviceHeadline
        case let .video(card):
            return card.serviceHeadline
        case let .audio(card):
            return card.serviceHeadline
        case let .pdf(card):
            return card.serviceHeadline
        }
    }

    /// Prioritized search fields used by channel-local search ranking.
    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .photo(card):
            return card.searchFields
        case let .text(card):
            return card.searchFields
        case let .video(card):
            return card.searchFields
        case let .audio(card):
            return card.searchFields
        case let .pdf(card):
            return card.searchFields
        }
    }
}

extension ChannelCardContent {
    var localFeedCardModel: LocalFeedCardModel {
        LocalFeedCardModel(
            id: id,
            channelID: channelID,
            createdAt: createdAt,
            kind: kind,
            orderedTextContent: orderedTextContent,
            sourceContent: sourceContent,
            mediaContent: mediaContent
        )
    }

    var newsFeedCard: NewsFeedCard {
        let localCard = localFeedCardModel

        switch kind {
        case .text:
            return .text(.local(localCard))
        case .photo:
            return .photo(.local(localCard))
        case .video:
            return .video(.local(localCard))
        case .audio:
            return .audio(.local(localCard))
        case .pdf:
            return .pdf(.local(localCard))
        }
    }
}

private extension ChannelCardKind {
    var feedKind: NewsFeedCardKind {
        switch self {
        case .text:
            return .text
        case .photo:
            return .photo
        case .video:
            return .video
        case .audio:
            return .audio
        case .pdf:
            return .pdf
        }
    }
}

/// Presentation model for the featured article card.
struct PhotoCardModel: Identifiable, Equatable, Sendable {
    let id: String
    let channelID: String
    let postedInPrefix: String
    let sourceTitle: String
    let brandTitle: String
    let headline: String
    let summary: String
    let metadataLine: String
    let translationLabel: String
    let commentCount: Int
    let actions: [PhotoActionItem]
    let uiState: PhotoCardUIState

    /// Headline formatted for service consumers that should not receive multiline text.
    var serviceHeadline: String {
        headline.replacingOccurrences(of: "\n", with: " ")
    }

    /// Destination payload used by callers that open article details.
    var detailRoute: NewsRoute {
        NewsRoute(
            destinationID: "photo-details",
            title: serviceHeadline,
            subtitle: sourceTitle,
            bodyText: summary,
            accentLabel: translationLabel
        )
    }

    /// Returns a copy with updated runtime-only card UI state.
    func updatingUIState(_ transform: (PhotoCardUIState) -> PhotoCardUIState) -> PhotoCardModel {
        PhotoCardModel(
            id: id,
            channelID: channelID,
            postedInPrefix: postedInPrefix,
            sourceTitle: sourceTitle,
            brandTitle: brandTitle,
            headline: headline,
            summary: summary,
            metadataLine: metadataLine,
            translationLabel: translationLabel,
            commentCount: commentCount,
            actions: actions,
            uiState: transform(uiState)
        )
    }

    /// Returns a copy with refreshed article content while keeping runtime state local to the screen.
    func updatingContent(
        headline: String? = nil,
        summary: String? = nil,
        metadataLine: String? = nil
    ) -> PhotoCardModel {
        PhotoCardModel(
            id: id,
            channelID: channelID,
            postedInPrefix: postedInPrefix,
            sourceTitle: sourceTitle,
            brandTitle: brandTitle,
            headline: headline ?? self.headline,
            summary: summary ?? self.summary,
            metadataLine: metadataLine ?? self.metadataLine,
            translationLabel: translationLabel,
            commentCount: commentCount,
            actions: actions,
            uiState: uiState
        )
    }
}

/// Presentation model for a single action shown under an article.
struct PhotoActionItem: Identifiable, Equatable, Sendable {
    let id: String
    let kind: PhotoActionKind
    let systemName: String
    let title: String
}

/// Semantic action kind shown under a featured article card.
enum PhotoActionKind: String, Codable, Equatable, Sendable {
    case like
    case comments
}

/// Intent emitted from the featured article card UI.
enum PhotoCardAction: Equatable, Sendable {
    case toggleLike
    case addComment
    case setDisplayMode(PhotoCardDisplayMode)
    case refreshContent
    case runLongTask
}

/// Runtime-only UI state owned by the screen for a featured article card.
struct PhotoCardUIState: Equatable, Sendable {
    let isLiked: Bool
    let displayMode: PhotoCardDisplayMode
    let pendingOperation: PhotoCardPendingOperation?
    let inlineStatusMessage: String?

    /// When true, the screen should serialize actions for this card and keep the visible
    /// snapshot stable until the current operation completes.
    /// Whether destructive or network-backed card actions should be temporarily disabled.
    var blocksActions: Bool {
        pendingOperation != nil
    }

    /// Default interaction state for cards loaded from persistence or stub content.
    static let idle = PhotoCardUIState(
        isLiked: false,
        displayMode: .expanded,
        pendingOperation: nil,
        inlineStatusMessage: nil
    )
}

/// Visual layout variant currently used to render the featured article card.
enum PhotoCardDisplayMode: String, Codable, Equatable, Sendable {
    case expanded
    case compact
}

/// Long-running card operation currently visible in the list.
enum PhotoCardPendingOperation: Equatable, Sendable {
    case liking
    case addingComment
    case updatingDisplayMode
    case refreshingContent
    case updatingContent

    /// User-facing status text for inline progress rendering.
    var statusText: String {
        switch self {
        case .liking:
            return AppLocalization.text("news.photo.pending.like")
        case .addingComment:
            return AppLocalization.text("news.photo.pending.comment")
        case .updatingDisplayMode:
            return AppLocalization.text("news.photo.pending.displayMode")
        case .refreshingContent:
            return AppLocalization.text("news.photo.pending.refresh")
        case .updatingContent:
            return AppLocalization.text("news.photo.pending.update")
        }
    }
}

/// Presentation model for the discussion preview card.
struct TextCardModel: Identifiable, Equatable, Sendable {
    let id: String
    let channelID: String
    let categoryTitle: String
    let headline: String
    let participants: [TextCardParticipant]
    let replyCount: Int
    let joinedCount: Int
    let uiState: TextCardUIState

    /// Headline formatted for service consumers that should not receive multiline text.
    var serviceHeadline: String {
        headline.replacingOccurrences(of: "\n", with: " ")
    }

    /// User-facing joined label rendered in the discussion card footer.
    var joinedText: String {
        AppLocalization.text("news.text.joinedCountFormat", joinedCount)
    }

    /// Destination payload used by callers that open discussion details.
    var detailRoute: NewsRoute {
        NewsRoute(
            destinationID: "text-details",
            title: categoryTitle,
            subtitle: joinedText,
            bodyText: serviceHeadline,
            accentLabel: nil
        )
    }

    /// Returns a copy with updated runtime-only discussion UI state.
    func updatingUIState(_ transform: (TextCardUIState) -> TextCardUIState) -> TextCardModel {
        TextCardModel(
            id: id,
            channelID: channelID,
            categoryTitle: categoryTitle,
            headline: headline,
            participants: participants,
            replyCount: replyCount,
            joinedCount: joinedCount,
            uiState: transform(uiState)
        )
    }

    /// Returns a copy with refreshed discussion content while preserving runtime state.
    func updatingContent(
        headline: String? = nil,
        participants: [TextCardParticipant]? = nil,
        replyCount: Int? = nil,
        joinedCount: Int? = nil
    ) -> TextCardModel {
        TextCardModel(
            id: id,
            channelID: channelID,
            categoryTitle: categoryTitle,
            headline: headline ?? self.headline,
            participants: participants ?? self.participants,
            replyCount: replyCount ?? self.replyCount,
            joinedCount: joinedCount ?? self.joinedCount,
            uiState: uiState
        )
    }
}

/// Presentation model describing a participant avatar in a discussion preview.
struct TextCardParticipant: Identifiable, Equatable, Sendable {
    let id: String
    let initials: String
    let isHighlighted: Bool
}

/// Intent emitted from the discussion card UI.
enum TextCardAction: Equatable, Sendable {
    case toggleParticipation
    case addReply
    case setDisplayMode(TextCardDisplayMode)
    case refreshContent
    case runLongTask
}

/// Runtime-only UI state owned by the screen for a discussion card.
struct TextCardUIState: Equatable, Sendable {
    let isParticipating: Bool
    let displayMode: TextCardDisplayMode
    let pendingOperation: TextCardPendingOperation?
    let inlineStatusMessage: String?

    /// When true, the screen should serialize actions for this card and keep the visible
    /// snapshot stable until the current operation completes.
    var blocksActions: Bool {
        pendingOperation != nil
    }

    static let idle = TextCardUIState(
        isParticipating: false,
        displayMode: .expanded,
        pendingOperation: nil,
        inlineStatusMessage: nil
    )
}

/// Visual layout variant currently used to render the discussion card.
enum TextCardDisplayMode: String, Codable, Equatable, Sendable {
    case expanded
    case compact
}

/// Long-running card operation currently visible in a discussion card.
enum TextCardPendingOperation: Equatable, Sendable {
    case togglingParticipation
    case addingReply
    case updatingDisplayMode
    case refreshingContent
    case updatingContent

    var statusText: String {
        switch self {
        case .togglingParticipation:
            return AppLocalization.text("news.text.pending.participation")
        case .addingReply:
            return AppLocalization.text("news.text.pending.reply")
        case .updatingDisplayMode:
            return AppLocalization.text("news.text.pending.displayMode")
        case .refreshingContent:
            return AppLocalization.text("news.text.pending.refresh")
        case .updatingContent:
            return AppLocalization.text("news.text.pending.update")
        }
    }
}

/// App-level fallback content used while the real feed is still loading or unavailable.
enum NewsFeedFixtures {
    static let fallbackContent = makeFallbackContent(channelID: AppChannel.defaultChannel.id)

    static func makeFallbackContent(channelID: String) -> NewsFeedContent {
        NewsFeedContent(
            cards: [
                .photo(
                    .remote(
                        PhotoCardModel(
                            id: "featured-article-fallback",
                            channelID: channelID,
                            postedInPrefix: AppLocalization.text("news.fallback.postedInPrefix"),
                            sourceTitle: AppLocalization.text("news.fallback.sourceTitle"),
                            brandTitle: AppLocalization.text("news.fallback.brandTitle"),
                            headline: AppLocalization.text("news.fallback.headline"),
                            summary: AppLocalization.text("news.fallback.summary"),
                            metadataLine: AppLocalization.text("news.fallback.metadataLine"),
                            translationLabel: AppLocalization.text("news.fallback.translationLabel"),
                            commentCount: 48,
                            actions: [
                                PhotoActionItem(
                                    id: "like",
                                    kind: .like,
                                    systemName: "hand.thumbsup.fill",
                                    title: AppLocalization.text("news.fallback.action.like")
                                ),
                                PhotoActionItem(
                                    id: "comments",
                                    kind: .comments,
                                    systemName: "bubble.left.fill",
                                    title: AppLocalization.text("news.fallback.action.comments")
                                )
                            ],
                            uiState: .idle
                        )
                    )
                ),
                .text(
                    .remote(
                        TextCardModel(
                            id: "text-fallback",
                            channelID: channelID,
                            categoryTitle: AppLocalization.text("news.fallback.discussion.category"),
                            headline: AppLocalization.text("news.fallback.discussion.headline"),
                            participants: [
                                TextCardParticipant(id: "adorlee", initials: "A", isHighlighted: true),
                                TextCardParticipant(id: "mattis", initials: "M", isHighlighted: false),
                                TextCardParticipant(id: "sophia", initials: "S", isHighlighted: false)
                            ],
                            replyCount: 12,
                            joinedCount: 12,
                            uiState: .idle
                        )
                    )
                )
            ],
            availability: .live
        )
    }
}
