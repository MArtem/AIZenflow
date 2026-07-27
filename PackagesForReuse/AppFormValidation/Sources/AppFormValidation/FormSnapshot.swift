import Foundation

public struct FormSnapshot: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let formID: FormID
    public let revision: Int
    public let fields: [FormFieldID: FormFieldState]

    public init(formID: FormID, revision: Int = 0, fields: [FormFieldState]) throws {
        guard revision >= 0 else {
            throw FormValidationFailure.invalidRevision
        }
        var keyed: [FormFieldID: FormFieldState] = [:]
        for field in fields {
            guard keyed[field.id] == nil else {
                throw FormValidationFailure.duplicateField
            }
            keyed[field.id] = field
        }
        self.formID = formID
        self.revision = revision
        self.fields = keyed
    }

    private init(formID: FormID, revision: Int, keyedFields: [FormFieldID: FormFieldState]) throws {
        guard revision >= 0 else {
            throw FormValidationFailure.invalidRevision
        }
        self.formID = formID
        self.revision = revision
        self.fields = keyedFields
    }

    public func field(_ id: FormFieldID) -> FormFieldState? {
        fields[id]
    }

    public func updatingField(_ id: FormFieldID, value: FormFieldValue, markTouched: Bool = true) throws -> FormSnapshot {
        guard let current = fields[id] else {
            throw FormValidationFailure.missingField
        }
        var nextFields = fields
        nextFields[id] = current.updatingValue(value, markTouched: markTouched)
        return try FormSnapshot(formID: formID, revision: nextRevision(), keyedFields: nextFields)
    }

    public func markingTouched(_ id: FormFieldID) throws -> FormSnapshot {
        guard let current = fields[id] else {
            throw FormValidationFailure.missingField
        }
        var nextFields = fields
        nextFields[id] = current.markingTouched()
        return try FormSnapshot(formID: formID, revision: nextRevision(), keyedFields: nextFields)
    }

    private func nextRevision() throws -> Int {
        guard revision < Int.max else {
            throw FormValidationFailure.revisionOverflow
        }
        return revision + 1
    }

    public var description: String {
        "FormSnapshot(formID:\(formID),revision:\(revision),fieldCount:\(fields.count))"
    }

    public var debugDescription: String { description }
}
