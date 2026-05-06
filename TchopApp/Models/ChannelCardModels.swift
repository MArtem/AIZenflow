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

enum ChannelCardTextFieldKind: String, CaseIterable, Equatable, Sendable, Identifiable {
    case text
    case headline
    case subheadline
    case source

    var id: String { rawValue }

    var title: String {
        switch self {
        case .text:
            return "Text"
        case .headline:
            return "Headline"
        case .subheadline:
            return "Subheadline"
        case .source:
            return "Source"
        }
    }

    var placeholder: String {
        switch self {
        case .text:
            return "Enter card text..."
        case .headline:
            return "Add headline"
        case .subheadline:
            return "Add subheadline"
        case .source:
            return "Add source"
        }
    }
}

enum FeedComposerInsertion: Equatable, Sendable, Identifiable {
    case photoOrVideo
    case audio
    case pdf
    case headline
    case subheadline
    case source

    var id: String { title }

    var title: String {
        switch self {
        case .photoOrVideo:
            return "Photo or Video"
        case .audio:
            return "Audio"
        case .pdf:
            return "PDF"
        case .headline:
            return "Headline"
        case .subheadline:
            return "Subheadline"
        case .source:
            return "Source"
        }
    }
}

struct ChannelCardContent: Identifiable, Equatable, Sendable {
    let id: String
    let channelID: String
    let createdAt: Date
    let kind: ChannelCardKind
    let text: String?
    let headline: String?
    let subheadline: String?
    let source: String?
    let mediaKind: ChannelCardMediaKind?

    var orderedTextBlocks: [String] {
        [text, headline, subheadline, source].compactMap { value in
            guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
                return nil
            }
            return trimmed
        }
    }

    var serviceHeadline: String {
        orderedTextBlocks.first ?? kind.rawValue.capitalized
    }
}
