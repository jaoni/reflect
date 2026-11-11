import Foundation

extension Date {
    /// First moment of this date's day (midnight)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// First day of this date's month, at midnight
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// Number of days in this date's month
    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 30
    }

    /// Weekday index of the first day of this date's month (0-based, 0 = Sunday)
    var firstWeekdayOfMonth: Int {
        let first = Calendar.current.component(.weekday, from: startOfMonth)
        return first - 1
    }

    /// "November 2026" — for the calendar header
    var monthYearString: String {
        self.formatted(.dateTime.month(.wide).year())
    }

    /// Navigate forward or backward by months
    func advancedByMonths(_ months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    /// Whether this date is in the same calendar day as another date
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// Whether this date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}
