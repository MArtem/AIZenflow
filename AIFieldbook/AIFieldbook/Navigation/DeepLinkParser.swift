import Foundation

/// Value-only destination decoded from an external app URL.
///
/// Security contract:
/// The destination is not trusted until the app composition layer verifies that the referenced
/// local record still exists before mutating navigation state.
enum DeepLinkDestination: Equatable {
    case workspace(UUID)
    case item(UUID, KnowledgeItemKind?)
}

/// Parses external AI Fieldbook URLs into app navigation destinations.
///
/// Security contract:
/// Only the app-owned `aifieldbook` scheme is accepted. Parsed identifiers remain value-only
/// until `AppComposition` verifies that the target record exists before routing.
enum DeepLinkParser {
    static func destination(for url: URL) -> DeepLinkDestination? {
        guard
            url.scheme?.lowercased() == "aifieldbook",
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.user == nil,
            urlComponents.password == nil,
            urlComponents.port == nil,
            urlComponents.fragment == nil,
            let host = urlComponents.host?.lowercased()
        else {
            return nil
        }

        let encodedPath = urlComponents.percentEncodedPath
        guard
            encodedPath.hasPrefix("/"),
            !encodedPath.hasSuffix("/"),
            !encodedPath.dropFirst().contains("/"),
            let id = UUID(uuidString: String(encodedPath.dropFirst()))
        else {
            return nil
        }

        let queryItems = urlComponents.queryItems ?? []
        switch host {
        case "workspace":
            guard queryItems.isEmpty else { return nil }
            return .workspace(id)
        case "item":
            guard queryItems.count <= 1 else { return nil }
            guard let queryItem = queryItems.first else { return .item(id, nil) }
            guard queryItem.name == "kind", let value = queryItem.value,
                  let kind = KnowledgeItemKind(rawValue: value) else { return nil }
            return .item(id, kind)
        default: return nil
        }
    }
}
