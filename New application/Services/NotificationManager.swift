import UserNotifications

enum NotificationManager {
    private static let center = UNUserNotificationCenter.current()
    private static let reminderIdentifier = "daily-journal-reminder"

    static func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleDailyReminder(hour: Int, minute: Int) {
        // Remove any existing reminder first
        cancelReminder()

        let content = UNMutableNotificationContent()
        content.title = "How Are You Feeling?"
        content.body = "Take a moment to reflect on your day."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    static func cancelReminder() {
        center.removePendingNotificationRequests(
            withIdentifiers: [reminderIdentifier]
        )
    }
}
