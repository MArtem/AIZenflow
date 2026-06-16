import Foundation

public enum AppTaskQueueFailure: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidIdentifier
    case invalidKind
    case invalidPayloadSize(maximumBytes: Int)
    case invalidMediaType
    case invalidPriority
    case invalidSchedule
    case invalidRetryPolicy
    case duplicateTask
    case missingTask
    case taskCannotBeReserved
    case taskCannotBeCompleted
    case taskCannotBeRetried

    public var description: String {
        switch self {
        case .invalidIdentifier:
            "AppTaskQueueFailure.invalidIdentifier"
        case .invalidKind:
            "AppTaskQueueFailure.invalidKind"
        case .invalidPayloadSize(let maximumBytes):
            "AppTaskQueueFailure.invalidPayloadSize(maximumBytes: \(maximumBytes))"
        case .invalidMediaType:
            "AppTaskQueueFailure.invalidMediaType"
        case .invalidPriority:
            "AppTaskQueueFailure.invalidPriority"
        case .invalidSchedule:
            "AppTaskQueueFailure.invalidSchedule"
        case .invalidRetryPolicy:
            "AppTaskQueueFailure.invalidRetryPolicy"
        case .duplicateTask:
            "AppTaskQueueFailure.duplicateTask"
        case .missingTask:
            "AppTaskQueueFailure.missingTask"
        case .taskCannotBeReserved:
            "AppTaskQueueFailure.taskCannotBeReserved"
        case .taskCannotBeCompleted:
            "AppTaskQueueFailure.taskCannotBeCompleted"
        case .taskCannotBeRetried:
            "AppTaskQueueFailure.taskCannotBeRetried"
        }
    }
}
