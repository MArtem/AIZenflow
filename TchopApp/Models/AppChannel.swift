import Foundation

/// Domain-level channel available to the current signed-in user.
struct AppChannel: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String

    static let product = AppChannel(
        id: "product-channel",
        title: AppLocalization.text("channel.product.title"),
        subtitle: AppLocalization.text("channel.product.subtitle")
    )

    static let community = AppChannel(
        id: "community-channel",
        title: AppLocalization.text("channel.community.title"),
        subtitle: AppLocalization.text("channel.community.subtitle")
    )

    static let leadership = AppChannel(
        id: "leadership-channel",
        title: AppLocalization.text("channel.leadership.title"),
        subtitle: AppLocalization.text("channel.leadership.subtitle")
    )

    static let defaultChannel = product

    /// Header presentation model derived from the current channel snapshot.
    var headerInfo: ChannelHeaderInfo {
        ChannelHeaderInfo(
            title: title,
            subtitle: subtitle
        )
    }
}
