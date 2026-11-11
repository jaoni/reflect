import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var settings = AppSettings()
    @State private var notificationDenied = false

    @Query(sort: \JournalEntry.createdAt, order: .reverse)
    private var entries: [JournalEntry]

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Reminders
                Section {
                    Toggle("Daily Reminder", isOn: $settings.dailyReminderEnabled)
                        .onChange(of: settings.dailyReminderEnabled) { _, enabled in
                            handleReminderToggle(enabled)
                        }

                    if settings.dailyReminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $settings.reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: settings.reminderTime) { _, _ in
                            NotificationManager.scheduleDailyReminder(
                                hour: settings.reminderHour,
                                minute: settings.reminderMinute
                            )
                        }
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    if notificationDenied {
                        Text("Notifications are disabled. Enable them in Settings > Notifications.")
                            .foregroundStyle(.red)
                    }
                }

                // MARK: - Journaling
                Section("Journaling") {
                    HStack {
                        Text("Default Mood")
                        Spacer()
                        HStack(spacing: Spacing.sm) {
                            ForEach(Mood.allCases) { mood in
                                Button {
                                    settings.defaultMood = mood
                                } label: {
                                    Text(mood.emoji)
                                        .font(.title3)
                                        .padding(4)
                                        .background(
                                            Circle()
                                                .fill(
                                                    settings.defaultMood == mood
                                                        ? mood.color.opacity(0.2)
                                                        : Color.clear
                                                )
                                        )
                                        .overlay(
                                            Circle()
                                                .strokeBorder(
                                                    settings.defaultMood == mood
                                                        ? mood.color
                                                        : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // MARK: - Data
                Section("Data") {
                    if let jsonData = exportJSON() {
                        ShareLink(
                            item: jsonData,
                            preview: SharePreview(
                                "Reflect Journal Export",
                                image: Image(systemName: "doc.text")
                            )
                        ) {
                            Label("Export Journal (\(entries.count) entries)", systemImage: "square.and.arrow.up")
                        }
                    }
                }

                // MARK: - About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(Color.reflectTextSecondary)
                    }


                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func handleReminderToggle(_ enabled: Bool) {
        if enabled {
            Task {
                let granted = await NotificationManager.requestPermission()
                if granted {
                    NotificationManager.scheduleDailyReminder(
                        hour: settings.reminderHour,
                        minute: settings.reminderMinute
                    )
                    notificationDenied = false
                } else {
                    settings.dailyReminderEnabled = false
                    notificationDenied = true
                }
            }
        } else {
            NotificationManager.cancelReminder()
        }
    }

    private func exportJSON() -> Data? {
        guard !entries.isEmpty else { return nil }

        struct ExportEntry: Codable {
            let content: String
            let mood: String
            let tags: [String]
            let createdAt: Date
            let updatedAt: Date
        }

        let exportEntries = entries.map {
            ExportEntry(
                content: $0.content,
                mood: $0.mood.rawValue,
                tags: $0.tags,
                createdAt: $0.createdAt,
                updatedAt: $0.updatedAt
            )
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(exportEntries)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
