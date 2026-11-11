import Foundation
import FoundationModels

// MARK: - AI-Generated Types

@Generable(description: "A reflective weekly journal summary with insights")
struct WeeklyReflection {
    @Guide(description: "A warm, reflective 2-3 sentence summary of the person's week. Speak directly to them using 'you'.")
    var summary: String

    @Guide(description: "The top 3-5 themes or topics mentioned across the entries, as short noun phrases", .count(3...5))
    var themes: [String]

    @Guide(description: "One specific behavioral pattern or insight noticed, starting with 'You'.")
    var pattern: String

    @Guide(description: "A warm, personalized journaling prompt question for the next entry, ending with '?'.")
    var coachingPrompt: String
}

// MARK: - Computed Mood Statistics (no AI required)

struct MoodStatistics {
    let averageMood: Mood
    let averageNumeric: Double
    let distribution: [Mood: Int]
    let mostFrequentMood: Mood
    let totalEntries: Int
    let periodLabel: String
}

enum InsightsPeriod: String, CaseIterable, Identifiable {
    case week = "This Week"
    case month = "This Month"

    var id: String { rawValue }
}
