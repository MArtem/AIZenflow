import Foundation

/// Domain-level channel available to the current signed-in user.
struct AppChannel: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String

    static let primary = AppChannel(
        id: "primary-channel",
        title: AppLocalization.text("channel.default.title"),
        subtitle: AppLocalization.text("channel.default.subtitle")
    )

    /// Header presentation model derived from the current channel snapshot.
    var headerInfo: ChannelHeaderInfo {
        ChannelHeaderInfo(title: title, subtitle: subtitle)
    }
}
