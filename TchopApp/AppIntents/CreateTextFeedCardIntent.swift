import AppIntents
import Foundation

/// Test App Intent that creates a source-neutral text feed card through the existing app-group import path.
///
/// Created by system App Intents runtime when the user runs the matching Shortcuts/Siri action.
/// The intent keeps only the product action here; generic validation remains in `AppIntentSupport`, and
/// feed persistence still flows through `SharedFeedCardSyncManager` so the app imports the card through
/// the same durable path used by the share extension.
struct CreateTextFeedCardIntent: AppIntent {
    static let title: LocalizedStringResource = "Create Text Card"
    static let description = IntentDescription("Creates a test text card in Tchop.")
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    static var supportedModes: IntentModes { .background }

    @Parameter(
        title: "Text",
        description: "Text to publish into the Tchop feed."
    )
    var text: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let normalizedText: String
        do {
            normalizedText = try AppIntentTextNormalizer.requiredText(
                text,
                fieldName: "Text",
                maximumCharacterCount: 200
            )
        } catch AppIntentSupportValidationFailure.emptyRequiredText {
            return .result(
                dialog: "Enter text before creating a card."
            )
        } catch AppIntentSupportValidationFailure.textExceedsLimit {
            return .result(
                dialog: "Text must be 200 characters or fewer."
            )
        }

        let sessionContext = try await loadSessionContext()
        guard sessionContext?.isAuthenticated == true else {
            return .result(
                dialog: "Open Tchop and sign in before creating cards from Shortcuts."
            )
        }

        let selectedChannelID = sessionContext?.selectedChannelID
            ?? sessionContext?.availableChannels.first?.id
            ?? AppChannel.defaultChannel.id

        var draft = FeedComposerDraft(selectedChannelID: selectedChannelID)
        draft.updateText(normalizedText, for: .text)

        guard let card = draft.makeCard()?.feedCardModel else {
            throw AppIntentSupportValidationFailure.emptyRequiredText(fieldName: "Text")
        }

        let syncManager = try SharedFeedCardSyncManager(
            groupIdentifier: AppGroupConfiguration.sharedContainerIdentifier
        )
        try await syncManager.publishImportedCard(card)

        return .result(
            dialog: "Created a text card. Open Tchop to sync it into the feed."
        )
    }
}

private extension CreateTextFeedCardIntent {
    func loadSessionContext() async throws -> ShareExtensionSessionContext? {
        try await MainActor.run {
            let manager = try ShareExtensionSessionContextManager(
                groupIdentifier: AppGroupConfiguration.sharedContainerIdentifier
            )
            return try manager.loadContext()
        }
    }
}
