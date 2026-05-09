import Foundation
import XCTest
import TchopShareSupport
@testable import TchopApp

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

    @MainActor
    func testSharedLocalFeedCardSyncMovesPendingCardsIntoLocalRuntimeStore() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileManager = TestAppGroupFileManager(containerURL: rootURL)
        let store = try AppGroupJSONItemDirectoryStore<LocalFeedCardModel>(
            groupIdentifier: "group.test.share-runtime",
            directoryName: "pending-share-cards",
            fileManager: fileManager
        )
        let syncManager = SharedLocalFeedCardSyncManager(store: store)
        let localFeedCardStore = LocalFeedCardStore()
        let card = LocalFeedCardModel(
            id: "shared-card-1",
            channelID: "channel-1",
            createdAt: Date(timeIntervalSince1970: 1),
            kind: .text,
            orderedTextContent: [
                LocalFeedTextContent(kind: .text, text: "Shared text")
            ],
            sourceContent: nil,
            mediaContent: nil
        )

        try syncManager.publishImportedCard(card)

        let syncedCount = try syncManager.syncPendingCards(into: localFeedCardStore)

        XCTAssertEqual(syncedCount, 1)
        XCTAssertEqual(localFeedCardStore.cards(for: "channel-1").map(\.id), ["shared-card-1"])
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
