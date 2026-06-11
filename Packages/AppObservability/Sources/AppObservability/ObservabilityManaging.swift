import Foundation

public protocol ObservabilityManaging: Sendable {
    func startSpan(
        _ name: String,
        parent: TraceContext?,
        attributes: ObservabilityAttributes,
        diagnosticContext: DiagnosticContext?
    ) async -> ObservabilitySpan

    func addBreadcrumb(
        _ name: String,
        attributes: ObservabilityAttributes,
        diagnosticContext: DiagnosticContext?
    ) async

    func measure<T: Sendable>(
        _ name: String,
        attributes: ObservabilityAttributes,
        diagnosticContext: DiagnosticContext?,
        operation: @Sendable () async throws -> T
    ) async throws -> T
}

public extension ObservabilityManaging {
    func startSpan(
        _ name: String,
        parent: TraceContext? = nil,
        attributes: ObservabilityAttributes = [:],
        diagnosticContext: DiagnosticContext? = nil
    ) async -> ObservabilitySpan {
        await startSpan(name, parent: parent, attributes: attributes, diagnosticContext: diagnosticContext)
    }

    func addBreadcrumb(
        _ name: String,
        attributes: ObservabilityAttributes = [:],
        diagnosticContext: DiagnosticContext? = nil
    ) async {
        await addBreadcrumb(name, attributes: attributes, diagnosticContext: diagnosticContext)
    }

    func measure<T: Sendable>(
        _ name: String,
        attributes: ObservabilityAttributes = [:],
        diagnosticContext: DiagnosticContext? = nil,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        try await measure(name, attributes: attributes, diagnosticContext: diagnosticContext, operation: operation)
    }
}
