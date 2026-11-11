import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \JournalEntry.createdAt, order: .reverse)
    private var entries: [JournalEntry]

    @Binding var selectedTab: AppTab

    @State private var navigationPath = NavigationPath()
    @State private var showingEditor = false
    @State private var entryToEdit: JournalEntry?

    private var todayEntries: [JournalEntry] {
        entries.filter { Calendar.current.isDateInToday($0.createdAt) }
    }

    private var thisWeekEntries: [JournalEntry] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
        return entries.filter { $0.createdAt >= weekAgo }
    }

    private var streakInfo: StreakInfo {
        StreakCalculator.calculate(from: entries)
    }

    private var recentEntries: [JournalEntry] {
        Array(entries.prefix(3))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 0) {
                        GreetingHeader()

                        // Today's Mood
                        todayMoodCard
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.md)

                        // Streaks
                        streakCard
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.md)

                        // Quick Stats
                        quickStatsCard
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.md)

                        // Recent Entries
                        if !recentEntries.isEmpty {
                            recentEntriesSection
                                .padding(.top, Spacing.lg)
                        }

                        Spacer(minLength: 100)
                    }
                }

                FloatingComposeButton {
                    entryToEdit = nil
                    showingEditor = true
                }
            }
            .navigationDestination(for: UUID.self) { entryID in
                if let entry = entries.first(where: { $0.id == entryID }) {
                    JournalDetailView(entry: entry) {
                        entryToEdit = entry
                        showingEditor = true
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                JournalEditorView(entry: entryToEdit)
                    .id(entryToEdit?.id)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Today's Mood

    private var todayMoodCard: some View {
        VStack(spacing: Spacing.sm) {
            sectionHeader("Today's Mood")

            if let latestToday = todayEntries.first {
                HStack(spacing: Spacing.md) {
                    Text(latestToday.mood.emoji)
                        .font(.system(size: 44))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(latestToday.mood.label)
                            .font(Typography.headline)
                            .foregroundStyle(latestToday.mood.color)

                        Text(latestToday.createdAt.timeString)
                            .font(Typography.caption)
                            .foregroundStyle(Color.reflectTextSecondary)
                    }

                    Spacer()
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadii.card)
                        .fill(Color.reflectSurface)
                )
            } else {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "face.dashed")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.reflectTextTertiary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("No entry yet")
                            .font(Typography.headline)
                            .foregroundStyle(Color.reflectTextPrimary)

                        Text("How are you feeling today?")
                            .font(Typography.caption)
                            .foregroundStyle(Color.reflectTextSecondary)
                    }

                    Spacer()
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadii.card)
                        .fill(Color.reflectSurface)
                )
            }
        }
    }

    // MARK: - Streaks

    private var streakCard: some View {
        HStack(spacing: 0) {
            VStack(spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(streakInfo.current)")
                        .font(Typography.largeTitle)
                        .foregroundStyle(Color.reflectTextPrimary)
                }
                Text("Current streak")
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextSecondary)
            }
            .frame(maxWidth: .infinity)

            RoundedRectangle(cornerRadius: 1)
                .fill(Color.reflectDivider)
                .frame(width: 1, height: 48)

            VStack(spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("\(streakInfo.longest)")
                        .font(Typography.largeTitle)
                        .foregroundStyle(Color.reflectTextPrimary)
                }
                Text("Longest streak")
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadii.card)
                .fill(Color.reflectSurface)
        )
    }

    // MARK: - Quick Stats

    private var quickStatsCard: some View {
        HStack(spacing: 0) {
            VStack(spacing: Spacing.xs) {
                Text("\(entries.count)")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Color.reflectAccent)
                Text("Total entries")
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextSecondary)
            }
            .frame(maxWidth: .infinity)

            RoundedRectangle(cornerRadius: 1)
                .fill(Color.reflectDivider)
                .frame(width: 1, height: 48)

            VStack(spacing: Spacing.xs) {
                Text("\(thisWeekEntries.count)")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Color.reflectAccent)
                Text("This week")
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadii.card)
                .fill(Color.reflectSurface)
        )
    }

    // MARK: - Recent Entries

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("Recent Entries")
                .padding(.horizontal, Spacing.md)

            VStack(spacing: 0) {
                ForEach(recentEntries) { entry in
                    Button {
                        navigationPath.append(entry.id)
                    } label: {
                        JournalEntryCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }

            // See all button
            Button {
                selectedTab = .journal
            } label: {
                HStack {
                    Spacer()
                    Text("See all entries")
                        .font(Typography.moodLabel)
                        .foregroundStyle(Color.reflectAccent)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundStyle(Color.reflectAccent)
                    Spacer()
                }
                .padding(.vertical, Spacing.sm)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Typography.caption)
            .foregroundStyle(Color.reflectTextTertiary)
            .textCase(.uppercase)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    @Previewable @State var tab: AppTab = .dashboard
    DashboardView(selectedTab: $tab)
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
