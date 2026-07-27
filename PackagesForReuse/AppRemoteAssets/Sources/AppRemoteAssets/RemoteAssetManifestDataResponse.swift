import Foundation

public struct RemoteAssetManifestDataResponse: Sendable, CustomStringConvertible {
    public let statusCode: Int
    public let payload: Data

    public init(statusCode: Int, payload: Data) {
        self.statusCode = statusCode
        self.payload = payload
    }

    public var description: String {
        "RemoteAssetManifestDataResponse(statusCode: \(statusCode), byteCount: \(payload.count))"
    }
}
