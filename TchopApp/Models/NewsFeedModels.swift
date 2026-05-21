import Foundation
import TchopOnDeviceAI
import TchopShareSupport

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
    let fileURL: URL?
    let caption: String?
    let copyright: String?
}

struct ChannelCardTeaserImageContent: Equatable, Sendable, Identifiable {
    let id: String
    let displayTitle: String
    let fileURL: URL?
    let copyright: String?
}

struct ChannelCardFileMediaContent: Equatable, Sendable {
    let kind: ChannelCardMediaKind
    let displayTitle: String
    let fileURL: URL?
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
        case .headline: return "Headline"
        case .subheadline: return "Sub Heading"
        case .source: return "Source"
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

enum FeedComposerImportError: Error, Equatable, Sendable {
    case unsupportedMixedMediaAttachments
    case unsupportedMultipleFileAttachments
    case incompatibleWithExistingMedia
}

struct FeedComposerDraft: Equatable, Sendable {
    private static let maximumTextFieldCharacterCount = 200

    var selectedChannelID: String
    private(set) var visibleTextFieldKinds: Set<ChannelCardTextFieldKind>
    private(set) var textValues: [ChannelCardTextFieldKind: String]
    private(set) var sourceURLString: String?
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
        self.sourceURLString = nil
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

    var orderedVisiblePrimaryTextFieldKinds: [ChannelCardTextFieldKind] {
        orderedVisibleTextFieldKinds.filter { $0 != .source }
    }

    var isSourceFieldVisible: Bool {
        visibleTextFieldKinds.contains(.source)
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
            selectMedia(.audio, displayTitle: nil, fileURL: nil)
        case .pdf:
            selectMedia(.pdf, displayTitle: nil, fileURL: nil)
        case .text, .headline, .subheadline, .source:
            visibleTextFieldKinds.insert(insertion.textFieldKind)
        }
    }

    mutating func addPhoto() {
        addPickedPhoto(displayTitle: nil, fileURL: nil)
    }

    mutating func addPickedPhoto(displayTitle: String?, fileURL: URL?) {
        switch media {
        case nil:
            media = .photos(items: [makePhotoItem(number: 1, displayTitle: displayTitle, fileURL: fileURL)])
        case let .photos(items):
            guard items.count < 10 else {
                return
            }
            media = .photos(
                items: items + [
                    makePhotoItem(number: items.count + 1, displayTitle: displayTitle, fileURL: fileURL)
                ]
            )
        case .file:
            return
        }

        visibleTextFieldKinds.insert(.text)
    }

    mutating func selectVideo() {
        selectMedia(.video, displayTitle: nil, fileURL: nil)
    }

