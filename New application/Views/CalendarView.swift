import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \JournalEntry.createdAt, order: .reverse)
    private var allEntries: [JournalEntry]

    @State private var displayedMonth: Date = Date.now.startOfMonth
    @State private var navigationPath = NavigationPath()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    // MARK: - Computed Properties

    private var entriesForMonth: [JournalEntry] {
        let start = displayedMonth.startOfMonth
        guard let end = Calendar.current.date(byAdding: .month, value: 1, to: start) else { return [] }
        return allEntries.filter { $0.createdAt >= start && $0.createdAt < end }
    }

    private var entryByDay: [Int: JournalEntry] {
        var result: [Int: JournalEntry] = [:]
        for entry in entriesForMonth {
            let day = Calendar.current.component(.day, from: entry.createdAt)
            if result[day] == nil {
                result[day] = entry
            }
        }
        return result
    }

    private var streakInfo: StreakInfo {
        StreakCalculator.calculate(from: allEntries)
    }

    private var isCurrentMonth: Bool {
        Calendar.current.isDate(displayedMonth, equalTo: Date.now, toGranularity: .month)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 0) {
                    streakBanner
                        .padding(.top, Spacing.lg)
                        .padding(.bottom, Spacing.md)

                    monthHeader
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.md)

                    weekdayHeader
                        .padding(.horizontal, Spacing.sm)

                    calendarGrid
                        .padding(.horizontal, Spacing.sm)
                        .padding(.bottom, Spacing.lg)

                    if !entriesForMonth.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Mood Trend")
                                .font(Typography.caption)
                                .foregroundStyle(Color.reflectTextTertiary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .padding(.horizontal, Spacing.md)

                            MoodTrendChart(entries: entriesForMonth)
                        }
                        .padding(.bottom, Spacing.lg)
                    }
                }
            }
            .navigationDestination(for: UUID.self) { entryID in
                if let entry = allEntries.first(where: { $0.id == entryID }) {
                    JournalDetailView(entry: entry) { }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        HStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    if streakInfo.current > 0 {
                        Image(systemName: "flame.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                            .symbolEffect(.bounce, value: streakInfo.current)
                    }
                    Text("\(streakInfo.current)")
                        .font(Typography.largeTitle)
                        .foregroundStyle(Color.reflectTextPrimary)
                        .contentTransition(.numericText())
                }
                Text("Current streak")
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextSecondary)
            }
            .frame(maxWidth: .infinity)

            RoundedRectangle(cornerRadius: 1)
                .fill(Color.reflectDivider)
                .frame(width: 1, height: 32)

            VStack(spacing: Spacing.xs) {
                Text("\(streakInfo.longest)")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Color.reflectTextPrimary)
                    .contentTransition(.numericText())
                Text("Longest streak")
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
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(AnimationTokens.standard) {
                    displayedMonth = displayedMonth.advancedByMonths(-1)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.reflectTextSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }

            Spacer()

            Text(displayedMonth.monthYearString)
                .font(Typography.headline)
                .foregroundStyle(Color.reflectTextPrimary)
                .contentTransition(.numericText())

            Spacer()

            Button {
                withAnimation(AnimationTokens.standard) {
                    displayedMonth = displayedMonth.advancedByMonths(1)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.medium))
                    .foregroundStyle(isCurrentMonth ? Color.reflectTextTertiary : Color.reflectTextSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .disabled(isCurrentMonth)
        }
        .sensoryFeedback(.selection, trigger: displayedMonth)
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextTertiary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let daysInMonth = displayedMonth.daysInMonth
        let firstWeekday = displayedMonth.firstWeekdayOfMonth
        let totalCells = firstWeekday + daysInMonth
        let today = Date.now

        return LazyVGrid(columns: columns, spacing: Spacing.xs) {
            ForEach(0..<totalCells, id: \.self) { index in
                if index < firstWeekday {
                    Color.clear
                        .frame(height: 44)
                } else {
                    let dayNumber = index - firstWeekday + 1
                    let dayDate = Calendar.current.date(
                        from: DateComponents(
                            year: Calendar.current.component(.year, from: displayedMonth),
                            month: Calendar.current.component(.month, from: displayedMonth),
                            day: dayNumber
                        )
                    )
                    let entry = entryByDay[dayNumber]
                    let isTodayCell = dayDate?.isSameDay(as: today) ?? false

                    Button {
                        if let entry {
                            navigationPath.append(entry.id)
                        }
                    } label: {
                        CalendarDayCell(
                            dayNumber: dayNumber,
                            isToday: isTodayCell,
                            mood: entry?.mood,
                            isCurrentMonth: true
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
