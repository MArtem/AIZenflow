import Foundation

public enum SecureStorageValidation {
    public static let maximumKeyLength = 512
    public static let maximumValueSizeInBytes = 1_048_576

    public static func validateKey(_ key: SecureStorageKey) throws {
        let trimmed = key.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw SecureStorageError.invalidKey
        }
        guard key.rawValue.utf8.count <= maximumKeyLength else {
            throw SecureStorageError.invalidKey
        }
    }

    public static func validateValueSize(_ data: Data, maximumBytes: Int = maximumValueSizeInBytes) throws {
        guard data.count <= maximumBytes else {
            throw SecureStorageError.valueTooLarge(maximumBytes: maximumBytes, actualBytes: data.count)
        }
    }
}
