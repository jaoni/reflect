import Foundation

struct StreakInfo {
    let current: Int
    let longest: Int
}

enum StreakCalculator {
    /// Calculate current and longest journaling streaks.
    /// Expects entries sorted by createdAt descending (newest first),
    /// matching the @Query sort order used in the app.
    static func calculate(from entries: [JournalEntry]) -> StreakInfo {
        guard !entries.isEmpty else {
            return StreakInfo(current: 0, longest: 0)
        }

        let calendar = Calendar.current

        // Build a Set of unique days for O(1) lookup
        let entryDays: Set<Date> = Set(
            entries.map { calendar.startOfDay(for: $0.createdAt) }
        )

        // Sort unique days descending (newest first)
        let sortedDays = entryDays.sorted(by: >)

        // Current streak: walk backwards from today
        var currentStreak = 0
        var checkDate = calendar.startOfDay(for: Date.now)

        // If no entry today, allow streak to start from yesterday
        if !entryDays.contains(checkDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return StreakInfo(current: 0, longest: longestStreak(sortedDays: sortedDays, calendar: calendar))
            }
            checkDate = yesterday
        }

        while entryDays.contains(checkDate) {
            currentStreak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        let longest = longestStreak(sortedDays: sortedDays, calendar: calendar)

        return StreakInfo(current: currentStreak, longest: max(longest, currentStreak))
    }

    private static func longestStreak(sortedDays: [Date], calendar: Calendar) -> Int {
        guard !sortedDays.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for i in 1..<sortedDays.count {
            let daysBetween = calendar.dateComponents([.day], from: sortedDays[i], to: sortedDays[i - 1]).day ?? 0
            if daysBetween == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }

        return longest
    }
}
