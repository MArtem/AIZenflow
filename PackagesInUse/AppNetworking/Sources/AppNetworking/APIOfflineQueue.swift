import Foundation

public actor APIOfflineRequestQueue {
    private var queuedOperations: [QueuedOperation] = []

    /// Creates an empty queue.
    public init() {}

    /// Number of requests currently waiting for connectivity.
    public var pendingRequestCount: Int {
        queuedOperations.count
    }

    /// Enqueues an operation for later execution.
    public func enqueue(
        id: UUID = UUID(),
        operation: @escaping @Sendable () async -> Void
    ) {
        queuedOperations.append(
            QueuedOperation(id: id, operation: operation)
        )
    }

    /// Executes and clears queued operations when the connectivity provider reports an active connection.
    public func drainIfConnected(using connectivityProvider: any APIConnectivityProviding) async {
        guard await connectivityProvider.isConnected() else {
            return
        }

        let operations = queuedOperations
        queuedOperations.removeAll()

        for operation in operations {
            await operation.operation()
        }
    }

    /// Clears all queued operations without executing them.
    public func removeAll() {
        queuedOperations.removeAll()
    }
}

/// Describes a single persisted offline queue item.
public struct APIOfflineQueueEntry<Payload>: Codable, Sendable where Payload: Codable & Sendable {
    /// Stable identifier of queued operation.
    public let id: UUID

    /// Creation timestamp for ordering and diagnostics.
    public let createdAt: Date

    /// Current retry attempt count.
    public let attempts: Int

    /// Domain payload used to reconstruct operation execution.
    public let payload: Payload

    /// Creates a queue entry.
    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        attempts: Int = 0,
        payload: Payload
    ) {
        self.id = id
        self.createdAt = createdAt
        self.attempts = attempts
        self.payload = payload
    }

    /// Returns a copy of the entry with incremented attempt count.
    public func incrementingAttempts() -> APIOfflineQueueEntry<Payload> {
        APIOfflineQueueEntry(
            id: id,
            createdAt: createdAt,
            attempts: attempts + 1,
            payload: payload
        )
    }
}

/// Persistence contract for payload-based offline queue entries.
public protocol APIOfflineQueueStoring: Sendable {
    associatedtype Payload: Codable & Sendable

    /// Loads all persisted queue entries.
    func loadEntries() throws -> [APIOfflineQueueEntry<Payload>]

    /// Persists queue entries atomically.
    func saveEntries(_ entries: [APIOfflineQueueEntry<Payload>]) throws

    /// Loads all persisted dead-letter entries.
    func loadDeadLetterEntries() throws -> [APIOfflineQueueEntry<Payload>]

    /// Persists dead-letter entries atomically.
    func saveDeadLetterEntries(_ entries: [APIOfflineQueueEntry<Payload>]) throws
}

public extension APIOfflineQueueStoring {
    /// Loads dead letter entries.
    func loadDeadLetterEntries() throws -> [APIOfflineQueueEntry<Payload>] {
        []
    }

    /// Saves dead letter entries.
    func saveDeadLetterEntries(_ entries: [APIOfflineQueueEntry<Payload>]) throws {}
}

/// File-backed store for payload-based offline queue entries.
public struct FileAPIOfflineQueueStore<Payload>: APIOfflineQueueStoring where Payload: Codable & Sendable {
    /// Defines how store behaves when persisted JSON is corrupted.
    public enum CorruptionPolicy: Sendable, Equatable {
        /// Surface decoding/read errors to caller.
        case throwError

        /// Move corrupted file aside and recover with empty entries.
        case recoverToEmpty
    }

    private let fileURL: URL
    private let deadLetterFileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let corruptionPolicy: CorruptionPolicy

    /// Creates a file-backed queue store.
    public init(
        fileURL: URL,
        corruptionPolicy: CorruptionPolicy = .recoverToEmpty,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.fileURL = fileURL
        self.deadLetterFileURL = fileURL.deletingPathExtension()
            .appendingPathExtension("deadletters")
            .appendingPathExtension(fileURL.pathExtension.isEmpty ? "json" : fileURL.pathExtension)
        self.corruptionPolicy = corruptionPolicy
        self.encoder = encoder
        self.decoder = decoder
    }

