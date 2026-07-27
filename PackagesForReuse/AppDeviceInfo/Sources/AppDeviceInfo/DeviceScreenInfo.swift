import Foundation

public struct DeviceScreenInfo: Codable, Sendable, Equatable {
    public let widthPoints: Double?
    public let heightPoints: Double?
    public let scale: Double?

    public init(
        widthPoints: Double?,
        heightPoints: Double?,
        scale: Double?
    ) {
        self.widthPoints = widthPoints
        self.heightPoints = heightPoints
        self.scale = scale
    }

    public static let unavailable = DeviceScreenInfo(
        widthPoints: nil,
        heightPoints: nil,
        scale: nil
    )
}
