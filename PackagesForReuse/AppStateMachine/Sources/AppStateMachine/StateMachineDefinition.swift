import Foundation

public struct StateMachineDefinition: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let id: StateMachineID
    public let states: Set<StateID>
    public let initialState: StateID
    public let transitions: [StateTransition]

    public init(
        id: StateMachineID,
        states: Set<StateID>,
        initialState: StateID,
        transitions: [StateTransition]
    ) throws {
        guard states.contains(initialState) else {
            throw StateMachineFailure.missingInitialState
        }
        for transition in transitions {
            guard states.contains(transition.from), states.contains(transition.to) else {
                throw StateMachineFailure.transitionReferencesUnknownState
            }
        }
        let keys = transitions.map(\.key)
        guard Set(keys).count == keys.count else {
            throw StateMachineFailure.duplicateTransition
        }
        self.id = id
        self.states = states
        self.initialState = initialState
        self.transitions = transitions
    }

    public func transition(from state: StateID, event: StateEventID) -> StateTransition? {
        transitions.first { candidate in
            candidate.from == state && candidate.event == event
        }
    }

    public var description: String {
        "<redacted:StateMachineDefinition,states:\(states.count),transitions:\(transitions.count)>"
    }

    public var debugDescription: String { description }
}
