import SwiftUI

/// Root authenticated shell with side menu and tab content container.
struct AppShellView: View {
    @ObservedObject var viewModel: AppShellViewModel
    @ObservedObject var coordinator: AppCoordinator
    let currentUser: AppUser?
    let onNavigationRestoreChange: (Bool) throws -> Void
    let onLogout: () -> Void
    @GestureState private var menuDragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let menuWidth = min(proxy.size.width * 0.78, 320)
            let menuOffset = currentMenuOffset(menuWidth: menuWidth)
            let menuVisibility = currentMenuVisibility(menuWidth: menuWidth)

            ZStack(alignment: .leading) {
                AppTheme.canvasBackground
                    .ignoresSafeArea()

                ShellContentView(
                    viewModel: viewModel,
                    coordinator: coordinator,
                    currentUser: currentUser,
                    onNavigationRestoreChange: onNavigationRestoreChange,
                    onLogout: onLogout
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .disabled(viewModel.isMenuOpen)
                    .blur(radius: viewModel.isMenuOpen ? 1.5 : 0)
                    .animation(.spring(response: 0.28, dampingFraction: 0.88), value: viewModel.isMenuOpen)

                if viewModel.isMenuOpen || menuDragOffset > 0 {
                    Button(action: viewModel.closeMenu) {
                        Color.black.opacity(0.22 * menuVisibility)
                            .ignoresSafeArea()
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.28, dampingFraction: 0.88), value: viewModel.isMenuOpen)

                    SideMenuView(
                        channelInfo: viewModel.channelInfo,
                        selectedTab: coordinator.selectedTab,
                        footerText: viewModel.sideMenuFooterText,
                        onSelect: selectTab
                    )
                    .frame(width: menuWidth, alignment: .topLeading)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: menuOffset)
                    .animation(.spring(response: 0.28, dampingFraction: 0.88), value: viewModel.isMenuOpen)
                }

                Color.clear
                    .frame(width: 24)
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .gesture(openMenuGesture(menuWidth: menuWidth))
            }
            .gesture(closeMenuGesture(menuWidth: menuWidth))
        }
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
                guard !viewModel.isMenuOpen, value.startLocation.x < 28 else { return }
                state = max(0, min(value.translation.width, menuWidth))
            }
            .onEnded { value in
                guard !viewModel.isMenuOpen, value.startLocation.x < 28 else { return }
                if value.translation.width > menuWidth * 0.22 {
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
                if value.translation.width < -(menuWidth * 0.22) {
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
