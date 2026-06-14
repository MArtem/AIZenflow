import Foundation

public struct UploadMultipartForm: Hashable, Codable, Sendable, CustomStringConvertible {
    public let fields: [UploadFormField]
    public let files: [UploadFileReference]

    public init(fields: [UploadFormField] = [], files: [UploadFileReference]) throws {
        guard fields.isEmpty == false || files.isEmpty == false else {
            throw UploadFailure(.invalidPayload, operation: .validation)
        }
        self.fields = fields
        self.files = files
    }

    public var description: String {
        "UploadMultipartForm(fields: \(fields.count), files: \(files.count))"
    }
}
