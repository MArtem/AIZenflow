import SwiftUI

struct FeatureTabScaffoldView: View {
    let content: FeatureTabContent
    let onQuickActionTap: (FeatureQuickAction) -> Void
    let onItemTap: (FeatureTabItem) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(content.subtitle.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(Color(red: 0.95, green: 0.50, blue: 0.37))

                    Text(content.title)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color(red: 0.24, green: 0.25, blue: 0.36))

                    Text(content.summary)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(red: 0.35, green: 0.36, blue: 0.44))
                        .lineSpacing(3)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 12, y: 6)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(content.quickActions) { action in
                            Button(action: { onQuickActionTap(action) }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Image(systemName: action.systemImageName)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color(red: 0.95, green: 0.50, blue: 0.37))

                                    Text(action.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color(red: 0.24, green: 0.25, blue: 0.36))

                                    Text(action.caption)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color(red: 0.52, green: 0.53, blue: 0.60))
                                }
                                .padding(16)
                                .frame(width: 150, alignment: .leading)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 2)
                }

                ForEach(content.sections) { section in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(section.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color(red: 0.24, green: 0.25, blue: 0.36))

                        ForEach(section.items) { item in
                            Button(action: { onItemTap(item) }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(alignment: .top) {
                                        Text(item.eyebrow.uppercased())
                                            .font(.system(size: 11, weight: .bold))
                                            .tracking(0.8)
                                            .foregroundStyle(Color(red: 0.95, green: 0.50, blue: 0.37))

                                        Spacer(minLength: 12)

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(Color(red: 0.73, green: 0.74, blue: 0.78))
                                    }

                                    Text(item.title)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color(red: 0.24, green: 0.25, blue: 0.36))

                                    Text(item.summary)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color(red: 0.35, green: 0.36, blue: 0.44))
                                        .lineSpacing(2)

                                    Text(item.metadata)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(Color(red: 0.52, green: 0.53, blue: 0.60))
                                }
                                .padding(18)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
