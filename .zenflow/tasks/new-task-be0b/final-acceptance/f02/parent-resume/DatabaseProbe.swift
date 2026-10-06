import Foundation
import SwiftData

// Disposable schema migration fixture. Actual database managers compile unchanged beside it.
enum OldSchema: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [Record.self] }
    @Model final class Record {
        var id: String
        var text: String
        init(id: String, text: String) { self.id = id; self.text = text }
    }
}
enum NewSchema: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(2, 0, 0) }
    static var models: [any PersistentModel.Type] { [Record.self] }
    @Model final class Record {
        var id: String
        var text: String
        var note: String?
        init(id: String, text: String, note: String? = nil) {
            self.id = id; self.text = text; self.note = note
        }
    }
}
enum FixturePlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [OldSchema.self, NewSchema.self] }
    static var stages: [MigrationStage] { [.lightweight(fromVersion: OldSchema.self, toVersion: NewSchema.self)] }
}
enum FailingFixturePlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [OldSchema.self, NewSchema.self] }
    static var stages: [MigrationStage] {
        [.custom(fromVersion: OldSchema.self, toVersion: NewSchema.self,
                 willMigrate: { _ in
                     print("INJECTED fixture migration callback failure")
                     throw ProbeError.assertion("injected-migration-failure")
                 }, didMigrate: nil)]
    }
}
enum ProbeError: Error { case assertion(String) }
func verify(_ condition: Bool, _ label: String) throws {
    guard condition else { throw ProbeError.assertion(label) }
    print("PASS " + label)
}

@MainActor final class FixtureVersionStore: DatabaseMigrationVersionStoring {
    var version = 0
    func currentVersion(for key: String) -> Int { version }
    func setCurrentVersion(_ version: Int, for key: String) { self.version = version }
}

