import Foundation

public actor UploadBodyLoadWorker {
    public init() {}

    public func prepare(_ request: UploadRequest) async throws -> PreparedUpload {
        let prepared: PreparedUpload
        switch request.payload {
        case .data(let data, let mediaType):
            prepared = try PreparedUpload(
                id: request.id,
                url: request.url,
                method: request.method,
                mediaType: mediaType,
                payloadData: data
            )
        case .file(let file):
            try validateFileReference(file, maximumPayloadBytes: request.maximumPayloadBytes)
            let data = try readFile(file.fileURL)
            prepared = try PreparedUpload(
                id: request.id,
                url: request.url,
                method: request.method,
                mediaType: file.mediaType,
                payloadData: data
            )
        case .multipart(let form):
            try validateMultipartFilePayload(form, maximumPayloadBytes: request.maximumPayloadBytes)
            let encoded = try encodeMultipart(form)
            prepared = try PreparedUpload(
                id: request.id,
                url: request.url,
                method: request.method,
                mediaType: try UploadMediaType("multipart/form-data; boundary=\(encoded.boundary)"),
                payloadData: encoded.data
            )
        }
        if let maximumPayloadBytes = request.maximumPayloadBytes, prepared.expectedByteCount > maximumPayloadBytes {
            throw UploadFailure(.payloadTooLarge, operation: .validation)
        }
        return prepared
    }

    public func fileByteCount(at fileURL: URL) throws -> Int64 {
        guard fileURL.isFileURL else {
            throw UploadFailure(.invalidPayload, operation: .validation)
        }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let number = attributes[.size] as? NSNumber {
                return number.int64Value
            }
            throw UploadFailure(.fileSystemUnavailable, operation: .fileSystem)
        } catch let failure as UploadFailure {
            throw failure
        } catch {
            throw UploadFailure(.fileSystemUnavailable, operation: .fileSystem)
        }
    }

    private func validateMultipartFilePayload(_ form: UploadMultipartForm, maximumPayloadBytes: Int64?) throws {
        guard let maximumPayloadBytes else { return }
        var totalFileBytes: Int64 = 0
        for file in form.files {
            let byteCount: Int64
            if let declaredByteCount = file.declaredByteCount {
                byteCount = declaredByteCount
            } else {
                byteCount = try fileByteCount(at: file.fileURL)
            }
            guard byteCount <= maximumPayloadBytes else {
                throw UploadFailure(.payloadTooLarge, operation: .validation)
            }
            totalFileBytes += byteCount
            guard totalFileBytes <= maximumPayloadBytes else {
                throw UploadFailure(.payloadTooLarge, operation: .validation)
            }
        }
    }

    private func validateFileReference(_ file: UploadFileReference, maximumPayloadBytes: Int64?) throws {
        guard let maximumPayloadBytes else { return }
        if let declaredByteCount = file.declaredByteCount {
            guard declaredByteCount <= maximumPayloadBytes else {
                throw UploadFailure(.payloadTooLarge, operation: .validation)
            }
            return
        }
        let byteCount = try fileByteCount(at: file.fileURL)
        guard byteCount <= maximumPayloadBytes else {
            throw UploadFailure(.payloadTooLarge, operation: .validation)
        }
    }

    private func readFile(_ fileURL: URL) throws -> Data {
        guard fileURL.isFileURL else {
            throw UploadFailure(.invalidPayload, operation: .validation)
        }
        do {
            return try Data(contentsOf: fileURL, options: [.mappedIfSafe])
        } catch {
            throw UploadFailure(.fileReadFailed, operation: .fileSystem)
        }
    }

    private func encodeMultipart(_ form: UploadMultipartForm) throws -> (data: Data, boundary: String) {
        let boundary = "AppUploadsBoundary-\(UUID().uuidString)"
        var data = Data()

        for field in form.fields {
            append("--\(boundary)\r\n", to: &data)
            append("Content-Disposition: form-data; name=\"\(field.name.value)\"\r\n\r\n", to: &data)
            append(field.value, to: &data)
            append("\r\n", to: &data)
        }

        for file in form.files {
            let fileData = try readFile(file.fileURL)
            append("--\(boundary)\r\n", to: &data)
            append("Content-Disposition: form-data; name=\"\(file.fieldName.value)\"; filename=\"\(file.fileName.value)\"\r\n", to: &data)
            append("Content-Type: \(file.mediaType.value)\r\n\r\n", to: &data)
            data.append(fileData)
            append("\r\n", to: &data)
        }

        append("--\(boundary)--\r\n", to: &data)
        guard data.isEmpty == false else {
            throw UploadFailure(.encodingFailed, operation: .encoding)
        }
        return (data, boundary)
    }

    private func append(_ string: String, to data: inout Data) {
        data.append(contentsOf: string.utf8)
    }
}
