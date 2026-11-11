import SwiftUI
import SwiftData
import FoundationModels

struct InsightsView: View {
    @Query(sort: \JournalEntry.createdAt, order: .reverse)
    private var allEntries: [JournalEntry]

    @State private var selectedPeriod: InsightsPeriod = .week
    @State private var generator = InsightsGenerator()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Period selector
                    periodPicker
                        .padding(.top, Spacing.lg)
                        .padding(.bottom, Spacing.md)

                    // AI Unavailable banner
                    if !generator.isAIAvailable {
                        AIUnavailableCard(availability: generator.modelAvailability)
                            .padding(.horizontal, Spacing.md)
                            .padding(.bottom, Spacing.md)
                    }

                    // Mood Overview (always available, no AI)
                    if let stats = generator.moodStats, stats.totalEntries > 0 {
                        moodOverviewSection(stats: stats)
                            .padding(.bottom, Spacing.lg)
                    }

                    // AI Reflection
                    if generator.isAIAvailable {
                        aiReflectionSection
                            .padding(.bottom, Spacing.lg)
                    }

                    // Coaching Prompt
                    if let reflection = generator.aiReflection {
                        coachingPromptSection(prompt: reflection.coachingPrompt)
                            .padding(.bottom, Spacing.lg)
                    }

                    // Empty state when no entries at all
                    if generator.moodStats?.totalEntries == 0 || generator.moodStats == nil {
                        noEntriesHint
                            .padding(.top, Spacing.xxl)
                    }
                }
                .padding(.bottom, Spacing.xxl)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onChange(of: selectedPeriod) { _, newPeriod in
            updateInsights(for: newPeriod)
        }
        .onAppear {
            generator.prewarmIfAvailable()
            updateInsights(for: selectedPeriod)
        }
    }

    private func updateInsights(for period: InsightsPeriod) {
        generator.moodStats = generator.computeMoodStatistics(
            from: allEntries, period: period
        )

        if generator.isAIAvailable {
            Task {
                await generator.generateReflection(
                    from: allEntries, period: period
                )
            }
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(InsightsPeriod.allCases) { period in
                Button {
                    withAnimation(AnimationTokens.standard) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(Typography.moodLabel)
                        .foregroundStyle(
                            selectedPeriod == period
                                ? Color.reflectTextPrimary
                                : Color.reflectTextSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm + 2)
                        .background(
                            Capsule()
                                .fill(
                                    selectedPeriod == period
                                        ? Color.reflectAccent.opacity(0.15)
                                        : Color.clear
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.xs)
        .background(
            Capsule()
                .fill(Color.reflectSurface)
        )
        .padding(.horizontal, Spacing.md)
        .sensoryFeedback(.selection, trigger: selectedPeriod)
    }

    // MARK: - Mood Overview

    private func moodOverviewSection(stats: MoodStatistics) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("Mood Overview")

            // Average + Most Frequent card
            HStack(spacing: Spacing.md) {
                VStack(spacing: Spacing.xs) {
                    Text(stats.averageMood.emoji)
                        .font(Typography.moodEmoji)
                    Text(stats.averageMood.label)
                        .font(Typography.moodLabel)
                        .foregroundStyle(stats.averageMood.color)
                    Text("Average mood")
                        .font(Typography.caption)
                        .foregroundStyle(Color.reflectTextSecondary)
                }
                .frame(maxWidth: .infinity)

                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.reflectDivider)
                    .frame(width: 1, height: 48)

                VStack(spacing: Spacing.xs) {
                    Text(stats.mostFrequentMood.emoji)
                        .font(Typography.moodEmoji)
                    Text(stats.mostFrequentMood.label)
                        .font(Typography.moodLabel)
                        .foregroundStyle(stats.mostFrequentMood.color)
                    Text("Most frequent")
                        .font(Typography.caption)
                        .foregroundStyle(Color.reflectTextSecondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadii.card)
                    .fill(Color.reflectSurface)
            )
            .padding(.horizontal, Spacing.md)

            // Distribution chart
            MoodDistributionChart(distribution: stats.distribution)
                .padding(.top, Spacing.sm)
        }
    }

    // MARK: - AI Reflection

    private var aiReflectionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("AI Reflection")

            if generator.isGenerating {
                InsightsLoadingView()
                    .padding(.horizontal, Spacing.md)
            } else if let error = generator.aiError {
                errorCard(error)
            } else if let reflection = generator.aiReflection {
                reflectionCard(reflection)
            } else if generator.moodStats?.totalEntries == 0 {
                hintCard("Write a few entries this \(selectedPeriod == .week ? "week" : "month") to unlock AI reflections.")
            }
        }
    }

    private func reflectionCard(_ reflection: WeeklyReflection) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Summary
            Text(reflection.summary)
                .font(Typography.body)
                .foregroundStyle(Color.reflectTextPrimary)
                .lineSpacing(4)

            Divider()

            // Themes
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Themes")
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextTertiary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(reflection.themes, id: \.self) { theme in
                            Text(theme)
                                .font(Typography.moodLabel)
                                .foregroundStyle(Color.reflectAccent)
                                .padding(.horizontal, Spacing.sm + 2)
                                .padding(.vertical, Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(Color.reflectAccent.opacity(0.1))
                                )
                        }
                    }
                }
            }

            Divider()

            // Pattern insight
            HStack(alignment: .top, spacing: Spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                    .font(.body)
                Text(reflection.pattern)
                    .font(Typography.body)
                    .foregroundStyle(Color.reflectTextPrimary)
                    .lineSpacing(4)
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadii.card)
                .fill(Color.reflectSurface)
        )
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Coaching Prompt

    private func coachingPromptSection(prompt: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("Your Next Prompt")

            HStack(alignment: .top, spacing: Spacing.md) {
                Image(systemName: "pencil.and.sparkles")
                    .font(.title2)
                    .foregroundStyle(Color.reflectAccent)

                Text(prompt)
                    .font(Typography.editor)
                    .foregroundStyle(Color.reflectTextPrimary)
                    .lineSpacing(4)
                    .italic()
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: CornerRadii.card)
                    .fill(Color.reflectAccent.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadii.card)
                    .strokeBorder(Color.reflectAccent.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, Spacing.md)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Typography.caption)
            .foregroundStyle(Color.reflectTextTertiary)
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.horizontal, Spacing.md)
    }

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(Color.reflectTextTertiary)
            Text(message)
                .font(Typography.body)
                .foregroundStyle(Color.reflectTextSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadii.card)
                .fill(Color.reflectSurface)
        )
        .padding(.horizontal, Spacing.md)
    }

    private func hintCard(_ message: String) -> some View {
        Text(message)
            .font(Typography.body)
            .foregroundStyle(Color.reflectTextSecondary)
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: CornerRadii.card)
                    .fill(Color.reflectSurface)
            )
            .padding(.horizontal, Spacing.md)
    }

    private var noEntriesHint: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(Color.reflectTextTertiary)
                .symbolEffect(.breathe)

            VStack(spacing: Spacing.sm) {
                Text("No entries yet")
                    .font(Typography.headline)
                    .foregroundStyle(Color.reflectTextPrimary)

                Text("Start journaling to see your mood insights here")
                    .font(Typography.body)
                    .foregroundStyle(Color.reflectTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xxl)
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
