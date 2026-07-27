import Foundation

/// Compile-time build configuration detected by compiler flags.
public enum BuildConfiguration: String, Equatable, Hashable, Sendable, Codable {
    case debug
    case release
    case unknown

    public static var current: BuildConfiguration {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }
}