@main struct DatabaseProbe {
    static func main() async {
        do {
            let phase = CommandLine.arguments[1]
            let url = URL(fileURLWithPath: CommandLine.arguments[2])
            try await runFixture(phase: phase, url: url)
            print("RESULT phase=\(phase) PASS")
        } catch {
            print("RESULT FAILURE \(error)")
            exit(1)
        }
    }
    // A concurrent fixture worker ensures creation does not inherit async main's MainActor.
    @concurrent static func runFixture(phase: String, url: URL) async throws {
            let schema = Schema(versionedSchema: phase.hasPrefix("old") ? OldSchema.self : NewSchema.self)
            let config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
            if phase == "migrate-failure" {
                do {
                    _ = try ModelContainer(for: schema, migrationPlan: FailingFixturePlan.self, configurations: [config])
                    throw ProbeError.assertion("injected-failure-not-observed")
                } catch ProbeError.assertion("injected-failure-not-observed") {
                    throw ProbeError.assertion("injected-failure-not-observed")
                } catch {
                    print("PASS actual-SwiftData-migration-failure-visible")
                }
                return
            }
            if phase.hasPrefix("old") {
                let container = try ModelContainer(for: schema, configurations: [config])
                let manager = SwiftDataModelActorDatabaseManager(modelContainer: container)
                if phase == "old" {
                    try await manager.write { context in
                        context.insert(OldSchema.Record(id: "one", text: "durable-old-one"))
                        context.insert(OldSchema.Record(id: "two", text: "durable-old-two"))
                    }
                }
                let values = try await manager.read { try $0.fetch(FetchDescriptor<OldSchema.Record>()).map(\.text).sorted() }
                try verify(values == ["durable-old-one", "durable-old-two"], phase == "old" ? "old-store-saved" : "failed-migration-old-store-reopen-preserved")
            } else {
                let container = try ModelContainer(for: schema, migrationPlan: FixturePlan.self, configurations: [config])
                let manager = SwiftDataModelActorDatabaseManager(modelContainer: container)
                if phase == "new" {
                    let values = try await manager.read { context in
                        try context.fetch(FetchDescriptor<NewSchema.Record>()).map { $0.id + ":" + $0.text + ":" + ($0.note ?? "nil") }.sorted()
                    }
                    try verify(values == ["one:durable-old-one:nil", "two:durable-old-two:nil"], "lightweight-preserves-old-values")
                    try await manager.write { context in
                        for record in try context.fetch(FetchDescriptor<NewSchema.Record>()) { record.note = "migrated" }
                    }
                    do {
                        try await manager.write { context in
                            context.insert(NewSchema.Record(id: "rollback", text: "discard"))
                            throw DatabaseError.unsupportedOperation("fixture-rejection")
                        }
                        throw ProbeError.assertion("missing-error")
                    } catch DatabaseError.unsupportedOperation {
                        print("PASS typed-failure-preserved")
                    }
                    let rollbackCount = try await manager.read { try $0.fetchCount(FetchDescriptor<NewSchema.Record>()) }
                    try verify(rollbackCount == 2, "write-failure-rollback")
                    let cancelled = Task {
                        withUnsafeCurrentTask { $0?.cancel() }
                        return try await manager.write { context in
                            context.insert(NewSchema.Record(id: "cancel", text: "discard"))
                            try Task.checkCancellation()
                            return 1
                        }
                    }
                    do {
                        _ = try await cancelled.value
                        throw ProbeError.assertion("cancellation-not-observed")
                    } catch DatabaseError.transactionFailed {
                        print("OBSERVED cancellation-wrapped-as-transactionFailed")
                    }
                    let cancelCount = try await manager.read { try $0.fetchCount(FetchDescriptor<NewSchema.Record>()) }
                    try verify(cancelCount == 2, "cooperative-cancellation-rolls-back")
                    try await withThrowingTaskGroup(of: Void.self) { group in
                        for i in 0..<20 {
                            group.addTask {
                                try await manager.write { context in
                                    context.insert(NewSchema.Record(id: "parallel-\(i)", text: "durable-new"))
                                }
                            }
                        }
                        try await group.waitForAll()
                    }
                    let count = try await manager.read { try $0.fetchCount(FetchDescriptor<NewSchema.Record>()) }
                    try verify(count == 22, "actor-concurrent-writes-preserved")
                    try await versionChecks(container)
                } else {
                    let values = try await manager.read { context in
                        try context.fetch(FetchDescriptor<NewSchema.Record>()).map { $0.id + ":" + ($0.note ?? "nil") }.sorted()
                    }
                    try verify(values.count == 22, "separate-process-reopen-count")
                    try verify(values.contains("one:migrated") && values.contains("two:migrated"), "separate-process-reopen-old-fields")
                    try verify(!values.contains(where: { $0.hasPrefix("cancel:") || $0.hasPrefix("rollback:") }), "separate-process-rollback-durable")
                }
            }
    }

    @MainActor static func versionChecks(_ container: ModelContainer) throws {
        let manager = SwiftDataDatabaseManager(modelContainer: container)
        let versions = FixtureVersionStore()
        let runner = DatabaseMigrationRunner(versionStore: versions)
        let steps = [DatabaseMigrationStep(fromVersion: 0, toVersion: 1) { manager in
            try manager.write(DatabaseWriteOperation(swiftData: { _ in }))
        }, DatabaseMigrationStep(fromVersion: 1, toVersion: 2) { _ in
            throw DatabaseError.migrationFailed("fixture-failure")
        }]
        do {
            _ = try runner.migrateIfNeeded(key: "fixture", targetVersion: 2, using: manager, steps: steps)
            throw ProbeError.assertion("version-failure-not-observed")
        } catch DatabaseError.migrationFailed { print("PASS migration-failure-visible") }
        try verify(versions.version == 1, "version-advances-only-after-success")
        let result = try runner.migrateIfNeeded(key: "fixture", targetVersion: 2, using: manager,
            steps: [DatabaseMigrationStep(fromVersion: 1, toVersion: 2) { _ in }])
        try verify(result == 2, "migration-retry-resumes-version")
        let reopened = try runner.migrateIfNeeded(key: "fixture", targetVersion: 2, using: manager, steps: [])
        try verify(reopened == 2, "current-version-is-idempotent")
    }
}
