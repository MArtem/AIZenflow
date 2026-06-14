import Foundation

public struct SafeDownloadFileName: Hashable, Sendable, Codable, CustomStringConvertible {
    public static let maximumLength = 180
    private let storage: String

    private init(validated value: String) {
        self.storage = value
    }

    public init(_ value: String) throws {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.isEmpty == false else {
            throw DownloadFailure(.invalidFileName, operation: .validation)
        }
        guard normalized.count <= Self.maximumLength else {
            throw DownloadFailure(.invalidFileName, operation: .validation)
        }
        guard normalized != "." && normalized != ".." else {
            throw DownloadFailure(.invalidFileName, operation: .validation)
        }
        guard normalized.contains("/") == false && normalized.contains("\\") == false else {
            throw DownloadFailure(.invalidFileName, operation: .validation)
        }
        guard normalized.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) == false else {
            throw DownloadFailure(.invalidFileName, operation: .validation)
        }
        let forbiddenCharacters = CharacterSet(charactersIn: ":*?\"<>|")
        guard normalized.unicodeScalars.contains(where: { forbiddenCharacters.contains($0) }) == false else {
            throw DownloadFailure(.invalidFileName, operation: .validation)
        }
        self.storage = normalized
    }

    public static func sanitized(_ proposedName: String, fallbackExtension: String? = nil) -> SafeDownloadFileName {
        let trimmed = proposedName.trimmingCharacters(in: .whitespacesAndNewlines)
        let scalarView = trimmed.unicodeScalars.map { scalar -> Character in
            if CharacterSet.controlCharacters.contains(scalar) {
                return "-"
            }
            if scalar == "/" || scalar == "\\" || scalar == ":" || scalar == "*" || scalar == "?" || scalar == "\"" || scalar == "<" || scalar == ">" || scalar == "|" {
                return "-"
            }
            return Character(scalar)
        }
        var candidate = String(scalarView)
        while candidate.contains("--") {
            candidate = candidate.replacingOccurrences(of: "--", with: "-")
        }
        candidate = candidate.trimmingCharacters(in: CharacterSet(charactersIn: " .-"))
        if candidate.isEmpty || candidate == "." || candidate == ".." {
            candidate = "download"
        }
        if candidate.count > maximumLength {
            candidate = String(candidate.prefix(maximumLength))
        }
        if candidate.contains(".") == false, let fallbackExtension, fallbackExtension.isEmpty == false {
            let cleanExtension = fallbackExtension.trimmingCharacters(in: CharacterSet(charactersIn: ". "))
            if cleanExtension.isEmpty == false {
                candidate = String(candidate.prefix(maximumLength - min(cleanExtension.count + 1, maximumLength))) + "." + cleanExtension
            }
        }
        if isValid(candidate) {
            return SafeDownloadFileName(validated: candidate)
        }
        return SafeDownloadFileName.fallback
    }

    public static let fallback = SafeDownloadFileName(validated: "download")

    private static func isValid(_ value: String) -> Bool {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.isEmpty == false else { return false }
        guard normalized.count <= maximumLength else { return false }
        guard normalized != "." && normalized != ".." else { return false }
        guard normalized.contains("/") == false && normalized.contains("\\") == false else { return false }
        guard normalized.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) == false else { return false }
        let forbiddenCharacters = CharacterSet(charactersIn: ":*?\"<>|")
        guard normalized.unicodeScalars.contains(where: { forbiddenCharacters.contains($0) }) == false else { return false }
        return true
    }

    public var value: String { storage }

    public var description: String {
        "SafeDownloadFileName(redacted, length: \(storage.count))"
    }
}
