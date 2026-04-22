import SwiftUI

/// Layout wrapper combining top chrome, tab content, and overlays.
struct ShellContentView: View {
    @ObservedObject var viewModel: AppShellViewModel
    @ObservedObject var coordinator: AppCoordinator
    let currentUser: AppUser?
    let onNavigationRestoreChange: (Bool) throws -> Void
    let onLogout: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TopBarView(
                    channelInfo: viewModel.channelInfo,
                    onMenuTap: viewModel.toggleMenu,
                    onChannelTap: {},
                    onSearchTap: {},
                    onNotificationsTap: {}
                )

                TabContentView(
                    selectedTab: coordinator.selectedTab,
                    coordinator: coordinator,
                    newsFeedViewModel: viewModel.newsFeedViewModel,
                    currentUser: currentUser,
                    onNavigationRestoreChange: onNavigationRestoreChange,
                    onLogout: onLogout
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if coordinator.selectedTab == .news && viewModel.showsFloatingActionButton {
                FloatingActionButton()
                    .padding(.leading, 290)
                    .padding(.bottom, 66)
            }

            BottomTabBar(selectedTab: coordinator.selectedTab, onSelect: coordinator.selectTab)
        }
        .accessibilityIdentifier("shell.content")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}
