public protocol InputFormattingStore: Sendable {
    func formatter(id: InputFormatterID) async throws -> (any InputFormatter)?
    func plan(fieldID: InputFieldID) async throws -> InputFormattingPlan?
    func save(formatter: any InputFormatter) async throws
    func save(plan: InputFormattingPlan) async throws
}

public actor InMemoryInputFormattingStore: InputFormattingStore {
    private var formatters: [InputFormatterID: any InputFormatter] = [:]
    private var plans: [InputFieldID: InputFormattingPlan] = [:]

    public init() {}

    public func formatter(id: InputFormatterID) async throws -> (any InputFormatter)? {
        formatters[id]
    }

    public func plan(fieldID: InputFieldID) async throws -> InputFormattingPlan? {
        plans[fieldID]
    }

    public func save(formatter: any InputFormatter) async throws {
        guard formatters[formatter.id] == nil else {
            throw InputFormattingFailure.duplicateFormatter
        }
        formatters[formatter.id] = formatter
    }

    public func save(plan: InputFormattingPlan) async throws {
        guard plans[plan.fieldID] == nil else {
            throw InputFormattingFailure.duplicatePlan
        }
        plans[plan.fieldID] = plan
    }
}
