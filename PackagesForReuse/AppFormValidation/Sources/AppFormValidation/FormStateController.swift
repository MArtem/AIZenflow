import Foundation

public actor FormStateController {
    private let formID: FormID
    private let store: any FormSnapshotStore
    private let validator: FormValidator
    private let operationQueue = FormStateControllerOperationQueue()

    public init(formID: FormID, initialSnapshot: FormSnapshot, store: any FormSnapshotStore, validator: FormValidator) async throws {
        guard formID == initialSnapshot.formID else {
            throw FormValidationFailure.formMismatch
        }
        self.formID = formID
        self.store = store
        self.validator = validator
        try await store.save(initialSnapshot)
    }

    public func currentSnapshot() async throws -> FormSnapshot {
        try await loadCurrentSnapshot()
    }

    public func updateField(_ fieldID: FormFieldID, value: FormFieldValue, markTouched: Bool = true) async throws -> FormSnapshot {
        try await operationQueue.run { [formID, store] in
            guard let current = try await store.load(formID: formID) else {
                throw FormValidationFailure.missingSnapshot
            }
            let next = try current.updatingField(fieldID, value: value, markTouched: markTouched)
            try await store.save(next)
            return next
        }
    }

    public func markTouched(_ fieldID: FormFieldID) async throws -> FormSnapshot {
        try await operationQueue.run { [formID, store] in
            guard let current = try await store.load(formID: formID) else {
                throw FormValidationFailure.missingSnapshot
            }
            let next = try current.markingTouched(fieldID)
            try await store.save(next)
            return next
        }
    }

    public func validateCurrent() async throws -> FormValidationResult {
        try await operationQueue.run { [formID, store, validator] in
            guard let snapshot = try await store.load(formID: formID) else {
                throw FormValidationFailure.missingSnapshot
            }
            return try await validator.validate(snapshot)
        }
    }

    private func loadCurrentSnapshot() async throws -> FormSnapshot {
        guard let snapshot = try await store.load(formID: formID) else {
            throw FormValidationFailure.missingSnapshot
        }
        return snapshot
    }
}

private actor FormStateControllerOperationQueue {
    private var isLocked = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func run<Output: Sendable>(_ operation: @Sendable @escaping () async throws -> Output) async throws -> Output {
        await acquire()
        do {
            let output = try await operation()
            release()
            return output
        } catch {
            release()
            throw error
        }
    }

    private func acquire() async {
        if !isLocked {
            isLocked = true
            return
        }

        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    private func release() {
        guard !waiters.isEmpty else {
            isLocked = false
            return
        }
        let next = waiters.removeFirst()
        next.resume()
    }
}
