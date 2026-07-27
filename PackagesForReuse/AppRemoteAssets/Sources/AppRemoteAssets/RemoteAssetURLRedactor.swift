import Foundation

public enum RemoteAssetURLRedactor: Sendable {
    public static func redacted(_ url: URL) -> String {
        guard let source = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return "url(redacted)"
        }
        var output = URLComponents()
        output.scheme = source.scheme
        output.host = source.host
        output.port = source.port
        output.path = source.path.isEmpty ? "" : "/…"
        return output.string ?? "url(redacted)"
    }
}
