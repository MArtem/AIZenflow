import SwiftUI

/// App-local semantic colors for AI Fieldbook screens.
///
/// Scope:
/// These tokens are product-specific and intentionally stay in the app target until a
/// reusable design-system package has an approved cross-app contract.
enum FieldbookColor {
    static let canvas = Color(.systemGroupedBackground)
    static let surface = Color(.secondarySystemGroupedBackground)
    static let elevatedSurface = Color(.tertiarySystemGroupedBackground)
    static let accent = Color.indigo
    static let destructive = Color.red
}

/// App-local spacing scale used to keep repeated screen layouts visually consistent.
enum FieldbookSpacing {
    static let compact: CGFloat = 8
    static let standard: CGFloat = 12
    static let section: CGFloat = 20
    static let screen: CGFloat = 24
}

/// App-local radius scale for controls and card surfaces.
enum FieldbookRadius {
    static let control: CGFloat = 12
    static let card: CGFloat = 16
}

/// App-local typography aliases that preserve Dynamic Type through system text styles.
enum FieldbookTypography {
    static let screenTitle = Font.largeTitle.bold()
    static let sectionTitle = Font.title3.weight(.semibold)
    static let body = Font.body
    static let supporting = Font.subheadline
}

/// Shared card surface modifier for non-repeated container sections.
///
/// Performance contract:
/// Use for bounded screen sections. Repeated rows should still be reviewed for overdraw and
/// broad invalidation before adopting additional visual effects.
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
