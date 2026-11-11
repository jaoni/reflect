import SwiftUI

struct CalendarDayCell: View {
    let dayNumber: Int
    let isToday: Bool
    let mood: Mood?
    let isCurrentMonth: Bool

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text("\(dayNumber)")
                .font(Typography.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(textColor)

            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
                .opacity(mood != nil ? 1 : 0)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(
            Circle()
                .fill(isToday ? Color.reflectAccent.opacity(0.12) : Color.clear)
                .frame(width: 36, height: 36)
        )
        .opacity(isCurrentMonth ? 1 : 0)
    }

    private var textColor: Color {
        if isToday { return Color.reflectAccent }
        if mood != nil { return Color.reflectTextPrimary }
        return Color.reflectTextTertiary
    }

    private var dotColor: Color {
        mood?.color ?? Color.clear
    }
}

#Preview {
    HStack {
        CalendarDayCell(dayNumber: 4, isToday: true, mood: .happy, isCurrentMonth: true)
        CalendarDayCell(dayNumber: 5, isToday: false, mood: .sad, isCurrentMonth: true)
        CalendarDayCell(dayNumber: 6, isToday: false, mood: nil, isCurrentMonth: true)
        CalendarDayCell(dayNumber: 7, isToday: false, mood: nil, isCurrentMonth: false)
    }
    .padding()
}
