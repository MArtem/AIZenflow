import SwiftUI

enum FieldbookColor {
    static let canvas = Color(.systemGroupedBackground)
    static let surface = Color(.secondarySystemGroupedBackground)
    static let elevatedSurface = Color(.tertiarySystemGroupedBackground)
    static let accent = Color.indigo
    static let destructive = Color.red
}

enum FieldbookSpacing {
    static let compact: CGFloat = 8
    static let standard: CGFloat = 12
    static let section: CGFloat = 20
    static let screen: CGFloat = 24
}

enum FieldbookRadius {
    static let control: CGFloat = 12
    static let card: CGFloat = 16
}

enum FieldbookTypography {
    static let screenTitle = Font.largeTitle.bold()
    static let sectionTitle = Font.title3.weight(.semibold)
    static let body = Font.body
    static let supporting = Font.subheadline
}

struct FieldbookCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(FieldbookSpacing.standard)
            .background(FieldbookColor.surface)
            .clipShape(.rect(cornerRadius: FieldbookRadius.card))
    }
}

extension View {
    func fieldbookCard() -> some View {
        modifier(FieldbookCardModifier())
    }
}
