import Combine
import Foundation

/// Persistence contract for the user-scoped selected channel runtime preference.
protocol ChannelSelectionStoring {
    /// Loads the last selected channel identifier for the provided user.
    func loadSelectedChannelID(for userID: String) -> String?

    /// Persists the selected channel identifier for the provided user.
    func saveSelectedChannelID(_ channelID: String?, for userID: String)
}

/// UserDefaults-backed store for selected-channel persistence.
struct UserDefaultsChannelSelectionStore: ChannelSelectionStoring {
    private let userDefaults: UserDefaults
    private let keyPrefix: String

    /// Creates the selected-channel persistence adapter.
    init(
        userDefaults: UserDefaults = .standard,
        keyPrefix: String = "selected_channel_id"
    ) {
        self.userDefaults = userDefaults
        self.keyPrefix = keyPrefix
    }

    /// Loads the last selected channel identifier for the provided user.
    func loadSelectedChannelID(for userID: String) -> String? {
        userDefaults.string(forKey: storageKey(for: userID))
    }

    /// Persists the selected channel identifier for the provided user.
    func saveSelectedChannelID(_ channelID: String?, for userID: String) {
        let key = storageKey(for: userID)
        if let channelID {
            userDefaults.set(channelID, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }

    /// Builds the user-scoped persistence key for one selected-channel value.
    private func storageKey(for userID: String) -> String {
        "\(keyPrefix).\(userID)"
    }
}

/// App-wide runtime store for available channels and the current user-scoped channel selection.
///
/// This store keeps the current channel snapshot in memory and persists only the minimal selected
/// channel preference needed to restore the session quickly on next launch.
@MainActor
final class ChannelsStore: ObservableObject {
    /// All channels currently available to the active user session.
    @Published private(set) var channels: [AppChannel] = []

    /// Identifier of the active channel currently driving the visible feed context.
    @Published private(set) var selectedChannelID: String?

    private let selectionStore: any ChannelSelectionStoring
    private var activeUserID: String?

    /// Creates the runtime channels store with its selected-channel persistence adapter.
    init(selectionStore: any ChannelSelectionStoring) {
        self.selectionStore = selectionStore
    }

    /// Currently selected channel derived from the active identifier and available channel list.
    var selectedChannel: AppChannel? {
        guard let selectedChannelID else {
            return channels.first
        }

        return channels.first(where: { $0.id == selectedChannelID }) ?? channels.first
    }

    /// Header information derived from the currently selected channel.
    var selectedChannelHeaderInfo: ChannelHeaderInfo? {
        selectedChannel?.headerInfo
    }

    /// Replaces the available channel snapshot and keeps the active selection valid.
    func setAvailableChannels(_ channels: [AppChannel]) {
        self.channels = channels.sorted { lhs, rhs in
            if lhs.id == AppChannel.primary.id {
                return true
            }
            if rhs.id == AppChannel.primary.id {
                return false
            }

            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
        ensureValidSelection()
    }

    /// Activates the store for one authenticated user and resolves the initial selected channel.
    func activate(
        for userID: String,
        preferredSelectedChannelID: String?
    ) {
        activeUserID = userID
        let persistedChannelID = selectionStore.loadSelectedChannelID(for: userID)
        if let persistedChannelID, channels.contains(where: { $0.id == persistedChannelID }) {
            selectedChannelID = persistedChannelID
        } else if let preferredSelectedChannelID, channels.contains(where: { $0.id == preferredSelectedChannelID }) {
            selectedChannelID = preferredSelectedChannelID
        } else {
            selectedChannelID = channels.first?.id
        }

        persistSelectionIfNeeded()
    }

    /// Clears the current user context and resets channel selection back to an unauthenticated state.
    func reset() {
        activeUserID = nil
        selectedChannelID = nil
    }

    /// Applies a new user-selected active channel and persists it when the choice is valid.
    func selectChannel(id: String?) {
        guard let id else {
            selectedChannelID = channels.first?.id
            persistSelectionIfNeeded()
            return
        }

        guard channels.contains(where: { $0.id == id }) else {
            return
        }

        guard selectedChannelID != id else {
            return
        }

        selectedChannelID = id
        persistSelectionIfNeeded()
    }

    /// Restores or defaults the selected channel after the available channel list changes.
    private func ensureValidSelection() {
        if let selectedChannelID, channels.contains(where: { $0.id == selectedChannelID }) {
            return
        }

        selectedChannelID = channels.first?.id
        persistSelectionIfNeeded()
    }

    /// Persists the current selected channel when a user session is active.
    private func persistSelectionIfNeeded() {
        guard let activeUserID else {
            return
        }

        selectionStore.saveSelectedChannelID(selectedChannelID, for: activeUserID)
    }
}