    mutating func selectPickedFile(kind: ChannelCardMediaKind, displayTitle: String, fileURL: URL?) {
        selectMedia(kind, displayTitle: displayTitle, fileURL: fileURL)
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

    mutating func replacePickedPhoto(id: String, displayTitle: String?, fileURL: URL?) {
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
                    displayTitle: normalizedDisplayTitle(displayTitle, fallback: item.displayTitle),
                    fileURL: fileURL,
                    caption: item.caption,
                    copyright: item.copyright
                )
            }
        )
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
                    fileURL: item.fileURL,
                    caption: normalizedOptionalEditableText(value),
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
                    fileURL: item.fileURL,
                    caption: item.caption,
                    copyright: normalizedOptionalEditableText(value)
                )
            }
        )
    }

    mutating func updateFileCaption(_ value: String?) {
        let normalizedCaption = normalizedOptionalEditableText(value)
        updateFileMedia { file in
            ChannelCardFileMediaContent(
                kind: file.kind,
                displayTitle: file.displayTitle,
                fileURL: file.fileURL,
                teaserImage: file.teaserImage,
                caption: normalizedCaption
            )
        }
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

    mutating func addOrReplaceTeaserImage(displayTitle: String = "Teaser image", fileURL: URL? = nil) {
        updateFileMedia { file in
            ChannelCardFileMediaContent(
                kind: file.kind,
                displayTitle: file.displayTitle,
                fileURL: file.fileURL,
                teaserImage: ChannelCardTeaserImageContent(
                    id: UUID().uuidString,
                    displayTitle: displayTitle,
                    fileURL: fileURL,
                    copyright: file.teaserImage?.copyright
                ),
                caption: file.caption
            )
        }
    }

    mutating func showTeaserCopyrightField() {
        guard case let .file(file) = media, file.teaserImage != nil else {
            return
        }

        isTeaserCopyrightFieldVisible = true
    }

    mutating func removeTeaserImage() {
        updateFileMedia { file in
            ChannelCardFileMediaContent(
                kind: file.kind,
                displayTitle: file.displayTitle,
                fileURL: file.fileURL,
                teaserImage: nil,
                caption: file.caption
            )
        }
        isTeaserCopyrightFieldVisible = false
    }

    mutating func removeTeaserCopyrightFieldIfEmpty() {
        guard teaserCopyrightText == nil else {
            return
        }

        isTeaserCopyrightFieldVisible = false
    }

    mutating func updateTeaserCopyright(_ value: String?) {
        let normalizedCopyright = normalizedOptionalEditableText(value)
        updateFileMedia { file in
            guard let teaserImage = file.teaserImage else {
                return file
            }

            return ChannelCardFileMediaContent(
                kind: file.kind,
                displayTitle: file.displayTitle,
                fileURL: file.fileURL,
                teaserImage: ChannelCardTeaserImageContent(
                    id: teaserImage.id,
                    displayTitle: teaserImage.displayTitle,
                    fileURL: teaserImage.fileURL,
                    copyright: normalizedCopyright
                ),
                caption: file.caption
            )
        }
    }

    mutating func updateText(_ value: String, for kind: ChannelCardTextFieldKind) {
        textValues[kind] = Self.limitedTextFieldValue(value)
    }

    mutating func updateSourceURLString(_ value: String?) {
        sourceURLString = normalizedOptionalText(value)
    }

    mutating func applyImportedItems(_ items: [ShareImportedItem]) throws {
        guard !items.isEmpty else {
            return
        }

        applyImportedTextItems(items)
        try applyImportedFileItems(items)
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
            sourceURLString: visibleTextFieldKinds.contains(.source) ? sourceURLString : nil,
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

    private func normalizedOptionalEditableText(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : value
    }

    private func photoItem(id: String) -> ChannelCardPhotoItem? {
        guard case let .photos(items) = media else {
            return nil
        }

        return items.first(where: { $0.id == id })
    }

    private mutating func applyImportedTextItems(_ importedItems: [ShareImportedItem]) {
        let importedTexts = importedItems.compactMap { item -> String? in
            guard case let .text(textItem) = item else {
                return nil
            }

            let trimmed = textItem.text.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        guard !importedTexts.isEmpty else {
            return
        }

        let combinedImportedText = importedTexts.joined(separator: "\n\n")
        let currentText = normalizedText(for: .text)
        let mergedText = [currentText, combinedImportedText]
            .compactMap { $0 }
            .joined(separator: currentText == nil ? "" : "\n\n")

        visibleTextFieldKinds.insert(.text)
        textValues[.text] = Self.limitedTextFieldValue(mergedText)
    }

    private static func limitedTextFieldValue(_ value: String) -> String {
        String(value.prefix(maximumTextFieldCharacterCount))
    }

    private mutating func applyImportedFileItems(_ importedItems: [ShareImportedItem]) throws {
        let importedFiles = importedItems.compactMap { item -> ShareImportedFileItem? in
            guard case let .file(fileItem) = item else {
                return nil
            }

            return fileItem
        }

        guard !importedFiles.isEmpty else {
            return
        }

        let imageFiles = importedFiles.filter { $0.kind == .image }
        let nonImageFiles = importedFiles.filter { $0.kind != .image }

        if !imageFiles.isEmpty && !nonImageFiles.isEmpty {
            throw FeedComposerImportError.unsupportedMixedMediaAttachments
        }

        if nonImageFiles.count > 1 {
            throw FeedComposerImportError.unsupportedMultipleFileAttachments
        }

        if !imageFiles.isEmpty {
            try applyImportedPhotoFiles(imageFiles)
            return
        }

        if let file = nonImageFiles.first {
            try applyImportedSingleFile(file)
        }
    }

    private mutating func applyImportedPhotoFiles(_ files: [ShareImportedFileItem]) throws {
        switch media {
        case nil:
            let items = files.prefix(10).enumerated().map { index, file in
                makeImportedPhotoItem(file: file, fallbackNumber: index + 1)
            }
            media = .photos(items: items)
        case let .photos(existingItems):
            let remainingCapacity = max(0, 10 - existingItems.count)
            guard remainingCapacity > 0 else {
                return
            }

            let newItems = files.prefix(remainingCapacity).enumerated().map { index, file in
                makeImportedPhotoItem(file: file, fallbackNumber: existingItems.count + index + 1)
            }
            media = .photos(items: existingItems + newItems)
        case .file:
            throw FeedComposerImportError.incompatibleWithExistingMedia
        }

        visibleTextFieldKinds.insert(.text)
    }

    private mutating func applyImportedSingleFile(_ file: ShareImportedFileItem) throws {
        guard media == nil else {
            throw FeedComposerImportError.incompatibleWithExistingMedia
        }

        let mediaKind: ChannelCardMediaKind
        switch file.kind {
        case .video:
            mediaKind = .video
        case .audio:
            mediaKind = .audio
        case .pdf:
            mediaKind = .pdf
        case .image:
            throw FeedComposerImportError.incompatibleWithExistingMedia
        }

        media = .file(
            ChannelCardFileMediaContent(
                kind: mediaKind,
                displayTitle: file.originalFilename,
                fileURL: file.fileURL,
                teaserImage: nil,
                caption: nil
            )
        )
        visibleTextFieldKinds.insert(.text)
    }

    private mutating func selectMedia(
        _ kind: ChannelCardMediaKind,
        displayTitle: String?,
        fileURL: URL?
    ) {
        guard media == nil else {
            return
        }

        isFileCaptionFieldVisible = false
        isTeaserCopyrightFieldVisible = false

        switch kind {
        case .photo:
            media = .photos(items: [makePhotoItem(number: 1, displayTitle: displayTitle, fileURL: fileURL)])
        case .video:
            media = .file(makeFileMedia(kind: .video, displayTitle: displayTitle, fileURL: fileURL))
        case .audio:
            media = .file(makeFileMedia(kind: .audio, displayTitle: displayTitle, fileURL: fileURL))
        case .pdf:
            media = .file(makeFileMedia(kind: .pdf, displayTitle: displayTitle, fileURL: fileURL))
        }

        visibleTextFieldKinds.insert(.text)
    }

    private func makePhotoItem(
        number: Int,
        displayTitle: String? = nil,
        fileURL: URL? = nil
    ) -> ChannelCardPhotoItem {
        ChannelCardPhotoItem(
            id: UUID().uuidString,
            displayTitle: normalizedDisplayTitle(displayTitle, fallback: "Photo \(number)"),
            fileURL: fileURL,
            caption: nil,
            copyright: nil
        )
    }

    private func makeImportedPhotoItem(
        file: ShareImportedFileItem,
        fallbackNumber: Int
    ) -> ChannelCardPhotoItem {
        let filename = file.originalFilename.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayTitle = filename.isEmpty ? "Photo \(fallbackNumber)" : filename

        return ChannelCardPhotoItem(
            id: UUID().uuidString,
            displayTitle: displayTitle,
            fileURL: file.fileURL,
            caption: nil,
            copyright: nil
        )
    }

    private func makeFileMedia(
        kind: ChannelCardMediaKind,
        displayTitle: String? = nil,
        fileURL: URL? = nil
    ) -> ChannelCardFileMediaContent {
        let fallbackTitle = switch kind {
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
            displayTitle: normalizedDisplayTitle(displayTitle, fallback: fallbackTitle),
            fileURL: fileURL,
            teaserImage: nil,
            caption: nil
        )
    }

    private func normalizedDisplayTitle(_ displayTitle: String?, fallback: String) -> String {
        let trimmedTitle = displayTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedTitle.isEmpty ? fallback : trimmedTitle
    }

    private mutating func updateFileMedia(
        _ transform: (ChannelCardFileMediaContent) -> ChannelCardFileMediaContent
    ) {
        guard case let .file(file) = media else {
            return
        }

        media = .file(transform(file))
    }
}

struct ChannelCardTextContent: Equatable, Sendable, Identifiable {
    let kind: ChannelCardTextFieldKind
    let text: String

    var id: ChannelCardTextFieldKind { kind }
}

struct FeedSourceContent: Codable, Equatable, Sendable {
    let text: String
    let resourceURLString: String?
}

struct FeedPhotoItem: Codable, Equatable, Sendable, Identifiable {
    let id: String
    let displayTitle: String
    let fileURLString: String?
    let caption: String?
    let copyright: String?
}

struct FeedTeaserImageContent: Codable, Equatable, Sendable, Identifiable {
    let id: String
    let displayTitle: String
    let fileURLString: String?
    let copyright: String?
}

enum FeedMediaKind: String, Codable, Equatable, Sendable {
    case photo
    case video
    case audio
    case pdf
}

struct FeedFileMediaContent: Codable, Equatable, Sendable {
    let kind: FeedMediaKind
    let displayTitle: String
    let fileURLString: String?
    let teaserImage: FeedTeaserImageContent?
    let caption: String?
}

enum FeedMediaContent: Codable, Equatable, Sendable {
    case photos(items: [FeedPhotoItem])
    case file(FeedFileMediaContent)
}

enum FeedTextFieldKind: String, CaseIterable, Codable, Equatable, Sendable, Identifiable {
    case text
    case headline
    case subheadline
    case source

    var id: String { rawValue }
}

struct FeedTextContent: Codable, Equatable, Sendable, Identifiable {
    let kind: FeedTextFieldKind
    let text: String

    var id: FeedTextFieldKind { kind }
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

struct FeedCard: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let channelID: String
    let createdAt: Date
    let kind: NewsFeedCardKind
    let orderedTextContent: [FeedTextContent]
    let sourceContent: FeedSourceContent?
    let mediaContent: FeedMediaContent?
    let isLiked: Bool
    let commentsCount: Int
    let displayMode: FeedCardDisplayMode

    private enum CodingKeys: String, CodingKey {
        case id
        case channelID
        case createdAt
        case kind
        case orderedTextContent
        case sourceContent
        case mediaContent
        case isLiked
        case commentsCount
        case displayMode
    }

    init(
        id: String,
        channelID: String,
        createdAt: Date,
        kind: NewsFeedCardKind,
        orderedTextContent: [FeedTextContent],
        sourceContent: FeedSourceContent?,
        mediaContent: FeedMediaContent?,
        isLiked: Bool,
        commentsCount: Int,
        displayMode: FeedCardDisplayMode
    ) {
        self.id = id
        self.channelID = channelID
        self.createdAt = createdAt
        self.kind = kind
        self.orderedTextContent = orderedTextContent
        self.sourceContent = sourceContent
        self.mediaContent = mediaContent
        self.isLiked = isLiked
        self.commentsCount = commentsCount
        self.displayMode = displayMode
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        channelID = try container.decode(String.self, forKey: .channelID)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        kind = try container.decode(NewsFeedCardKind.self, forKey: .kind)
        orderedTextContent = try container.decode([FeedTextContent].self, forKey: .orderedTextContent)
        sourceContent = try container.decodeIfPresent(FeedSourceContent.self, forKey: .sourceContent)
        mediaContent = try container.decodeIfPresent(FeedMediaContent.self, forKey: .mediaContent)
        isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
        commentsCount = try container.decodeIfPresent(Int.self, forKey: .commentsCount) ?? 0
        displayMode = try container.decodeIfPresent(FeedCardDisplayMode.self, forKey: .displayMode) ?? .expanded
    }

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

    func textValue(for kind: FeedTextFieldKind) -> String? {
        orderedTextContent.first(where: { $0.kind == kind })?.text
    }

    func translated(using snapshot: CardTranslationSnapshot?) -> FeedCard {
        guard let snapshot else {
            return self
        }

        return FeedCard(
            id: id,
            channelID: channelID,
            createdAt: createdAt,
            kind: kind,
            orderedTextContent: orderedTextContent.map { textContent in
                guard let fieldID = textContent.kind.translationFieldID else {
                    return textContent
                }

                return FeedTextContent(
                    kind: textContent.kind,
                    text: snapshot.text(for: fieldID) ?? textContent.text
                )
            },
            sourceContent: sourceContent,
            mediaContent: mediaContent,
            isLiked: isLiked,
            commentsCount: commentsCount,
            displayMode: displayMode
        )
    }

    func replacingInteractionState(
        isLiked: Bool? = nil,
        commentsCount: Int? = nil,
        displayMode: FeedCardDisplayMode? = nil
    ) -> FeedCard {
        FeedCard(
            id: id,
            channelID: channelID,
            createdAt: createdAt,
            kind: kind,
            orderedTextContent: orderedTextContent,
            sourceContent: sourceContent,
            mediaContent: mediaContent,
            isLiked: isLiked ?? self.isLiked,
            commentsCount: commentsCount ?? self.commentsCount,
            displayMode: displayMode ?? self.displayMode
        )
    }
}

enum FeedCardDisplayMode: String, Codable, Equatable, Sendable {
    case expanded
    case compact
}

enum CardTranslationFieldID: String, Hashable, Codable, Sendable {
    case text
    case headline
    case subheadline
    case photoBrandTitle
    case photoHeadline
    case photoSummary
    case photoMetadataLine
    case photoTranslationLabel
    case textCategoryTitle
    case textHeadline

    var sortOrder: Int {
        switch self {
        case .text:
            return 0
        case .headline:
            return 1
        case .subheadline:
            return 2
        case .photoBrandTitle:
            return 10
        case .photoHeadline:
            return 11
        case .photoSummary:
            return 12
        case .photoMetadataLine:
            return 13
        case .photoTranslationLabel:
            return 14
        case .textCategoryTitle:
            return 20
        case .textHeadline:
            return 21
        }
    }
}

struct CardTranslationSnapshot: Equatable, Codable, Sendable {
    let cardID: String
    let targetLanguageIdentifier: String
    let translatedTexts: [CardTranslationFieldID: String]

    func text(for fieldID: CardTranslationFieldID) -> String? {
        translatedTexts[fieldID]
    }
}

struct NewsFeedCardTranslationPayload: Equatable, Sendable {
    let cardID: String
    let fields: [CardTranslationFieldID: String]

    var isEmpty: Bool {
        fields.isEmpty
    }

    func makeRequest(
        sourceLanguage: OnDeviceLanguage?,
        targetLanguage: OnDeviceLanguage
    ) -> OnDeviceTranslationRequest {
        let orderedSegments: [OnDeviceTranslationSegment] = fields.keys
            .sorted(by: { $0.sortOrder < $1.sortOrder })
            .map { fieldID in
                OnDeviceTranslationSegment(
                    id: fieldID.rawValue,
                    text: fields[fieldID] ?? ""
                )
            }

        return OnDeviceTranslationRequest(
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            segments: orderedSegments
        )
    }

    static func snapshot(
        cardID: String,
        targetLanguageIdentifier: String,
        result: OnDeviceTranslationResult
    ) -> CardTranslationSnapshot {
        let translatedTexts = result.segments.reduce(into: [CardTranslationFieldID: String]()) {
            partialResult,
            segment in
            guard let fieldID = CardTranslationFieldID(rawValue: segment.id) else {
                return
            }

            partialResult[fieldID] = segment.text
        }

        return CardTranslationSnapshot(
            cardID: cardID,
            targetLanguageIdentifier: targetLanguageIdentifier,
            translatedTexts: translatedTexts
        )
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
enum NewsFeedCardKind: String, Codable, Equatable, Sendable {
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
    case card(FeedCard)

    var id: String {
        switch self {
        case let .card(card):
            return card.id
        }
    }

    var channelID: String {
        switch self {
        case let .card(card):
            return card.channelID
        }
    }

    var serviceHeadline: String {
        switch self {
        case let .card(card):
            return card.serviceHeadline
        }
    }

    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .card(card):
            return card.searchFields
        }
    }
}

enum NewsFeedTextCardContent: Identifiable, Equatable, Sendable {
    case card(FeedCard)

    var id: String {
        switch self {
        case let .card(card):
            return card.id
        }
    }

    var channelID: String {
        switch self {
        case let .card(card):
            return card.channelID
        }
    }

    var serviceHeadline: String {
        switch self {
        case let .card(card):
            return card.serviceHeadline
        }
    }

    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .card(card):
            return card.searchFields
        }
    }
}

