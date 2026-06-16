import Foundation

public struct StateMachineSnapshot: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let machineID: StateMachineID
    public let state: StateID
    public let revision: UInt64
    public let lastEventID: StateEventID?
    public let metadata: StateMetadata
    public let updatedAt: StateMachineInstant

    public init(
        machineID: StateMachineID,
        state: StateID,
        revision: UInt64 = 0,
        lastEventID: StateEventID? = nil,
        metadata: StateMetadata = StateMetadata.empty,
        updatedAt: StateMachineInstant
    ) {
        self.machineID = machineID
        self.state = state
        self.revision = revision
        self.lastEventID = lastEventID
        self.metadata = metadata
        self.updatedAt = updatedAt
    }

    public func applying(
        transition: StateTransition,
        event: StateMachineEvent,
        at instant: StateMachineInstant
    ) -> StateMachineSnapshot {
        let nextRevision = revision == UInt64.max ? UInt64.max : revision + 1
        return StateMachineSnapshot(
            machineID: machineID,
            state: transition.to,
            revision: nextRevision,
            lastEventID: event.id,
            metadata: event.metadata,
            updatedAt: instant
        )
    }

    public var description: String {
        "<redacted:StateMachineSnapshot,revision:\(revision),metadataFields:\(metadata.fields.count)>"
    }

    public var debugDescription: String { description }
}
