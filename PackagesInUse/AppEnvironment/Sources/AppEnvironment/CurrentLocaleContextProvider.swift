import Foundation

public struct CurrentLocaleContextProvider: AppLocaleContextProviding {
    public init() {}

    public func localeContext() async -> AppLocaleContext {
        let locale = Locale.current
        let calendar = Calendar.current
        let timeZone = TimeZone.current

        let identifier = locale.identifier

        return AppLocaleContext(
            localeIdentifier: identifier,
            languageCode: CurrentLocaleContextProvider.languageCode(fromLocaleIdentifier: identifier),
            regionCode: CurrentLocaleContextProvider.regionCode(fromLocaleIdentifier: identifier),
            timeZoneIdentifier: timeZone.identifier,
            calendarIdentifier: calendar.identifier.stableCode
        )
    }

    private static func languageCode(fromLocaleIdentifier identifier: String) -> String? {
        let normalized = identifier.replacingOccurrences(of: "_", with: "-")
        guard let first = normalized.split(separator: "-").first else { return nil }
        let value = String(first).trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value.lowercased()
    }

    private static func regionCode(fromLocaleIdentifier identifier: String) -> String? {
        let normalized = identifier.replacingOccurrences(of: "_", with: "-")
        let parts = normalized.split(separator: "-").map(String.init)
        guard parts.count >= 2 else { return nil }
        let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }
        return value.uppercased()
    }
}

private extension Calendar.Identifier {
    var stableCode: String {
        switch self {
        case .gregorian: return "gregorian"
        case .buddhist: return "buddhist"
        case .chinese: return "chinese"
        case .coptic: return "coptic"
        case .ethiopicAmeteMihret: return "ethiopic-amete-mihret"
        case .ethiopicAmeteAlem: return "ethiopic-amete-alem"
        case .hebrew: return "hebrew"
        case .iso8601: return "iso8601"
        case .indian: return "indian"
        case .islamic: return "islamic"
        case .islamicCivil: return "islamic-civil"
        case .japanese: return "japanese"
        case .persian: return "persian"
        case .republicOfChina: return "republic-of-china"
        case .islamicTabular: return "islamic-tabular"
        case .islamicUmmAlQura: return "islamic-umm-al-qura"
        default: return "unknown"
        }
    }
}
