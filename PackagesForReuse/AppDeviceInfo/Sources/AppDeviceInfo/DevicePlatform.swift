import Foundation

public enum DevicePlatform: String, Codable, Sendable, Equatable, CaseIterable {
    case iOS
    case iPadOS
    case macOS
    case tvOS
    case watchOS
    case visionOS
    case linux
    case unknown

    public static var current: DevicePlatform {
        #if os(iOS)
        return .iOS
        #elseif os(macOS)
        return .macOS
        #elseif os(tvOS)
        return .tvOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(visionOS)
        return .visionOS
        #elseif os(Linux)
        return .linux
        #else
        return .unknown
        #endif
    }
}
