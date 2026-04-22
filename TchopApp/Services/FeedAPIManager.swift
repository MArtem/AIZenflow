import Foundation
import TchopNetworking

/// DTO returned by the feed API abstraction.
struct FeedResponseDTO: Decodable, Sendable {
    let cards: [FeedCardDTO]
}

/// Card payload variants produced by the feed API.
enum FeedCardDTO: Decodable, Sendable {
    case featuredArticle(FeaturedArticleDTO)
    case discussion(DiscussionDTO)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    private enum CardType: String, Decodable {
        case featuredArticle
        case discussion
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(CardType.self, forKey: .type) {
        case .featuredArticle:
            self = .featuredArticle(try FeaturedArticleDTO(from: decoder))
        case .discussion:
            self = .discussion(try DiscussionDTO(from: decoder))
        }
    }
}

/// DTO describing the featured article card.
struct FeaturedArticleDTO: Decodable, Sendable {
    let id: String
    let remoteUpdatedAt: Date
    let publishedAt: Date?
    let postedInPrefix: String
    let sourceTitle: String
    let brandTitle: String
    let headline: String
    let summary: String
    let metadataLine: String
    let translationLabel: String
    let actions: [ArticleActionDTO]
}

/// DTO describing a single article action.
struct ArticleActionDTO: Decodable, Sendable {
    let id: String
    let systemName: String
    let title: String
}

/// DTO describing the discussion card.
struct DiscussionDTO: Decodable, Sendable {
    let id: String
    let remoteUpdatedAt: Date
    let publishedAt: Date?
    let categoryTitle: String
    let headline: String
    let participants: [DiscussionParticipantDTO]
    let joinedText: String
}

/// DTO describing a participant preview inside a discussion card.
struct DiscussionParticipantDTO: Decodable, Sendable {
    let id: String
    let initials: String
    let isHighlighted: Bool
}

/// API abstraction used by repositories to fetch home feed content.
protocol FeedAPIManaging {
    /// Fetches the current feed payload.
    func fetchFeed() async throws -> FeedResponseDTO
}

/// Stubbed feed API manager used until a real backend contract exists.
struct StubFeedAPIManager: FeedAPIManaging {
    private let apiManager: any APIManaging

    /// Creates the stub feed API manager with the shared networking client.
    init(apiManager: any APIManaging) {
        self.apiManager = apiManager
    }

    /// Returns a stubbed feed payload through the shared API client.
    func fetchFeed() async throws -> FeedResponseDTO {
        try await apiManager.perform(
            APIRequest(
                path: "feed",
                method: .get,
                stubResponse: {
                    try await FeedAPIStubFactory.makeFeedResponse()
                }
            )
        )
    }
}

enum FeedAPIStubFactory {
    static func makeFeedResponse() async throws -> FeedResponseDTO {
        try await Task.sleep(for: .milliseconds(120))
        try Task.checkCancellation()
        return try loadFeedResponse()
    }

    static func loadFeedResponse() throws -> FeedResponseDTO {
        let feedData = try loadStubFeedResponseData()
        return try makeJSONDecoder().decode(FeedResponseDTO.self, from: feedData)
    }

    private static func loadStubFeedResponseData() throws -> Data {
        guard
            let responseURL = Bundle.main.url(
                forResource: "StubFeedResponse",
                withExtension: "json",
                subdirectory: "Resources"
            ) ?? Bundle.main.url(forResource: "StubFeedResponse", withExtension: "json")
        else {
            throw FeedAPIStubError.missingStubResource
        }

        return try Data(contentsOf: responseURL)
    }

    private static func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            if let date = iso8601DateFormatterWithFractionalSeconds.date(from: value) {
                return date
            }

            if let date = iso8601DateFormatter.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported ISO8601 date value: \(value)"
            )
        }
        return decoder
    }

    private static let iso8601DateFormatterWithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

private enum FeedAPIStubError: Error {
    case missingStubResource
}
