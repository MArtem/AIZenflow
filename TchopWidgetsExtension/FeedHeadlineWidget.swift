import SwiftUI
import WidgetKit
import TchopWidgets

struct FeedHeadlineWidgetEntry: TimelineEntry {
    let date: Date
    let headline: String
}

struct FeedHeadlineWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FeedHeadlineWidgetEntry {
        FeedHeadlineWidgetEntry(
            date: Date(),
            headline: "Parrots help others..."
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FeedHeadlineWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FeedHeadlineWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: entry.date) ?? entry.date
        completion(
            Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )
        )
    }

    private func loadEntry() -> FeedHeadlineWidgetEntry {
        let headline = (try? snapshotManager.load())?.headline ?? "Parrots help others..."
        return FeedHeadlineWidgetEntry(
            date: Date(),
            headline: headline
        )
    }

    private var snapshotManager: UserDefaultsFeedHeadlineWidgetSnapshotManager {
        (try? UserDefaultsFeedHeadlineWidgetSnapshotManager(
            suiteName: AppGroupConfiguration.widgetsSuiteName
        )) ?? UserDefaultsFeedHeadlineWidgetSnapshotManager(userDefaults: .standard)
    }
}

struct FeedHeadlineWidgetEntryView: View {
    let entry: FeedHeadlineWidgetProvider.Entry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.55, blue: 0.38),
                    Color(red: 0.84, green: 0.25, blue: 0.19)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 10) {
                Text("Feed")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))

                Text(entry.headline)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(4)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(16)
        }
    }
}

struct FeedHeadlineWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: FeedHeadlineWidgetConstants.widgetKind,
            provider: FeedHeadlineWidgetProvider()
        ) { entry in
            FeedHeadlineWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Feed Headline")
        .description("Shows the title of the first card on the feed screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
