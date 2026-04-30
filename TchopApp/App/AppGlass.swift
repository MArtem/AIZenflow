import SwiftUI

/// Availability-gated wrapper that groups custom glass elements when the runtime supports Liquid Glass.
struct AppGlassContainer<Content: View>: View {
    let spacing: CGFloat?
    let content: () -> Content

    /// Creates a glass container that falls back to a plain view hierarchy on older systems.
    init(
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.content = content
    }

    /// Builds either a native glass container or the unmodified content tree.
    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) {
                content()
            }
        } else {
            content()
        }
    }
}

/// Availability-gated custom chrome styling that uses native Liquid Glass on supported systems.
private struct AppGlassChromeModifier<ChromeShape: Shape>: ViewModifier {
    let shape: ChromeShape
    let fallbackBackground: Color
    let fallbackShadowColor: Color
    let fallbackShadowRadius: CGFloat
    let fallbackShadowX: CGFloat
    let fallbackShadowY: CGFloat
    let interactive: Bool

    /// Applies either native glass chrome or the pre-iOS-26 fallback surface.
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(
                    interactive ? .regular.interactive() : .regular,
                    in: shape
                )
        } else {
            content
                .background(fallbackBackground)
                .clipShape(shape)
                .shadow(
                    color: fallbackShadowColor,
                    radius: fallbackShadowRadius,
                    x: fallbackShadowX,
                    y: fallbackShadowY
                )
        }
    }
}

extension View {
    /// Styles a floating chrome surface with native Liquid Glass on iOS 26 and a themed fallback on older systems.
    func appGlassChrome<ChromeShape: Shape>(
        in shape: ChromeShape,
        fallbackBackground: Color,
        fallbackShadowColor: Color = .clear,
        fallbackShadowRadius: CGFloat = 0,
        fallbackShadowX: CGFloat = 0,
        fallbackShadowY: CGFloat = 0,
        interactive: Bool = false
    ) -> some View {
        modifier(
            AppGlassChromeModifier(
                shape: shape,
                fallbackBackground: fallbackBackground,
                fallbackShadowColor: fallbackShadowColor,
                fallbackShadowRadius: fallbackShadowRadius,
                fallbackShadowX: fallbackShadowX,
                fallbackShadowY: fallbackShadowY,
                interactive: interactive
            )
        )
    }
}
