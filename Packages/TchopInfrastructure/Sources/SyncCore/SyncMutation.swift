import Foundation

public struct SyncMutation: Codable, Identifiable, Sendable, Equatable {
    public let id: UUID
    public let entityType: String
    public let entityID: String
    public let operation: SyncOperationKind
    public let baseServerRevision: Int?
    public let fieldChanges: [FieldChange]
    public let payloadData: Data?
    public let createdAt: Date
    public let idempotencyKey: String
    public var retryCount: Int
    public var lastError: String?

    public init(
        id: UUID = UUID(),
        entityType: String,
        entityID: String,
        operation: SyncOperationKind,
        baseServerRevision: Int?,
        fieldChanges: [FieldChange] = [],
        payloadData: Data? = nil,
        createdAt: Date = Date(),
        idempotencyKey: String = UUID().uuidString,
        retryCount: Int = 0,
        lastError: String? = nil
    ) {
        self.id = id
        self.entityType = entityType
        self.entityID = entityID
        self.operation = operation
        self.baseServerRevision = baseServerRevision
        self.fieldChanges = fieldChanges
        self.payloadData = payloadData
        self.createdAt = createdAt
        self.idempotencyKey = idempotencyKey
        self.retryCount = retryCount
        self.lastError = lastError
    }
}
