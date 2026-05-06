import Foundation
import Observation

@MainActor
@Observable
final class FeedComposerViewModel {
    var selectedChannelID: String
    var text: String
    var headline: String
    var subheadline: String
    var source: String
    private(set) var showsHeadlineField: Bool
    private(set) var showsSubheadlineField: Bool
    private(set) var showsSourceField: Bool
    private(set) var mediaKind: ChannelCardMediaKind?
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
        self.showsHeadlineField = false
        self.showsSubheadlineField = false
        self.showsSourceField = false
    }

    var availableChannels: [AppChannel] {
        channelsStore.selectionSnapshot.availableChannels
    }

    var selectedChannelTitle: String {
        availableChannels.first(where: { $0.id == selectedChannelID })?.title ?? "Channel"
    }

    var canPublish: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || mediaKind != nil
    }

    var availableInsertions: [FeedComposerInsertion] {
        var insertions: [FeedComposerInsertion] = []

        if mediaKind == nil {
            insertions.append(.photoOrVideo)
            insertions.append(.audio)
            insertions.append(.pdf)
        }

        if !showsHeadlineField {
            insertions.append(.headline)
        }
        if !showsSubheadlineField {
            insertions.append(.subheadline)
        }
        if !showsSourceField {
            insertions.append(.source)
        }

        return insertions
    }

    func selectChannel(id: String) {
        selectedChannelID = id
    }

    func applyInsertion(_ insertion: FeedComposerInsertion) {
        switch insertion {
        case .photoOrVideo:
            if mediaKind == nil {
                mediaKind = .photo
            }
        case .audio:
            if mediaKind == nil {
                mediaKind = .audio
            }
        case .pdf:
            if mediaKind == nil {
                mediaKind = .pdf
            }
        case .headline:
            showsHeadlineField = true
        case .subheadline:
            showsSubheadlineField = true
        case .source:
            showsSourceField = true
        }
    }

    @discardableResult
    func publish() -> ChannelCardContent? {
        guard canPublish else {
            return nil
        }

        let resolvedKind: ChannelCardKind
        switch mediaKind {
        case .photo:
            resolvedKind = .photo
        case .video:
            resolvedKind = .video
        case .audio:
            resolvedKind = .audio
        case .pdf:
            resolvedKind = .pdf
        case nil:
            resolvedKind = .text
        }

        let card = ChannelCardContent(
            id: UUID().uuidString,
            channelID: selectedChannelID,
            createdAt: Date(),
            kind: resolvedKind,
            text: normalized(text),
            headline: normalized(headline),
            subheadline: normalized(subheadline),
            source: normalized(source),
            mediaKind: mediaKind
        )
        channelCardStore.publish(card)
        return card
    }

    private func normalized(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
