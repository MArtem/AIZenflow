import Foundation

public enum UploadURLRedactor {
    public static func redacted(_ url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return "url(redacted)"
        }
        components.query = nil
        components.fragment = nil
        if components.path.isEmpty == false {
            components.path = "/…"
        }
        return components.string ?? "url(redacted)"
    }
}
