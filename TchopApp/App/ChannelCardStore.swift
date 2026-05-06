import Foundation
import Observation

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
