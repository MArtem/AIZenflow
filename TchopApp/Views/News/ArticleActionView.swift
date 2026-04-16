import SwiftUI

struct ArticleActionView: View {
    let action: ArticleActionItem

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: action.systemName)
                .font(.system(size: 14, weight: .semibold))
            Text(action.title)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(AppTheme.textTertiary)
    }
}