enum NewsFeedVideoCardContent: Identifiable, Equatable, Sendable {
    case card(FeedCard)

    var id: String {
        switch self {
        case let .card(card):
            return card.id
        }
    }

    var channelID: String {
        switch self {
        case let .card(card):
            return card.channelID
        }
    }

    var serviceHeadline: String {
        switch self {
        case let .card(card):
            return card.serviceHeadline
        }
    }

    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .card(card):
            return card.searchFields
        }
    }
}

enum NewsFeedAudioCardContent: Identifiable, Equatable, Sendable {
    case card(FeedCard)

    var id: String {
        switch self {
        case let .card(card):
            return card.id
        }
    }

    var channelID: String {
        switch self {
        case let .card(card):
            return card.channelID
        }
    }

    var serviceHeadline: String {
        switch self {
        case let .card(card):
            return card.serviceHeadline
        }
    }

    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .card(card):
            return card.searchFields
        }
    }
}

enum NewsFeedPDFCardContent: Identifiable, Equatable, Sendable {
    case card(FeedCard)

    var id: String {
        switch self {
        case let .card(card):
            return card.id
        }
    }

    var channelID: String {
        switch self {
        case let .card(card):
            return card.channelID
        }
    }

    var serviceHeadline: String {
        switch self {
        case let .card(card):
            return card.serviceHeadline
        }
    }

    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .card(card):
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

