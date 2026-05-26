import Foundation
import XCTest
import TchopShareSupport
@testable import TchopApp

/// Verifies share-extension imported content maps into the shared composer/feed-card contract.
final class ShareExtensionRuntimeContractTests: XCTestCase {
    func testImportedTextMergesIntoDraftTextField() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        try draft.applyImportedItems([
            .text(ShareImportedTextItem(text: "Shared text"))
        ])

        XCTAssertEqual(draft.textValue(for: .text), "Shared text")
        XCTAssertEqual(draft.effectiveKind, .text)
    }

    func testImportedImageBatchCreatesPhotoCard() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        try draft.applyImportedItems([
            .file(makeFileItem(kind: .image, filename: "photo-1.jpg")),
            .file(makeFileItem(kind: .image, filename: "photo-2.jpg"))
        ])

        XCTAssertEqual(draft.effectiveKind, .photo)
        XCTAssertEqual(draft.photoItems.count, 2)
        XCTAssertEqual(draft.photoItems.map(\.displayTitle), ["photo-1.jpg", "photo-2.jpg"])
    }

    func testImportedTextAndImageKeepPhotoAsPrimaryKind() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        try draft.applyImportedItems([
            .text(ShareImportedTextItem(text: "Shared caption")),
            .file(makeFileItem(kind: .image, filename: "photo.jpg"))
        ])

        XCTAssertEqual(draft.textValue(for: .text), "Shared caption")
        XCTAssertEqual(draft.effectiveKind, .photo)
        XCTAssertEqual(draft.photoItems.count, 1)
    }

    func testImportedVideoCreatesVideoCard() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        try draft.applyImportedItems([
            .file(makeFileItem(kind: .video, filename: "clip.mov"))
        ])

        XCTAssertEqual(draft.effectiveKind, .video)
        XCTAssertEqual(draft.media?.displayTitle, "clip.mov")
    }

    func testImportedAudioCreatesAudioCard() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        try draft.applyImportedItems([
            .file(makeFileItem(kind: .audio, filename: "voice.m4a"))
        ])

        XCTAssertEqual(draft.effectiveKind, .audio)
        XCTAssertEqual(draft.media?.displayTitle, "voice.m4a")
    }

    func testImportedPDFCreatesPDFCard() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        try draft.applyImportedItems([
            .file(makeFileItem(kind: .pdf, filename: "doc.pdf"))
        ])

        XCTAssertEqual(draft.effectiveKind, .pdf)
        XCTAssertEqual(draft.media?.displayTitle, "doc.pdf")
    }

    func testMixedImportedMediaTypesThrowExplicitError() {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        XCTAssertThrowsError(
            try draft.applyImportedItems([
                .file(makeFileItem(kind: .image, filename: "photo.jpg")),
                .file(makeFileItem(kind: .video, filename: "clip.mov"))
            ])
        ) { error in
            XCTAssertEqual(error as? FeedComposerImportError, .unsupportedMixedMediaAttachments)
        }
    }

    func testMultipleImportedFilesThrowExplicitError() {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        XCTAssertThrowsError(
            try draft.applyImportedItems([
                .file(makeFileItem(kind: .video, filename: "clip.mov")),
                .file(makeFileItem(kind: .pdf, filename: "doc.pdf"))
            ])
        ) { error in
            XCTAssertEqual(error as? FeedComposerImportError, .unsupportedMultipleFileAttachments)
        }
    }

    func testRemovingImportedPrimaryMediaRecalculatesCardKindToText() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        try draft.applyImportedItems([
            .text(ShareImportedTextItem(text: "Shared text")),
            .file(makeFileItem(kind: .video, filename: "clip.mov"))
        ])

        XCTAssertEqual(draft.effectiveKind, .video)

        draft.removeMedia()

        XCTAssertEqual(draft.effectiveKind, .text)
        XCTAssertEqual(draft.textValue(for: .text), "Shared text")
    }

    func testImportedImageBatchCapsPhotoCardAtTenItems() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")
        let importedImages = (1...12).map { index in
            ShareImportedItem.file(makeFileItem(kind: .image, filename: "photo-\(index).jpg"))
        }

        try draft.applyImportedItems(importedImages)

        XCTAssertEqual(draft.effectiveKind, .photo)
        XCTAssertEqual(draft.photoItems.count, 10)
        XCTAssertEqual(draft.photoItems.first?.displayTitle, "photo-1.jpg")
        XCTAssertEqual(draft.photoItems.last?.displayTitle, "photo-10.jpg")
    }

    func testImportedImageIntoExistingFileMediaThrowsExplicitError() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")
        draft.selectPickedFile(kind: .video, displayTitle: "clip.mov", fileURL: nil)

        XCTAssertThrowsError(
            try draft.applyImportedItems([
                .file(makeFileItem(kind: .image, filename: "photo.jpg"))
            ])
        ) { error in
            XCTAssertEqual(error as? FeedComposerImportError, .incompatibleWithExistingMedia)
        }
    }

    func testDraftDoesNotPublishEmptyTextOnlyContent() {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        draft.updateText("   ", for: .text)

        XCTAssertFalse(draft.canPublish)
        XCTAssertNil(draft.effectiveKind)
        XCTAssertNil(draft.makeCard())
    }

    func testDraftLimitsImportedTextToComposerMaximumLength() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")

        try draft.applyImportedItems([
            .text(ShareImportedTextItem(text: String(repeating: "a", count: 250)))
        ])

        XCTAssertEqual(draft.textValue(for: .text).count, 200)
        XCTAssertTrue(draft.canPublish)
    }

    func testDraftPublishesSourceNeutralFileMediaMetadata() throws {
        var draft = FeedComposerDraft(selectedChannelID: "channel-1")
        let videoURL = URL(fileURLWithPath: "/tmp/clip.mov")
        let teaserURL = URL(fileURLWithPath: "/tmp/teaser.jpg")

        draft.selectPickedFile(kind: .video, displayTitle: "clip.mov", fileURL: videoURL)
        draft.updateText("Video text", for: .text)
        draft.showFileCaptionField()
        draft.updateFileCaption("Clip caption")
        draft.addOrReplaceTeaserImage(displayTitle: "teaser.jpg", fileURL: teaserURL)
        draft.showTeaserCopyrightField()
        draft.updateTeaserCopyright("© Tchop")

        let feedCard = try XCTUnwrap(draft.makeCard(id: "video-card", createdAt: Date(timeIntervalSince1970: 10))?.feedCardModel)

        XCTAssertEqual(feedCard.id, "video-card")
        XCTAssertEqual(feedCard.channelID, "channel-1")
        XCTAssertEqual(feedCard.kind, .video)
        XCTAssertEqual(feedCard.textValue(for: .text), "Video text")

        guard case let .file(fileMedia) = feedCard.mediaContent else {
            XCTFail("Expected file media")
            return
        }

        XCTAssertEqual(fileMedia.kind, .video)
        XCTAssertEqual(fileMedia.displayTitle, "clip.mov")
        XCTAssertEqual(fileMedia.fileURLString, videoURL.absoluteString)
        XCTAssertEqual(fileMedia.caption, "Clip caption")
        XCTAssertEqual(fileMedia.teaserImage?.displayTitle, "teaser.jpg")
        XCTAssertEqual(fileMedia.teaserImage?.fileURLString, teaserURL.absoluteString)
        XCTAssertEqual(fileMedia.teaserImage?.copyright, "© Tchop")
    }

    @MainActor
    func testSharedFeedCardSyncMovesPendingCardsIntoRuntimeStore() async throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileManager = TestAppGroupFileManager(containerURL: rootURL)
        let store = try AppGroupJSONItemDirectoryStore<FeedCard>(
            groupIdentifier: "group.test.share-runtime",
            directoryName: "pending-share-cards",
            fileManager: fileManager
        )
        let syncManager = SharedFeedCardSyncManager(store: store)
        let feedCardStore = makeTestFeedCardStore()
        let card = FeedCard(
            id: "shared-card-1",
            channelID: "channel-1",
            createdAt: Date(timeIntervalSince1970: 1),
            kind: .text,
            orderedTextContent: [
                FeedTextContent(kind: .text, text: "Shared text")
            ],
            sourceContent: nil,
            mediaContent: nil,
            isLiked: false,
            commentsCount: 0,
            displayMode: .expanded
        )

        try await syncManager.publishImportedCard(card)

        let syncedCount = try await syncManager.syncPendingCards(into: feedCardStore)

        XCTAssertEqual(syncedCount, 1)
        XCTAssertEqual(feedCardStore.cards(for: "channel-1").map(\.id), ["shared-card-1"])
        XCTAssertTrue(try store.loadAll().isEmpty)
    }

    private func makeFileItem(kind: ShareImportedFileKind, filename: String) -> ShareImportedFileItem {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: Data(), attributes: nil)
        }

        return ShareImportedFileItem(
            kind: kind,
            originalFilename: filename,
            contentTypeIdentifier: "test.\(kind.rawValue)",
            fileURL: url
        )
    }
}

private final class TestAppGroupFileManager: FileManager, @unchecked Sendable {
    private let sharedContainerURL: URL

    init(containerURL: URL) {
        self.sharedContainerURL = containerURL
        super.init()
    }

    override func containerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL? {
        sharedContainerURL
    }
}