    /// Loads entries.
    public func loadEntries() throws -> [APIOfflineQueueEntry<Payload>] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([APIOfflineQueueEntry<Payload>].self, from: data)
        } catch let decodingError as DecodingError {
            return try recoverOrThrow(for: fileURL, error: decodingError)
        } catch {
            throw error
        }
    }

    /// Saves entries.
    public func saveEntries(_ entries: [APIOfflineQueueEntry<Payload>]) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }

        let data = try encoder.encode(entries)
        try data.write(to: fileURL, options: .atomic)
    }

    /// Loads dead letter entries.
    public func loadDeadLetterEntries() throws -> [APIOfflineQueueEntry<Payload>] {
        guard FileManager.default.fileExists(atPath: deadLetterFileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: deadLetterFileURL)
            return try decoder.decode([APIOfflineQueueEntry<Payload>].self, from: data)
        } catch let decodingError as DecodingError {
            return try recoverOrThrow(for: deadLetterFileURL, error: decodingError)
        } catch {
            throw error
        }
    }

    /// Saves dead letter entries.
    public func saveDeadLetterEntries(_ entries: [APIOfflineQueueEntry<Payload>]) throws {
        let directoryURL = deadLetterFileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }

        let data = try encoder.encode(entries)
        try data.write(to: deadLetterFileURL, options: .atomic)
    }

    /// Handles recover or throw.
    private func recoverOrThrow(
        for url: URL,
        error: Error
    ) throws -> [APIOfflineQueueEntry<Payload>] {
        switch corruptionPolicy {
        case .throwError:
            throw error
        case .recoverToEmpty:
            let backupURL = url.appendingPathExtension("corrupted-\(Int(Date().timeIntervalSince1970))")
            try? FileManager.default.moveItem(at: url, to: backupURL)
            return []
        }
    }
}

