import SwiftUI

/// Passive list of currently available local capture actions.
struct CaptureOptionsView: View {
    let createTextNote: () -> Void
    let importItem: (ImportKind) -> Void
    let createURLReference: () -> Void
    let recordAudio: () -> Void

    var body: some View {
        List {
            Section("Available Now") {
                Button("New Text Note", systemImage: "square.and.pencil", action: createTextNote)
                Button("New Web Link", systemImage: "link.badge.plus", action: createURLReference)
                Button("Record Audio", systemImage: "mic.circle", action: recordAudio)

                ForEach(ImportKind.allCases) { kind in
                    Button {
                        importItem(kind)
                    } label: {
                        Label("Import \(kind.title)", systemImage: kind.systemImage)
                    }
                }
            }
        }
    }
}
