import Foundation

public enum DeviceFamily: String, Codable, Sendable, Equatable, CaseIterable {
    case phone
    case tablet
    case desktop
    case television
    case watch
    case spatial
    case server
    case unknown

    public static func defaultFamily(for platform: DevicePlatform) -> DeviceFamily {
        switch platform {
        case .iOS:
            return .phone
        case .iPadOS:
            return .tablet
        case .macOS:
            return .desktop
        case .tvOS:
            return .television
        case .watchOS:
            return .watch
        case .visionOS:
            return .spatial
        case .linux:
            return .server
        case .unknown:
            return .unknown
        }
    }
}
