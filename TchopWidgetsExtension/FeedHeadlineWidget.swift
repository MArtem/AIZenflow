import SwiftUI
import WidgetKit
import TchopWidgets

/// Widget entry carrying the latest cached feed headline.
struct FeedHeadlineWidgetEntry: TimelineEntry {
    let date: Date
    let headline: String
}

/// Reads the snapshot written by the main app and exposes it to WidgetKit.
struct FeedHeadlineWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FeedHeadlineWidgetEntry {
        FeedHeadlineWidgetEntry(
            date: Date(),
            headline: "Parrots help others..."
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FeedHeadlineWidgetEntry) -> Void) {
        // Snapshots and previews use the same cached-loading path so the widget stays close to the
        // production rendering behavior.
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FeedHeadlineWidgetEntry>) -> Void) {
        // The widget is intentionally cheap: render one cached headline and ask WidgetKit to come
        // back later in case the main app has already written a fresher snapshot.
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
        // Keep the widget renderable even when the shared app-group snapshot is unavailable, such
        // as in previews or before the main app has performed its first sync.
        let headline = (try? snapshotManager.load())?.headline ?? "Parrots help others..."
        return FeedHeadlineWidgetEntry(
            date: Date(),
            headline: headline
        )
    }

    /// Uses the shared app-group defaults in production and standard defaults as a safe preview fallback.
    private var snapshotManager: UserDefaultsFeedHeadlineWidgetSnapshotManager {
        (try? UserDefaultsFeedHeadlineWidgetSnapshotManager(
            suiteName: AppGroupConfiguration.widgetsSuiteName
        )) ?? UserDefaultsFeedHeadlineWidgetSnapshotManager(userDefaults: .standard)
    }
}

/// Visual presentation for the cached headline snapshot.
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

/// Widget declaration surfaced on the user's home screen.
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

#if DEBUG
#Preview("Widget Entry View") {
    FeedHeadlineWidgetEntryView(
        entry: FeedHeadlineWidgetEntry(
            date: Date(),
            headline: "Parrots help others in need, study shows for first time"
        )
    )
    .frame(width: 170, height: 170)
}

struct FeedHeadlineWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FeedHeadlineWidgetEntryView(
                entry: FeedHeadlineWidgetEntry(
                    date: Date(),
                    headline: "Parrots help others in need, study shows for first time"
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))

            FeedHeadlineWidgetEntryView(
                entry: FeedHeadlineWidgetEntry(
                    date: Date(),
                    headline: "Parrots help others in need, study shows for first time"
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
#endif
