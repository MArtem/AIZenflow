import SwiftUI

struct NewsDestinationView: View {
    let route: NewsRoute

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(route.subtitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 0.95, green: 0.50, blue: 0.37))

                Text(route.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(red: 0.24, green: 0.25, blue: 0.36))

                Text(route.bodyText)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color(red: 0.35, green: 0.36, blue: 0.44))
                    .lineSpacing(3)

                if let accentLabel = route.accentLabel {
                    Text(accentLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(red: 0.95, green: 0.50, blue: 0.37))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94))
        .navigationTitle(titleForNavigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var titleForNavigationBar: String {
        route.destinationID == "discussion-details" ? "Discussion" : "Article"
    }
}
