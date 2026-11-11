import SwiftUI

struct InsightsLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            shimmerBlock(height: 60)

            HStack(spacing: Spacing.sm) {
                ForEach(0..<4, id: \.self) { _ in
                    shimmerBlock(height: 28)
                }
            }

            shimmerBlock(height: 40)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadii.card)
                .fill(Color.reflectSurface)
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }

    private func shimmerBlock(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.reflectTextTertiary.opacity(isAnimating ? 0.12 : 0.06))
            .frame(maxWidth: .infinity)
            .frame(height: height)
    }
}

#Preview {
    InsightsLoadingView()
        .padding()
}
