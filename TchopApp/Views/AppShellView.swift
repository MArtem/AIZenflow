import SwiftUI

/// Root authenticated shell with side menu and tab content container.
struct AppShellView: View {
    fileprivate static let menuAnimation = Animation.spring(response: 0.28, dampingFraction: 0.88)
    fileprivate static let menuEdgeActivationWidth: CGFloat = 28
    fileprivate static let menuDismissOverlayWidth: CGFloat = 24
    fileprivate static let menuDragThresholdRatio: CGFloat = 0.22

    let viewModel: AppShellViewModel
    let coordinator: AppCoordinator
    let currentUser: AppUser?
    let profileTabViewModel: ProfileTabViewModel?
    let onLogout: () -> Void
    @GestureState private var menuDragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let menuMetrics = menuMetrics(for: proxy.size.width)

            ZStack(alignment: .leading) {
                AppTheme.canvasBackground
                    .ignoresSafeArea()

                ShellContentView(
                    viewModel: viewModel,
                    coordinator: coordinator,
                    newsRouter: coordinator.newsRouter,
                    currentUser: currentUser,
                    profileTabViewModel: profileTabViewModel,
                    onLogout: onLogout
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .disabled(viewModel.isMenuOpen)
                    .blur(radius: viewModel.isMenuOpen ? 1.5 : 0)
                    .animation(Self.menuAnimation, value: viewModel.isMenuOpen)

                if viewModel.isMenuOpen || menuDragOffset > 0 {
                    ShellMenuDismissOverlay(
                        visibility: menuMetrics.visibility,
                        onDismiss: viewModel.closeMenu
                    )
                    .animation(Self.menuAnimation, value: viewModel.isMenuOpen)

                    SideMenuView(
                        channelsStore: viewModel.channelsStore,
                        accountSummary: currentUser.map(AccountProfileSummary.init(user:)),
                        selectedTab: coordinator.selectedTab,
                        footerText: viewModel.sideMenuFooterText,
                        onSelect: selectTab
                    )
                    .frame(width: menuMetrics.width, alignment: .topLeading)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: menuMetrics.offset)
                    .animation(Self.menuAnimation, value: viewModel.isMenuOpen)
                }

                ShellMenuEdgeGestureZone(
                    openGesture: openMenuGesture(menuWidth: menuMetrics.width)
                )
            }
            .gesture(closeMenuGesture(menuWidth: menuMetrics.width))
        }
    }

    /// Computes the current menu layout derived from width and gesture state.
    private func menuMetrics(for availableWidth: CGFloat) -> ShellMenuMetrics {
        let menuWidth = min(availableWidth * 0.78, 320)
        return ShellMenuMetrics(
            width: menuWidth,
            offset: currentMenuOffset(menuWidth: menuWidth),
            visibility: currentMenuVisibility(menuWidth: menuWidth)
        )
    }

    /// Returns menu offset.
    private func currentMenuOffset(menuWidth: CGFloat) -> CGFloat {
        if viewModel.isMenuOpen {
            return min(menuDragOffset, 0)
        }

        if menuDragOffset > 0 {
            return -menuWidth + menuDragOffset
        }

        return -menuWidth
    }

    /// Returns menu visibility.
    private func currentMenuVisibility(menuWidth: CGFloat) -> CGFloat {
        let visibleWidth = viewModel.isMenuOpen
            ? menuWidth + min(menuDragOffset, 0)
            : max(menuDragOffset, 0)
        return max(0, min(visibleWidth / menuWidth, 1))
    }

    /// Opens menu gesture.
    private func openMenuGesture(menuWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($menuDragOffset) { value, state, _ in
                guard !viewModel.isMenuOpen, value.startLocation.x < Self.menuEdgeActivationWidth else { return }
                state = max(0, min(value.translation.width, menuWidth))
            }
            .onEnded { value in
                guard !viewModel.isMenuOpen, value.startLocation.x < Self.menuEdgeActivationWidth else { return }
                if value.translation.width > menuWidth * Self.menuDragThresholdRatio {
                    withAnimation {
                        viewModel.toggleMenu()
                    }
                }
            }
    }

    /// Handles close menu gesture.
    private func closeMenuGesture(menuWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($menuDragOffset) { value, state, _ in
                guard viewModel.isMenuOpen else { return }
                state = min(0, max(value.translation.width, -menuWidth))
            }
            .onEnded { value in
                guard viewModel.isMenuOpen else { return }
                if value.translation.width < -(menuWidth * Self.menuDragThresholdRatio) {
                    viewModel.closeMenu()
                }
            }
    }

    /// Selects tab.
    private func selectTab(_ tab: AppTab) {
        coordinator.selectTab(tab)
        viewModel.closeMenu()
    }
}

private struct ShellMenuMetrics {
    let width: CGFloat
    let offset: CGFloat
    let visibility: CGFloat
}

private struct ShellMenuDismissOverlay: View {
    let visibility: CGFloat
    let onDismiss: () -> Void

    var body: some View {
        Button(action: onDismiss) {
            Color.black.opacity(0.22 * visibility)
                .ignoresSafeArea()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppLocalization.text("accessibility.shell.dismissMenu"))
        .accessibilityHint(AppLocalization.text("accessibility.shell.dismissMenuHint"))
        .accessibilityIdentifier("shell.dismissMenu")
    }
}

private struct ShellMenuEdgeGestureZone<OpenGesture: Gesture>: View {
    let openGesture: OpenGesture

    var body: some View {
        Color.clear
            .frame(width: AppShellView.menuDismissOverlayWidth)
            .contentShape(Rectangle())
            .ignoresSafeArea()
            .accessibilityHidden(true)
            .gesture(openGesture)
    }
}

#if DEBUG
#Preview("App Shell") {
    let coordinator = ViewPreviewSupport.makeCoordinator()

    return AppShellView(
        viewModel: ViewPreviewSupport.makeShellViewModel(),
        coordinator: coordinator,
        currentUser: ViewPreviewSupport.sampleUser,
        profileTabViewModel: ViewPreviewSupport.makeProfileTabViewModel(
            currentUser: ViewPreviewSupport.sampleUser
        ),
        onLogout: {}
    )
}
#endif
