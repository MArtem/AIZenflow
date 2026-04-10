import SwiftUI

struct FloatingActionButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color(red: 0.95, green: 0.50, blue: 0.37))
                .clipShape(Circle())
                .shadow(color: Color(red: 0.95, green: 0.50, blue: 0.37).opacity(0.35), radius: 10, y: 6)
        }
        .buttonStyle(.plain)
    }
}
