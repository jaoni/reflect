import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 64))
                .foregroundStyle(Color.reflectTextTertiary)
                .symbolEffect(.breathe)

            VStack(spacing: Spacing.sm) {
                Text("Your story begins here")
                    .font(Typography.headline)
                    .foregroundStyle(Color.reflectTextPrimary)

                Text("Tap + to write your first entry")
                    .font(Typography.body)
                    .foregroundStyle(Color.reflectTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xxl)
    }
}

#Preview {
    EmptyStateView()
}
