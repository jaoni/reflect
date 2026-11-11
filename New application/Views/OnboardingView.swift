import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Welcome
            welcomePage
                .tag(0)

            // Page 2: Track Your Mood
            moodPage
                .tag(1)

            // Page 3: AI Insights + Get Started
            insightsPage
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Color.reflectBackground)
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "book.closed.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.reflectAccent)
                .symbolEffect(.breathe)

            VStack(spacing: Spacing.md) {
                Text("Welcome to Reflect")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Color.reflectTextPrimary)

                Text("Your personal space for mindful journaling and self-discovery.")
                    .font(Typography.body)
                    .foregroundStyle(Color.reflectTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            Spacer()
            Spacer()
        }
    }

    // MARK: - Page 2: Mood Tracking

    private var moodPage: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            HStack(spacing: Spacing.md) {
                ForEach(Mood.allCases) { mood in
                    VStack(spacing: Spacing.xs) {
                        Text(mood.emoji)
                            .font(.system(size: 40))
                        Text(mood.label)
                            .font(Typography.caption)
                            .foregroundStyle(mood.color)
                    }
                }
            }

            VStack(spacing: Spacing.md) {
                Text("Track Your Mood")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Color.reflectTextPrimary)

                Text("Log how you feel each day and watch patterns emerge over time.")
                    .font(Typography.body)
                    .foregroundStyle(Color.reflectTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            Spacer()
            Spacer()
        }
    }

    // MARK: - Page 3: AI Insights

    private var insightsPage: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundStyle(Color.reflectAccent)
                .symbolEffect(.breathe)

            VStack(spacing: Spacing.md) {
                Text("AI-Powered Insights")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Color.reflectTextPrimary)

                Text("Get personalized reflections and coaching prompts powered by Apple Intelligence — all on-device and private.")
                    .font(Typography.body)
                    .foregroundStyle(Color.reflectTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            Spacer()

            Button {
                withAnimation {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text("Get Started")
                    .font(Typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadii.button)
                            .fill(Color.reflectAccent)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxl)
        }
    }
}

#Preview {
    OnboardingView()
}
