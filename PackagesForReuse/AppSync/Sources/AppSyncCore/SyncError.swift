import Foundation

/// Common sync-domain failures surfaced by reusable sync infrastructure.
///
/// External usage:
/// Repositories and UI layers may map these values into localized user-facing failure states.
public enum SyncError: Error, Sendable, Equatable, LocalizedError {
    case alreadyRunning
    case offline
    case invalidCursor
    case conflictNotResolvable
    case unsupportedEntityType(String)
    case remoteRejected(String)
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .alreadyRunning:
            return "Sync is already running."
        case .offline:
            return "Network is offline."
        case .invalidCursor:
            return "Sync cursor is invalid."
        case .conflictNotResolvable:
            return "Conflict cannot be resolved automatically."
        case .unsupportedEntityType(let type):
            return "Unsupported entity type: \(type)."
        case .remoteRejected(let reason):
            return "Remote rejected sync operation: \(reason)."
        case .cancelled:
            return "Sync was cancelled."
        }
    }
}
