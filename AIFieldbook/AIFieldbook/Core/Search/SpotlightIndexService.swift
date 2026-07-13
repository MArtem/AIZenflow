import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

struct SpotlightIndexService {
    private let index = CSSearchableIndex.default()

    @MainActor
    func rebuild(repository: FieldbookRepository) async {
        do {
            var searchableItems: [CSSearchableItem] = []
            for workspace in try repository.fetchWorkspaces() {
                let attributes = CSSearchableItemAttributeSet(contentType: .folder)
                attributes.title = workspace.name
                attributes.contentDescription = String(localized: "AI Fieldbook workspace")
                let item = CSSearchableItem(
                    uniqueIdentifier: "workspace:\(workspace.id.uuidString)",
                    domainIdentifier: "AIFieldbook.Workspaces",
                    attributeSet: attributes
                )
                item.expirationDate = .distantFuture
                searchableItems.append(item)

                for summary in try repository.fetchKnowledgeItems(workspaceID: workspace.id) {
                    let itemAttributes = CSSearchableItemAttributeSet(contentType: .content)
                    itemAttributes.title = summary.displayTitle
                    itemAttributes.contentDescription = summary.subtitle
                    itemAttributes.keywords = summary.tags.map(\.name) + [workspace.name, summary.kind.displayName]
                    let searchable = CSSearchableItem(
                        uniqueIdentifier: "item:\(summary.id.uuidString):\(summary.kind.rawValue)",
                        domainIdentifier: "AIFieldbook.Items",
                        attributeSet: itemAttributes
                    )
                    searchable.expirationDate = .distantFuture
                    searchableItems.append(searchable)
                }
            }
            try await index.deleteAllSearchableItems()
            if !searchableItems.isEmpty { try await index.indexSearchableItems(searchableItems) }
        } catch {
            // Spotlight is supplementary; local content remains available in-app.
        }
    }

    func clear() async { try? await index.deleteAllSearchableItems() }
}
