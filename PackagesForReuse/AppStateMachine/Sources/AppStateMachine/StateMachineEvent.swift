import Foundation

public struct StateMachineEvent: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let id: StateEventID
    public let metadata: StateMetadata

    public init(id: StateEventID) {
        self.id = id
        self.metadata = StateMetadata.empty
    }

    public init(id: StateEventID, metadata: StateMetadata) {
        self.id = id
        self.metadata = metadata
    }

    public var description: String {
        "<redacted:StateMachineEvent,metadataFields:\(metadata.fields.count)>"
    }

    public var debugDescription: String { description }
}
