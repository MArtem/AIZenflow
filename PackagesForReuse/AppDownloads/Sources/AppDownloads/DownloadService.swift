import Foundation

public actor DownloadService {
    private let transport: any DownloadTransport
    private let fileSystem: DownloadFileSystemWorker

    public init(
        transport: any DownloadTransport = FoundationDownloadTransport(),
        fileSystem: DownloadFileSystemWorker = DownloadFileSystemWorker()
    ) {
        self.transport = transport
        self.fileSystem = fileSystem
    }

    public func download(_ request: DownloadRequest, to destination: DownloadDestination) async throws -> DownloadReceipt {
        let response = try await transport.response(for: request)
        if let maximumAllowedBytes = request.maximumAllowedBytes,
           let expectedBytes = response.expectedBytes,
           expectedBytes > maximumAllowedBytes {
            throw DownloadFailure(.responseTooLarge, operation: .transport)
        }
        if let maximumAllowedBytes = request.maximumAllowedBytes, Int64(response.data.count) > maximumAllowedBytes {
            throw DownloadFailure(.responseTooLarge, operation: .transport)
        }
        let receipt = try await fileSystem.writeAtomically(data: response.data, to: destination)
        return DownloadReceipt(
            id: request.id,
            fileName: receipt.fileName,
            directoryRole: receipt.directoryRole,
            byteCount: receipt.byteCount,
            completedAt: receipt.completedAt
        )
    }
}