    var translationPayload: NewsFeedCardTranslationPayload {
        switch self {
        case let .photo(content):
            return content.translationPayload
        case let .text(content):
            return content.translationPayload
        case let .video(content):
            return content.translationPayload
        case let .audio(content):
            return content.translationPayload
        case let .pdf(content):
            return content.translationPayload
        }
    }
}

extension ChannelCardContent {
    var feedCardModel: FeedCard {
        FeedCard(
            id: id,
            channelID: channelID,
            createdAt: createdAt,
            kind: kind.feedKind,
            orderedTextContent: orderedTextContent.map(\.feedTextContent),
            sourceContent: sourceContent?.feedSourceContent,
            mediaContent: mediaContent?.feedMediaContent,
            isLiked: false,
            commentsCount: 0,
            displayMode: .expanded
        )
    }
}

extension FeedCard {
    var newsFeedCard: NewsFeedCard {
        switch kind {
        case .text:
            return .text(.card(self))
        case .photo:
            return .photo(.card(self))
        case .video:
            return .video(.card(self))
        case .audio:
            return .audio(.card(self))
        case .pdf:
            return .pdf(.card(self))
        }
    }

    var detailRoute: NewsRoute {
        let titleText = textValue(for: .headline)
            ?? textValue(for: .text)
            ?? serviceHeadline
        let bodyText = textValue(for: .text)
            ?? textValue(for: .subheadline)
            ?? titleText
        let subtitleText = sourceContent?.text ?? AppLocalization.text("news.feed.sourceFallback")

        return NewsRoute(
            cardID: id,
            destinationID: kind == .text ? "text-details" : "photo-details",
            title: titleText,
            subtitle: subtitleText,
            bodyText: bodyText,
            accentLabel: nil
        )
    }
}

