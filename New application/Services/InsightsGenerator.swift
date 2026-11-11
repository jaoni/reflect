import Foundation
import FoundationModels
import Observation

@Observable
final class InsightsGenerator {
    // MARK: - Published State

    var moodStats: MoodStatistics?
    var aiReflection: WeeklyReflection?
    var isGenerating: Bool = false
    var aiError: String?

    // MARK: - Cache

    private var cachedPeriod: InsightsPeriod?
    private var cachedEntryIDs: Set<UUID> = []
    private var cachedReflection: WeeklyReflection?

    // MARK: - Availability

    var modelAvailability: SystemLanguageModel.Availability {
        SystemLanguageModel.default.availability
    }

    var isAIAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability {
            return true
        }
        return false
    }

    // MARK: - Mood Statistics (pure computation, no AI)

    func computeMoodStatistics(from entries: [JournalEntry], period: InsightsPeriod) -> MoodStatistics {
        let calendar = Calendar.current
        let now = Date.now

        let filtered: [JournalEntry]
        switch period {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            filtered = entries.filter { $0.createdAt >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            filtered = entries.filter { $0.createdAt >= monthAgo }
        }

        guard !filtered.isEmpty else {
            return MoodStatistics(
                averageMood: .neutral,
                averageNumeric: 3.0,
                distribution: [:],
                mostFrequentMood: .neutral,
                totalEntries: 0,
                periodLabel: period.rawValue
            )
        }

        var distribution: [Mood: Int] = [:]
        for entry in filtered {
            distribution[entry.mood, default: 0] += 1
        }

        let sum = filtered.reduce(0.0) { $0 + Double($1.mood.numericValue) }
        let average = sum / Double(filtered.count)

        let averageMood = Mood.allCases.min(by: {
            abs(Double($0.numericValue) - average) < abs(Double($1.numericValue) - average)
        }) ?? .neutral

        let mostFrequent = distribution.max(by: { $0.value < $1.value })?.key ?? .neutral

        return MoodStatistics(
            averageMood: averageMood,
            averageNumeric: average,
            distribution: distribution,
            mostFrequentMood: mostFrequent,
            totalEntries: filtered.count,
            periodLabel: period.rawValue
        )
    }

    // MARK: - AI Reflection Generation

    func generateReflection(from entries: [JournalEntry], period: InsightsPeriod) async {
        let calendar = Calendar.current
        let now = Date.now

        let filtered: [JournalEntry]
        switch period {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            filtered = entries.filter { $0.createdAt >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            filtered = entries.filter { $0.createdAt >= monthAgo }
        }

        // Check cache validity
        let currentIDs = Set(filtered.map(\.id))
        if cachedPeriod == period,
           cachedEntryIDs == currentIDs,
           let cached = cachedReflection {
            aiReflection = cached
            return
        }

        guard !filtered.isEmpty else {
            aiReflection = nil
            aiError = nil
            return
        }

        isGenerating = true
        aiError = nil

        do {
            let prompt = buildPrompt(from: filtered, period: period)

            let session = LanguageModelSession(
                instructions: """
                    You are a warm, empathetic journaling coach. You speak directly to the \
                    person using "you" and "your". Your tone is encouraging and reflective, \
                    never clinical or judgmental. You notice patterns gently and frame \
                    insights positively. Keep all text concise — this is a mobile app.
                    """
            )

            let response = try await session.respond(
                to: prompt,
                generating: WeeklyReflection.self
            )

            aiReflection = response.content
            cachedReflection = response.content
            cachedPeriod = period
            cachedEntryIDs = currentIDs
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .exceededContextWindowSize:
                aiError = "Too many entries to analyze. Try a shorter period."
            case .guardrailViolation:
                aiError = "Unable to generate insights for this content."
            default:
                aiError = "Unable to generate insights right now."
            }
        } catch {
            aiError = "Something went wrong. Please try again."
        }

        isGenerating = false
    }

    // MARK: - Prewarm

    func prewarmIfAvailable() {
        guard isAIAvailable else { return }
        Task {
            let session = LanguageModelSession(
                instructions: "You are a warm, empathetic journaling coach."
            )
            try? await session.respond(to: "", generating: String.self)
        }
    }

    // MARK: - Private

    private func buildPrompt(from entries: [JournalEntry], period: InsightsPeriod) -> String {
        let condensed = entries
            .sorted { $0.createdAt < $1.createdAt }
            .prefix(15)
            .map { entry -> String in
                let date = entry.createdAt.formatted(
                    .dateTime.weekday(.abbreviated).month(.abbreviated).day()
                )
                let mood = entry.mood.label
                let snippet = String(
                    entry.content.prefix(80)
                        .components(separatedBy: .newlines)
                        .first ?? ""
                )
                return "[\(date)] \(mood): \(snippet)"
            }
            .joined(separator: "\n")

        return """
            Here are my journal entries from \(period.rawValue.lowercased()):

            \(condensed)

            Reflect on these entries and provide insights.
            """
    }
}
