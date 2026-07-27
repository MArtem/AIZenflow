import Foundation

public struct FormFieldState: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let id: FormFieldID
    public let value: FormFieldValue
    public let isTouched: Bool
    public let isDirty: Bool

    public init(id: FormFieldID, value: FormFieldValue, isTouched: Bool = false, isDirty: Bool = false) {
        self.id = id
        self.value = value
        self.isTouched = isTouched
        self.isDirty = isDirty
    }

    public func updatingValue(_ newValue: FormFieldValue, markTouched: Bool = true) -> FormFieldState {
        FormFieldState(
            id: id,
            value: newValue,
            isTouched: isTouched || markTouched,
            isDirty: isDirty || value != newValue
        )
    }

    public func markingTouched() -> FormFieldState {
        FormFieldState(id: id, value: value, isTouched: true, isDirty: isDirty)
    }

    public var description: String {
        "FormFieldState(id:\(id),value:\(value),touched:\(isTouched),dirty:\(isDirty))"
    }

    public var debugDescription: String { description }
}
