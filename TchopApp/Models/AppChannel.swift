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

    /// Header presentation model derived from the current channel snapshot.
    var headerInfo: ChannelHeaderInfo {
        ChannelHeaderInfo(
            title: AppLocalization.text("channel.header.title"),
            subtitle: title
        )
    }
}
