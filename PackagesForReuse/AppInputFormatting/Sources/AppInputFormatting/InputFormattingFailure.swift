public enum InputFormattingFailure: Error, Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    case invalidIdentifier
    case invalidSelection
    case invalidPattern
    case invalidLimit
    case missingPlan
    case missingFormatter
    case duplicateFormatter
    case duplicatePlan
    case revisionOverflow

    public var description: String {
        switch self {
        case .invalidIdentifier:
            "InputFormattingFailure.invalidIdentifier"
        case .invalidSelection:
            "InputFormattingFailure.invalidSelection"
        case .invalidPattern:
            "InputFormattingFailure.invalidPattern"
        case .invalidLimit:
            "InputFormattingFailure.invalidLimit"
        case .missingPlan:
            "InputFormattingFailure.missingPlan"
        case .missingFormatter:
            "InputFormattingFailure.missingFormatter"
        case .duplicateFormatter:
            "InputFormattingFailure.duplicateFormatter"
        case .duplicatePlan:
            "InputFormattingFailure.duplicatePlan"
        case .revisionOverflow:
            "InputFormattingFailure.revisionOverflow"
        }
    }

    public var debugDescription: String { description }
}
