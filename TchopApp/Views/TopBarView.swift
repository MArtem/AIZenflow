import SwiftUI

struct TopBarView: View {
    let channelInfo: ChannelHeaderInfo
    var onMenuTap: () -> Void
    var onChannelTap: () -> Void
    var onSearchTap: () -> Void
    var onNotificationsTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onMenuTap) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color(red: 0.31, green: 0.33, blue: 0.40))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Button(action: onChannelTap) {
                    HStack(spacing: 12) {
                        BrandMarkView(iconSize: 48, cardSize: CGSize(width: 28, height: 34))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(channelInfo.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(red: 0.20, green: 0.22, blue: 0.30))

                            HStack(spacing: 4) {
                                Text(channelInfo.subtitle)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(.gray)

                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 18) {
                    Button(action: onSearchTap) {
                        Image(systemName: "magnifyingglass")
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)

                    Button(action: onNotificationsTap) {
                        Image(systemName: "bell")
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(Color(red: 0.62, green: 0.64, blue: 0.69))
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 14)
            .background(Color.white)

            Divider()
                .overlay(Color.gray.opacity(0.12))
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        .zIndex(1)
    }
}
