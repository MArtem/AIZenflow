import SwiftUI
import WidgetKit

/// Stable identifiers used by the widget extension to read the app-written feed headline snapshot.
enum FeedHeadlineWidgetConstants {
    static let widgetKind = "FeedHeadlineWidget"
    static let snapshotKey = "widgets.feed.headline.snapshot"
}

/// Widget-local copy of the app-written feed headline snapshot payload.
struct FeedHeadlineWidgetSnapshot: Codable, Equatable, Sendable {
    let headline: String
    let updatedAt: Date
}

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
            headline: FeedHeadlineWidgetLocalization.text("widget.feedHeadline.placeholder")
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
        let headline = (try? snapshotManager.load())?.headline
            ?? FeedHeadlineWidgetLocalization.text("widget.feedHeadline.placeholder")
        return FeedHeadlineWidgetEntry(
            date: Date(),
            headline: headline
        )
    }

    /// Uses the shared app-group defaults in production and standard defaults as a safe preview fallback.
    private var snapshotManager: UserDefaultsWidgetSnapshotStore<FeedHeadlineWidgetSnapshot> {
        (try? UserDefaultsWidgetSnapshotStore<FeedHeadlineWidgetSnapshot>(
            suiteName: AppGroupConfiguration.widgetsSuiteName,
            snapshotKey: FeedHeadlineWidgetConstants.snapshotKey
        )) ?? UserDefaultsWidgetSnapshotStore<FeedHeadlineWidgetSnapshot>(
            snapshotKey: FeedHeadlineWidgetConstants.snapshotKey
        )
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
                Text(FeedHeadlineWidgetLocalization.text("widget.feed.label"))
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
        .configurationDisplayName(FeedHeadlineWidgetLocalization.text("widget.feedHeadline.displayName"))
        .description(FeedHeadlineWidgetLocalization.text("widget.feedHeadline.description"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#if DEBUG
#Preview("Widget Entry View") {
    FeedHeadlineWidgetEntryView(
        entry: FeedHeadlineWidgetEntry(
            date: Date(),
            headline: FeedHeadlineWidgetLocalization.text("widget.feedHeadline.preview")
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
                    headline: FeedHeadlineWidgetLocalization.text("widget.feedHeadline.preview")
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))

            FeedHeadlineWidgetEntryView(
                entry: FeedHeadlineWidgetEntry(
                    date: Date(),
                    headline: FeedHeadlineWidgetLocalization.text("widget.feedHeadline.preview")
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
#endif

/// Widget-local copy helper backed by Tchop app localization resources.
private enum FeedHeadlineWidgetLocalization {
    static func text(_ key: String) -> String {
        TchopProductLocalizationResources.localized(key, localeIdentifier: nil)
    }
}