private extension NewsFeedPhotoCardContent {
    var translationPayload: NewsFeedCardTranslationPayload {
        switch self {
        case let .card(card):
            return card.translationPayload
        }
    }
}

private extension NewsFeedTextCardContent {
    var translationPayload: NewsFeedCardTranslationPayload {
        switch self {
        case let .card(card):
            return card.translationPayload
        }
    }
}

private extension NewsFeedVideoCardContent {
    var translationPayload: NewsFeedCardTranslationPayload {
        switch self {
        case let .card(card):
            return card.translationPayload
        }
    }
}

private extension NewsFeedAudioCardContent {
    var translationPayload: NewsFeedCardTranslationPayload {
        switch self {
        case let .card(card):
            return card.translationPayload
        }
    }
}

private extension NewsFeedPDFCardContent {
    var translationPayload: NewsFeedCardTranslationPayload {
        switch self {
        case let .card(card):
            return card.translationPayload
        }
    }
}

private extension FeedCard {
    var translationPayload: NewsFeedCardTranslationPayload {
        let fields = orderedTextContent.reduce(into: [CardTranslationFieldID: String?]()) { partialResult, textContent in
            guard let fieldID = textContent.kind.translationFieldID else {
                return
            }

            partialResult[fieldID] = normalizedTranslationText(textContent.text)
        }

        return NewsFeedCardTranslationPayload(cardID: id, fields: fields.compactTranslationFields)
    }
}

