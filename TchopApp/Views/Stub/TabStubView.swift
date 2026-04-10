import SwiftUI

struct TabStubView: View {
    var tab: AppTab
    let onOpenSample: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 40)

            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 96, height: 96)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)

                Image(systemName: tab.menuIcon)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(Color(red: 0.95, green: 0.50, blue: 0.37))
            }

            VStack(spacing: 10) {
                Text(tab.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(red: 0.24, green: 0.25, blue: 0.36))

                Text(tab.stubDescription)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }

            Button(action: onOpenSample) {
                Text("Open sample screen")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.95, green: 0.50, blue: 0.37))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
        .padding(.bottom, 120)
        .background(Color.clear)
    }
}
