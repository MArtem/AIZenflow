import SwiftUI

/// Floating action button anchored above the bottom tab bar.
struct FloatingActionButton: View {
    private static let buttonSize: CGFloat = 56
    private static let iconSize: CGFloat = 24
    private static let figmaFill = Color(red: 243.0 / 255.0, green: 115.0 / 255.0, blue: 84.0 / 255.0)
    private static let figmaPrimaryShadow = Color(red: 40.0 / 255.0, green: 41.0 / 255.0, blue: 61.0 / 255.0)
    private static let figmaSecondaryShadow = Color(red: 96.0 / 255.0, green: 97.0 / 255.0, blue: 112.0 / 255.0)

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Self.figmaFill)
                    .frame(width: Self.buttonSize, height: Self.buttonSize)
                    .shadow(color: Self.figmaPrimaryShadow.opacity(0.04), radius: 4, y: 2)
                    .shadow(color: Self.figmaSecondaryShadow.opacity(0.16), radius: 16, y: 8)

                Image("ShellCreateAdd")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: Self.iconSize, height: Self.iconSize)
                    .accessibilityHidden(true)
            }
            .frame(width: Self.buttonSize, height: Self.buttonSize)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("shell.fab.create")
        .accessibilityLabel(AppLocalization.text("accessibility.fab.create"))
        .accessibilityHint(AppLocalization.text("accessibility.fab.createHint"))
        .accessibilityRepresentation {
            Button(AppLocalization.text("accessibility.fab.create"), action: action)
                .accessibilityIdentifier("shell.fab.create")
                .accessibilityHint(AppLocalization.text("accessibility.fab.createHint"))
        }
    }
}

#if DEBUG
#Preview("Floating Action Button") {
    FloatingActionButton(action: {})
        .padding()
        .background(AppTheme.canvasBackground)
}
#endif
