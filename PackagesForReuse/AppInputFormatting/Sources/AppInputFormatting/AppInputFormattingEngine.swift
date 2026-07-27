public actor AppInputFormattingEngine: Sendable {
    private let store: any InputFormattingStore

    public init(store: any InputFormattingStore) {
        self.store = store
    }

    public func format(_ snapshot: InputSnapshot) async throws -> InputFormattingResult {
        guard let plan = try await store.plan(fieldID: snapshot.fieldID) else {
            throw InputFormattingFailure.missingPlan
        }

        var current = snapshot
        var applied = 0
        for formatterID in plan.formatterIDs {
            guard let formatter = try await store.formatter(id: formatterID) else {
                throw InputFormattingFailure.missingFormatter
            }
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
}
