import Foundation

public struct OperatingSystemInfo: Codable, Sendable, Equatable {
    public let platform: DevicePlatform
    public let name: String
    public let versionString: String
    public let majorVersion: Int
    public let minorVersion: Int
    public let patchVersion: Int

    public init(
        platform: DevicePlatform,
        name: String,
        versionString: String,
        majorVersion: Int,
        minorVersion: Int,
        patchVersion: Int
    ) {
        self.platform = platform
        self.name = name.isEmpty ? platform.rawValue : name
        self.versionString = versionString.isEmpty ? "unknown" : versionString
        self.majorVersion = majorVersion
        self.minorVersion = minorVersion
        self.patchVersion = patchVersion
    }
}
