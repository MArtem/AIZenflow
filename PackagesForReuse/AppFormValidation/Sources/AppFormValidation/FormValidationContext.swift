import Foundation

public struct FormValidationContext: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let formID: FormID
    public let snapshot: FormSnapshot

    public init(formID: FormID, snapshot: FormSnapshot) {
        self.formID = formID
        self.snapshot = snapshot
    }

    public var description: String {
        "FormValidationContext(formID:\(formID),revision:\(snapshot.revision),fieldCount:\(snapshot.fields.count))"
    }

    public var debugDescription: String { description }
}
