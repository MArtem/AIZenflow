import Foundation

public struct DeviceModelInfo: Codable, Sendable, Equatable {
    public let identifier: String
    public let family: DeviceFamily
    public let architecture: String

    public init(
        identifier: String,
        family: DeviceFamily,
        architecture: String
    ) {
        self.identifier = identifier.isEmpty ? "unknown" : identifier
        self.family = family
        self.architecture = architecture.isEmpty ? "unknown" : architecture
    }
}
