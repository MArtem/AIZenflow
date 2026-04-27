import Foundation

/// Tracks one family of card-level tasks and additive queued actions.
@MainActor
final class NewsFeedCardActionCoordinator {
    private var tasks: [String: Task<Void, Never>] = [:]
    private var queuedAdditiveActions: [String: Int] = [:]

    func start(_ task: Task<Void, Never>, for cardID: String) {
        tasks[cardID] = task
    }

    func queueAdditiveAction(for cardID: String) {
        queuedAdditiveActions[cardID, default: 0] += 1
    }

    func consumeQueuedAdditiveAction(for cardID: String) -> Bool {
        let remainingCount = queuedAdditiveActions[cardID] ?? 0
        guard remainingCount > 0 else {
            queuedAdditiveActions[cardID] = nil
            return false
        }

        queuedAdditiveActions[cardID] = remainingCount - 1
        return true
    }

    func clear(cardID: String) {
        tasks[cardID] = nil
        queuedAdditiveActions[cardID] = nil
    }

    func cancelAll() {
        for task in tasks.values {
            task.cancel()
        }
        tasks.removeAll()
        queuedAdditiveActions.removeAll()
    }

    deinit {
        for task in tasks.values {
            task.cancel()
        }
    }
}
