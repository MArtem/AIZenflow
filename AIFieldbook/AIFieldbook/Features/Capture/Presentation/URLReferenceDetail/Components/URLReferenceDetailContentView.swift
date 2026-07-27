import SwiftUI

/// Passive metadata surface for a prepared locally stored web link.
struct URLReferenceDetailContentView: View {
    let content: URLReferenceDetailContentState

    var body: some View {
        List {
            Section("Address") {
                Link(destination: content.url) {
                    Label(content.urlText, systemImage: "safari")
                }
            }
            if !content.notes.isEmpty {
                Section("Notes") {
                    Text(content.notes)
                }
            }
            if !content.tags.isEmpty {
                Section("Tags") {
                    TagListView(tags: content.tags)
                }
            }
            Section("Metadata") {
                Text(content.updatedAtText)
            }
        }
    }
}
