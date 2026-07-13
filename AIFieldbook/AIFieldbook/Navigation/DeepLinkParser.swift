import Foundation

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
        guard url.scheme?.lowercased() == "aifieldbook" else { return nil }
        let components = [url.host].compactMap { $0 } + url.pathComponents.filter { $0 != "/" }
        guard components.count >= 2, let id = UUID(uuidString: components[1]) else { return nil }
        switch components[0].lowercased() {
        case "workspace": return .workspace(id)
        case "item":
            let kind = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "kind" })?.value
                .flatMap(KnowledgeItemKind.init(rawValue:))
            return .item(id, kind)
        default: return nil
        }
    }
}
