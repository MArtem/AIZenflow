public protocol InputFormatter: Sendable {
    var id: InputFormatterID { get }
    func format(_ snapshot: InputSnapshot) async throws -> InputFormattingResult
}
