import Foundation

public enum UploadPayload: Sendable, CustomStringConvertible {
    case data(Data, mediaType: UploadMediaType)
    case file(UploadFileReference)
    case multipart(UploadMultipartForm)

    public var description: String {
        switch self {
        case .data(let data, let mediaType):
            return "UploadPayload(dataBytes: \(data.count), mediaType: \(mediaType.value))"
        case .file(let file):
            return "UploadPayload(file: \(file.description))"
        case .multipart(let form):
            return "UploadPayload(multipart: \(form.description))"
        }
    }
}
