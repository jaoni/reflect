import SwiftUI

struct SplashScreen: View {
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0

    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.reflectBackground
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.reflectAccent)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                VStack(spacing: Spacing.xs) {
                    Text("Reflect")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.reflectTextPrimary)
                        .opacity(titleOpacity)

                    Text("Your mindful journal")
                        .font(Typography.body)
                        .foregroundStyle(Color.reflectTextSecondary)
                        .opacity(subtitleOpacity)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }

            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                titleOpacity = 1.0
            }

            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                subtitleOpacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashScreen { }
}
