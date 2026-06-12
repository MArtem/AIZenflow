import Foundation

/// Locale and regional context represented with Sendable primitive values.
public struct AppLocaleContext: Equatable, Sendable, Codable {
    public let localeIdentifier: String
    public let languageCode: String?
    public let regionCode: String?
    public let timeZoneIdentifier: String
    public let calendarIdentifier: String

    public init(
        localeIdentifier: String,
        languageCode: String? = nil,
        regionCode: String? = nil,
        timeZoneIdentifier: String,
        calendarIdentifier: String
    ) {
        self.localeIdentifier = localeIdentifier
        self.languageCode = AppLocaleContext.clean(languageCode)
        self.regionCode = AppLocaleContext.clean(regionCode)
        self.timeZoneIdentifier = timeZoneIdentifier
        self.calendarIdentifier = calendarIdentifier
    }

    private static func clean(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension AppLocaleContext: CustomStringConvertible {
    public var description: String {
        "AppLocaleContext(locale: \(localeIdentifier), timeZone: \(timeZoneIdentifier))"
    }
}
