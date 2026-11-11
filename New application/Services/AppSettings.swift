import SwiftUI

@Observable
final class AppSettings {
    // MARK: - Onboarding

    @ObservationIgnored
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    // MARK: - Daily Reminder

    @ObservationIgnored
    @AppStorage("dailyReminderEnabled") var dailyReminderEnabled: Bool = false

    @ObservationIgnored
    @AppStorage("reminderHour") var reminderHour: Int = 20

    @ObservationIgnored
    @AppStorage("reminderMinute") var reminderMinute: Int = 0

    var reminderTime: Date {
        get {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? .now
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 20
            reminderMinute = components.minute ?? 0
        }
    }

    // MARK: - Journaling Preferences

    @ObservationIgnored
    @AppStorage("defaultMoodRawValue") var defaultMoodRawValue: String = Mood.neutral.rawValue

    var defaultMood: Mood {
        get { Mood(rawValue: defaultMoodRawValue) ?? .neutral }
        set { defaultMoodRawValue = newValue.rawValue }
    }
}
