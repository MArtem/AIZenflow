import CoreSpotlight
import Foundation
import OSLog
import UniformTypeIdentifiers

/// Owns optional Core Spotlight indexing for local fieldbook content.
///
/// Privacy contract:
/// Spotlight exposes titles, subtitles, tags, and workspace names to system search. Iteration 1
/// keeps indexing disabled until the product has an explicit user-facing opt-in. The clear path
/// is still active so destructive local-data flows can remove indexes created by older builds or
/// future opt-in sessions.
actor SpotlightIndexService {
    private let index = CSSearchableIndex.default()
    private let isIndexingEnabled: Bool
    private let logger = Logger(subsystem: "com.zenflow.AIFieldbook", category: "Spotlight")

    init(isIndexingEnabled: Bool = false) {
        self.isIndexingEnabled = isIndexingEnabled
    }

    func rebuildIfAllowed(searchIndex: FieldbookSearchIndex) async {
        guard isIndexingEnabled else {
            await clear()
            return
        }

        do {
            let searchableItems = try await searchIndex.spotlightEntries().map { entry in
                let attributes = CSSearchableItemAttributeSet(contentType: .folder)
                attributes.title = entry.title
                attributes.contentDescription = entry.subtitle
                attributes.keywords = entry.keywords

                let uniqueIdentifier: String
                let domainIdentifier: String
                switch entry.kind {
                case .workspace:
                    uniqueIdentifier = "workspace:\(entry.id.uuidString)"
                    domainIdentifier = "AIFieldbook.Workspaces"
                case let .item(kind):
                    uniqueIdentifier = "item:\(entry.id.uuidString):\(kind.rawValue)"
                    domainIdentifier = "AIFieldbook.Items"
                }
                let item = CSSearchableItem(
                    uniqueIdentifier: uniqueIdentifier,
                    domainIdentifier: domainIdentifier,
                    attributeSet: attributes
                )
                item.expirationDate = .distantFuture
                return item
            }
            try await index.deleteAllSearchableItems()
            if !searchableItems.isEmpty { try await index.indexSearchableItems(searchableItems) }
        } catch {
            let nsError = error as NSError
            logger.error(
                "Spotlight rebuild failed domain=\(nsError.domain, privacy: .public) code=\(nsError.code)"
            )
        }
    }

    func clear() async {
        do {
            try await index.deleteAllSearchableItems()
        } catch {
            let nsError = error as NSError
            logger.error(
                "Spotlight cleanup failed domain=\(nsError.domain, privacy: .public) code=\(nsError.code)"
            )
        }
    }
}
