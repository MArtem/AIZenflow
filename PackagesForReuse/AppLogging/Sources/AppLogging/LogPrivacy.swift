import Foundation

/// Privacy classification for log metadata values.
public enum LogPrivacy: Codable, Equatable, Sendable {
    case `public`
    case `private`
    case sensitive(mask: String)

    public var isPublic: Bool {
        if case .public = self { return true }
        return false
    }

    public var replacement: String {
        switch self {
        case .public:
            ""
        case .private:
            "<private>"
        case .sensitive(let mask):
            mask.isEmpty ? "<redacted>" : mask
        }
    }
}
