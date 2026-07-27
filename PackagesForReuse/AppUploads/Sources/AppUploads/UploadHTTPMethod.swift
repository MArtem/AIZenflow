import Foundation

public enum UploadHTTPMethod: String, Codable, Sendable, CaseIterable {
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}