private extension FeedTextFieldKind {
    var translationFieldID: CardTranslationFieldID? {
        switch self {
        case .text:
            return .text
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .source:
            return nil
        }
    }
}

private extension Dictionary where Key == CardTranslationFieldID, Value == String? {
    var compactTranslationFields: [CardTranslationFieldID: String] {
        reduce(into: [CardTranslationFieldID: String]()) { partialResult, entry in
            guard let value = entry.value else {
                return
            }

            partialResult[entry.key] = value
        }
    }
}

private func normalizedTranslationText(_ value: String) -> String? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
}

private extension ChannelCardSourceContent {
    var feedSourceContent: FeedSourceContent {
        FeedSourceContent(
            text: text,
            resourceURLString: resourceURLString
        )
    }
}

private extension ChannelCardPhotoItem {
    var feedPhotoItem: FeedPhotoItem {
        FeedPhotoItem(
            id: id,
            displayTitle: displayTitle,
            fileURLString: fileURL?.absoluteString,
            caption: caption,
            copyright: copyright
        )
    }
}

private extension ChannelCardTeaserImageContent {
    var feedTeaserImageContent: FeedTeaserImageContent {
        FeedTeaserImageContent(
            id: id,
            displayTitle: displayTitle,
            fileURLString: fileURL?.absoluteString,
            copyright: copyright
        )
    }
}

private extension ChannelCardMediaKind {
    var feedMediaKind: FeedMediaKind {
        switch self {
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

private extension ChannelCardFileMediaContent {
    var feedFileMediaContent: FeedFileMediaContent {
        FeedFileMediaContent(
            kind: kind.feedMediaKind,
            displayTitle: displayTitle,
            fileURLString: fileURL?.absoluteString,
            teaserImage: teaserImage?.feedTeaserImageContent,
            caption: caption
        )
    }
}

private extension ChannelCardMediaContent {
    var feedMediaContent: FeedMediaContent {
        switch self {
        case let .photos(items):
            return .photos(items: items.map(\.feedPhotoItem))
        case let .file(file):
            return .file(file.feedFileMediaContent)
        }
    }
}

private extension ChannelCardTextFieldKind {
    var feedTextFieldKind: FeedTextFieldKind {
        switch self {
        case .text:
            return .text
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .source:
            return .source
        }
    }
}

private extension ChannelCardTextContent {
    var feedTextContent: FeedTextContent {
        FeedTextContent(
            kind: kind.feedTextFieldKind,
            text: text
        )
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
