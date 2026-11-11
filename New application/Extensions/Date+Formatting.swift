import Foundation

extension Date {
    /// "Today", "Yesterday", "Monday", or "Nov 4, 2026"
    var relativeDayString: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        if Calendar.current.isDateInYesterday(self) { return "Yesterday" }
        let daysAgo = Calendar.current.dateComponents([.day], from: self, to: .now).day ?? 0
        if daysAgo < 7 {
            return self.formatted(.dateTime.weekday(.wide))
        }
        return self.formatted(.dateTime.month(.abbreviated).day().year())
    }

    /// "2:45 PM"
    var timeString: String {
        self.formatted(date: .omitted, time: .shortened)
    }

    /// "Wednesday, November 4"
    var fullDateString: String {
        self.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    /// "November 4, 2026"
    var detailDateString: String {
        self.formatted(.dateTime.month(.wide).day().year())
    }

    /// Section grouping key for the journal list
    var sectionKey: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        if Calendar.current.isDateInYesterday(self) { return "Yesterday" }
        let daysAgo = Calendar.current.dateComponents([.day], from: self, to: .now).day ?? 0
        if daysAgo < 7 { return "This Week" }
        return "Earlier"
    }

    /// Sort priority for sections (lower = displayed first)
    var sectionSortOrder: Int {
        switch sectionKey {
        case "Today": return 0
        case "Yesterday": return 1
        case "This Week": return 2
        default: return 3
        }
    }
}