/// Durable payload-based offline queue with retry and dead-letter handling.
public actor APIPersistedOfflineQueue<Store>: Sendable where Store: APIOfflineQueueStoring {
    /// Export payload for diagnostics, support tooling, and state transfers.
    public struct DiagnosticsPayload: Codable, Sendable where Store.Payload: Codable & Sendable {
        public let exportedAt: Date
        public let pendingEntries: [APIOfflineQueueEntry<Store.Payload>]
        public let deadLetterEntries: [APIOfflineQueueEntry<Store.Payload>]

        /// Creates a new DiagnosticsPayload instance.
        public init(
            exportedAt: Date = Date(),
            pendingEntries: [APIOfflineQueueEntry<Store.Payload>],
            deadLetterEntries: [APIOfflineQueueEntry<Store.Payload>]
        ) {
            self.exportedAt = exportedAt
            self.pendingEntries = pendingEntries
            self.deadLetterEntries = deadLetterEntries
        }
    }

    /// Defines how imported diagnostics payload should be applied.
    public enum DiagnosticsImportStrategy: Sendable, Equatable {
        case replace
        case append
    }

    /// Snapshot of current queue state.
    public struct Snapshot: Sendable, Equatable {
        public let pendingCount: Int
        public let deadLetterCount: Int
        public let oldestPendingCreatedAt: Date?
        public let oldestDeadLetterCreatedAt: Date?

        /// Creates a new Snapshot instance.
        public init(
            pendingCount: Int,
            deadLetterCount: Int,
            oldestPendingCreatedAt: Date?,
            oldestDeadLetterCreatedAt: Date?
        ) {
            self.pendingCount = pendingCount
            self.deadLetterCount = deadLetterCount
            self.oldestPendingCreatedAt = oldestPendingCreatedAt
            self.oldestDeadLetterCreatedAt = oldestDeadLetterCreatedAt
        }
    }

    /// Drain execution report for diagnostics and metrics.
    public struct DrainReport: Sendable, Equatable {
        public let skippedDueToNoConnectivity: Bool
        public let attempted: Int
        public let succeeded: Int
        public let failed: Int
        public let retried: Int
        public let movedToDeadLetters: Int

        /// Creates a new DrainReport instance.
        public init(
            skippedDueToNoConnectivity: Bool,
            attempted: Int,
            succeeded: Int,
            failed: Int,
            retried: Int,
            movedToDeadLetters: Int
        ) {
            self.skippedDueToNoConnectivity = skippedDueToNoConnectivity
            self.attempted = attempted
            self.succeeded = succeeded
            self.failed = failed
            self.retried = retried
            self.movedToDeadLetters = movedToDeadLetters
        }
    }

    /// Runtime settings for queue drain and retry behavior.
    public struct Configuration: Sendable, Equatable {
        /// Maximum attempts before moving an entry to dead letters.
        public let maxAttempts: Int

        /// Creates queue configuration.
        public init(maxAttempts: Int = 3) {
            self.maxAttempts = maxAttempts
        }
    }

    private let store: Store
    private let configuration: Configuration
    private var entries: [APIOfflineQueueEntry<Store.Payload>] = []
    private var deadLetterEntries: [APIOfflineQueueEntry<Store.Payload>] = []

    /// Creates a persisted offline queue.
    public init(
        store: Store,
        configuration: Configuration = .init()
    ) throws {
        self.store = store
        self.configuration = configuration
        self.entries = try store.loadEntries().sorted { $0.createdAt < $1.createdAt }
        self.deadLetterEntries = try store.loadDeadLetterEntries().sorted { $0.createdAt < $1.createdAt }
    }

    /// Number of entries waiting for execution.
    public var pendingCount: Int {
        entries.count
    }

    /// Entries that exhausted retry attempts.
    public var deadLetters: [APIOfflineQueueEntry<Store.Payload>] {
        deadLetterEntries
    }

    /// Returns a deterministic snapshot of current queue state.
    public func makeSnapshot() -> Snapshot {
        Snapshot(
            pendingCount: entries.count,
            deadLetterCount: deadLetterEntries.count,
            oldestPendingCreatedAt: entries.first?.createdAt,
            oldestDeadLetterCreatedAt: deadLetterEntries.first?.createdAt
        )
    }

    /// Exports current queue state for diagnostics or offline support workflows.
    public func exportDiagnosticsPayload() -> DiagnosticsPayload {
        DiagnosticsPayload(
            pendingEntries: entries,
            deadLetterEntries: deadLetterEntries
        )
    }

    /// Imports diagnostics payload into queue state.
    public func importDiagnosticsPayload(
        _ payload: DiagnosticsPayload,
        strategy: DiagnosticsImportStrategy = .replace
    ) throws {
        switch strategy {
        case .replace:
            entries = payload.pendingEntries.sorted { $0.createdAt < $1.createdAt }
            deadLetterEntries = payload.deadLetterEntries.sorted { $0.createdAt < $1.createdAt }
        case .append:
            entries = (entries + payload.pendingEntries).sorted { $0.createdAt < $1.createdAt }
            deadLetterEntries = (deadLetterEntries + payload.deadLetterEntries)
                .sorted { $0.createdAt < $1.createdAt }
        }

        try persist()
    }

    /// Adds payload as a new queue entry and persists state.
    public func enqueue(
        payload: Store.Payload,
        id: UUID = UUID(),
        createdAt: Date = Date()
    ) throws {
        entries.append(
            APIOfflineQueueEntry(
                id: id,
                createdAt: createdAt,
                payload: payload
            )
        )
        try persist()
    }

    /// Clears all pending entries and persists state.
    public func removeAll() throws {
        entries.removeAll()
        try persist()
    }

    /// Executes queued entries when connected.
    ///
    /// Failed entries are retried up to `maxAttempts`. Entries that exceed retries
    /// are moved to dead letters.
    public func drainIfConnected(
        using connectivityProvider: any APIConnectivityProviding,
        execute: @escaping @Sendable (Store.Payload) async throws -> Void
    ) async throws {
        _ = try await drainWithReportIfConnected(using: connectivityProvider, execute: execute)
    }

    /// Executes queued entries when connected and returns detailed drain diagnostics.
    public func drainWithReportIfConnected(
        using connectivityProvider: any APIConnectivityProviding,
        execute: @escaping @Sendable (Store.Payload) async throws -> Void
    ) async throws -> DrainReport {
        guard await connectivityProvider.isConnected() else {
            return DrainReport(
                skippedDueToNoConnectivity: true,
                attempted: 0,
                succeeded: 0,
                failed: 0,
                retried: 0,
                movedToDeadLetters: 0
            )
        }

        let drainingEntries = entries
        entries.removeAll()
        var retryEntries: [APIOfflineQueueEntry<Store.Payload>] = []
        var succeededCount = 0
        var failedCount = 0
        var retryCount = 0
        var deadLetterCount = 0

        for entry in drainingEntries {
            do {
                try await execute(entry.payload)
                succeededCount += 1
            } catch {
                failedCount += 1
                let nextEntry = entry.incrementingAttempts()
                if nextEntry.attempts >= configuration.maxAttempts {
                    deadLetterEntries.append(nextEntry)
                    deadLetterCount += 1
                } else {
                    retryEntries.append(nextEntry)
                    retryCount += 1
                }
            }
        }

        // Preserve entries enqueued while drain was in progress.
        entries = retryEntries + entries
        try persist()

        return DrainReport(
            skippedDueToNoConnectivity: false,
            attempted: drainingEntries.count,
            succeeded: succeededCount,
            failed: failedCount,
            retried: retryCount,
            movedToDeadLetters: deadLetterCount
        )
    }

    /// Handles persist.
    private func persist() throws {
        try store.saveEntries(entries)
        try store.saveDeadLetterEntries(deadLetterEntries)
    }
}

/// Static connectivity provider useful for tests and previews.
