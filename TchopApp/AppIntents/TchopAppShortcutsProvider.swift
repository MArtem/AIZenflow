import AppIntents

/// Registers TchopApp's user-facing App Shortcuts with the system.
///
/// Ownership:
/// This provider intentionally lives in the app target, not in the reusable package, so Shortcuts/Siri
/// metadata discovery sees the provider and its exposed intent in the same executable target.
struct TchopAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateTextFeedCardIntent(),
            phrases: [
                "Create a text card in \(.applicationName)",
                "Add a text card to \(.applicationName)"
            ],
            shortTitle: "Create Card",
            systemImageName: "text.badge.plus"
        )
    }

    static var shortcutTileColor: ShortcutTileColor { .blue }
}
