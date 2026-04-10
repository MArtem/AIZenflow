import Foundation
@testable import TchopApp

@MainActor
final class TestAppContentRepository: AppContentRepository {
    func fetchChannelInfo() throws -> ChannelHeaderInfo {
        ChannelHeaderInfo(
            title: "Tchop",
            subtitle: "New channel name"
        )
    }

    func fetchNewsFeedContent() async throws -> NewsFeedContent {
        NewsFeedContent(cards: [])
    }
}

@MainActor
final class TestAppDatabaseManager: AppDatabaseManaging {
    var backendKind: AppDatabaseBackendKind = .swiftData
    var storedChannel: StoredChannel?
    var storedUsers: [String: StoredUser] = [:]
    var shouldFailFetchChannel = false
    var shouldFailFetchUser = false
    var shouldFailInsertChannel = false
    var shouldFailInsertUser = false
    var transactionCallCount = 0
    var insertedChannel: StoredChannel?
    var insertedUsers: [StoredUser] = []

    func fetchPrimaryChannel() throws -> StoredChannel? {
        if shouldFailFetchChannel {
            throw TestDatabaseError.fetchFailed
        }

        return storedChannel
    }

    func hasPrimaryChannel() throws -> Bool {
        storedChannel != nil
    }

    func insertPrimaryChannel(_ channel: StoredChannel) throws {
        if shouldFailInsertChannel {
            throw TestDatabaseError.insertFailed
        }

        insertedChannel = channel
        storedChannel = channel
    }

    func fetchUser(username: String) throws -> StoredUser? {
        if shouldFailFetchUser {
            throw TestDatabaseError.fetchFailed
        }

        return storedUsers[username]
    }

    func insertUser(username: String, createdAt: Date) throws -> StoredUser {
        if shouldFailInsertUser {
            throw TestDatabaseError.insertFailed
        }

        let user = StoredUser(
            id: UUID().uuidString,
            username: username,
            createdAt: createdAt
        )
        storedUsers[username] = user
        insertedUsers.append(user)
        return user
    }

    func performTransaction<T>(_ operation: () throws -> T) throws -> T {
        transactionCallCount += 1
        return try operation()
    }
}

struct TestFeedAPIManager: FeedAPIManaging {
    let result: Result<FeedResponseDTO, Error>

    func fetchFeed() async throws -> FeedResponseDTO {
        try result.get()
    }
}

enum TestDatabaseError: Error {
    case fetchFailed
    case insertFailed
}
