    static func errorKind(_ error: any Error) -> String {
        if error is CancellationError { return "cancellation" }
        if case DatabaseError.fetchFailed = error { return "fetchFailed" }
        if case DatabaseError.transactionFailed = error { return "transactionFailed" }
        if case DatabaseError.migrationFailed = error { return "migrationFailed" }
        if case DatabaseError.unsupportedOperation = error { return "unsupportedOperation" }
        return "other"
    }

    @concurrent static func cancellationChecks(url: URL, baseline: Bool) async throws {
        let schema = Schema(versionedSchema: NewSchema.self)
        let config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [config])
        let actor = SwiftDataModelActorDatabaseManager(modelContainer: container)
        try await actor.write { $0.insert(NewSchema.Record(id: "sentinel", text: "keep")) }
        do {
            let _: Int = try await actor.read { _ in throw CancellationError() }
            throw ProbeError.assertion("actor-read-missing-cancellation")
        } catch {
            let expected = baseline ? "fetchFailed" : "cancellation"
            try verify(errorKind(error) == expected, "actor-read-" + expected)
            if baseline { print("MISMATCH actor-read CancellationError wrapped") }
        }
        let cancelled = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await actor.write { context in
                context.insert(NewSchema.Record(id: "actor-cancel", text: "discard"))
                try Task.checkCancellation()
                return 1
            }
        }
        do {
            _ = try await cancelled.value
            throw ProbeError.assertion("actor-write-missing-cancellation")
        } catch {
            let expected = baseline ? "transactionFailed" : "cancellation"
            try verify(errorKind(error) == expected, "actor-write-" + expected)
            if baseline { print("MISMATCH actor-write CancellationError wrapped") }
        }
        let count = try await actor.read { try $0.fetchCount(FetchDescriptor<NewSchema.Record>()) }
        try verify(count == 1, "actor-cancellation-rollback")
        try await mainCancellationChecks(container: container, baseline: baseline)
    }

    @MainActor static func mainCancellationChecks(container: ModelContainer, baseline: Bool) throws {
        let manager = SwiftDataDatabaseManager(modelContainer: container)
        manager.modelContext.autosaveEnabled = false
        for operation in ["read", "write", "batch"] {
            do {
                switch operation {
                case "read":
                    let _: Int = try manager.read(DatabaseReadOperation(swiftData: { _ in throw CancellationError() }))
                case "write":
                    try manager.write(DatabaseWriteOperation(swiftData: { context in
                        let record = try context.fetch(FetchDescriptor<NewSchema.Record>())[0]
                        record.text = "discard-update"
                        context.insert(NewSchema.Record(id: "main-write", text: "discard"))
                        throw CancellationError()
                    }))
                default:
                    try manager.writeBatch(DatabaseBatchWriteOperation(swiftData: { context in
                        context.delete(try context.fetch(FetchDescriptor<NewSchema.Record>())[0])
                        context.insert(NewSchema.Record(id: "main-batch", text: "discard"))
                        throw CancellationError()
                    }))
                }
                throw ProbeError.assertion("main-" + operation + "-missing-cancellation")
            } catch {
                let expected = baseline ? (operation == "read" ? "fetchFailed" : "transactionFailed") : "cancellation"
                try verify(errorKind(error) == expected, "main-" + operation + "-" + expected)
                if baseline { print("MISMATCH main-" + operation + " CancellationError wrapped") }
            }
            let values = try manager.read(DatabaseReadOperation(swiftData: {
                try $0.fetch(FetchDescriptor<NewSchema.Record>()).map { $0.id + ":" + $0.text }
            }))
            try verify(values == ["sentinel:keep"], "main-" + operation + "-sentinel-preserved")
        }
        for typed in [false, true] {
            do {
                try manager.write(DatabaseWriteOperation(swiftData: { context in
                    context.insert(NewSchema.Record(id: "ordinary-failure", text: "discard"))
                    if typed { throw DatabaseError.unsupportedOperation("fixture") }
                    throw ProbeError.assertion("ordinary-error")
                }))
                throw ProbeError.assertion("main-missing-ordinary-error")
            } catch {
                try verify(errorKind(error) == (typed ? "unsupportedOperation" : "transactionFailed"),
                           typed ? "typed-error-unchanged" : "generic-error-unchanged")
            }
        }
        let versions = FixtureVersionStore()
        let runner = DatabaseMigrationRunner(versionStore: versions)
        do {
            _ = try runner.migrateIfNeeded(key: "cancel", targetVersion: 2, using: manager, steps: [
                DatabaseMigrationStep(fromVersion: 0, toVersion: 1) { _ in },
                DatabaseMigrationStep(fromVersion: 1, toVersion: 2) { manager in
                    try manager.write(DatabaseWriteOperation(swiftData: { context in
                        context.insert(NewSchema.Record(id: "migration-cancel", text: "discard"))
                        throw CancellationError()
                    }))
                }
            ])
            throw ProbeError.assertion("migration-missing-cancellation")
        } catch {
            // Before repair this nested callback produces transactionFailed, not migrationFailed.
            let expected = baseline ? "transactionFailed" : "cancellation"
            try verify(errorKind(error) == expected, "migration-nested-" + expected)
        }
        try verify(versions.version == 1, "cancelled-migration-version-not-advanced")
        do {
            _ = try runner.migrateIfNeeded(key: "cancel", targetVersion: 2, using: manager,
                steps: [DatabaseMigrationStep(fromVersion: 1, toVersion: 2) { _ in throw CancellationError() }])
            throw ProbeError.assertion("direct-migration-missing-cancellation")
        } catch {
            let expected = baseline ? "migrationFailed" : "cancellation"
            try verify(errorKind(error) == expected, "migration-direct-" + expected)
            if baseline { print("MISMATCH migration-runner CancellationError wrapped") }
        }
        try verify(versions.version == 1, "direct-cancelled-migration-version-not-advanced")
        let retried = try runner.migrateIfNeeded(key: "cancel", targetVersion: 2, using: manager,
            steps: [DatabaseMigrationStep(fromVersion: 1, toVersion: 2) { _ in }])
        try verify(retried == 2 && versions.version == 2, "cancelled-migration-retry-success")
        let count = try manager.read(DatabaseReadOperation(swiftData: { try $0.fetchCount(FetchDescriptor<NewSchema.Record>()) }))
        try verify(count == 1 && !manager.modelContext.hasChanges, "all-main-failures-rollback")
    }
