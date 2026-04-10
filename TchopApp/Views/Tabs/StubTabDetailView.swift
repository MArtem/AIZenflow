import SwiftUI

struct StubTabDetailView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color(red: 0.24, green: 0.25, blue: 0.36))

            Text(description)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(red: 0.35, green: 0.36, blue: 0.44))
                .lineSpacing(3)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(20)
        .background(Color(red: 0.97, green: 0.96, blue: 0.94))
        .navigationBarTitleDisplayMode(.inline)
    }
}
