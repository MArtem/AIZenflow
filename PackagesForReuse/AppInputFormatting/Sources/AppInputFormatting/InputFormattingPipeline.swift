public struct InputFormattingPipeline: InputFormatter, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let id: InputFormatterID
    private let formatters: [any InputFormatter]

    public init(id: InputFormatterID, formatters: [any InputFormatter]) throws {
        guard !formatters.isEmpty else {
            throw InputFormattingFailure.missingFormatter
        }
        guard formatters.count <= 128 else {
            throw InputFormattingFailure.invalidLimit
        }
        let formatterIDs = formatters.map(\.id)
        guard Set(formatterIDs).count == formatterIDs.count else {
            throw InputFormattingFailure.duplicateFormatter
        }
        self.id = id
        self.formatters = formatters
    }

    public func format(_ snapshot: InputSnapshot) async throws -> InputFormattingResult {
        var current = snapshot
        var applied = 0
        for formatter in formatters {
            let result = try await formatter.format(current)
            current = try result.asSnapshot()
            applied = try Self.addAppliedCount(applied, result.appliedFormatterCount)
        }
        return try InputFormattingResult(
            fieldID: current.fieldID,
            text: current.text,
            selection: current.selection,
            appliedFormatterCount: applied,
            revision: current.revision
        )
    }

    private static func addAppliedCount(_ current: Int, _ next: Int) throws -> Int {
        let result = current.addingReportingOverflow(next)
        guard !result.overflow else {
            throw InputFormattingFailure.invalidLimit
        }
        return result.partialValue
    }

    public var description: String {
        "InputFormattingPipeline(id:\(id),formatterCount:\(formatters.count))"
    }

    public var debugDescription: String { description }
}
