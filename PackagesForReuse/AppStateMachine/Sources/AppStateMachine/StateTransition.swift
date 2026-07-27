import Foundation

public struct StateTransitionKey: Codable, Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let from: StateID
    public let event: StateEventID

    public init(from: StateID, event: StateEventID) {
        self.from = from
        self.event = event
    }

    public var description: String {
        "<redacted:StateTransitionKey>"
    }

    public var debugDescription: String { description }
}

public struct StateTransition: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let from: StateID
    public let event: StateEventID
    public let to: StateID
    public let guardID: StateGuardID?
    public let actionID: StateActionID?

    public init(
        from: StateID,
        event: StateEventID,
        to: StateID,
        guardID: StateGuardID? = nil,
        actionID: StateActionID? = nil
    ) {
        self.from = from
        self.event = event
        self.to = to
        self.guardID = guardID
        self.actionID = actionID
    }

    public var key: StateTransitionKey {
        StateTransitionKey(from: from, event: event)
    }

    public var description: String {
        "<redacted:StateTransition,hasGuard:\(guardID != nil),hasAction:\(actionID != nil)>"
    }

    public var debugDescription: String { description }
}
