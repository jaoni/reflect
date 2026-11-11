import SwiftUI
import Charts

struct MoodTrendChart: View {
    let entries: [JournalEntry]

    private var dataPoints: [(date: Date, value: Int)] {
        entries
            .sorted { $0.createdAt < $1.createdAt }
            .map { (date: $0.createdAt, value: $0.mood.numericValue) }
    }

    var body: some View {
        if dataPoints.count >= 2 {
            Chart(dataPoints, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Mood", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.reflectAccent.opacity(0.8))

                AreaMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Mood", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.reflectAccent.opacity(0.2), Color.reflectAccent.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .chartYScale(domain: 1...5)
            .chartYAxis {
                AxisMarks(values: [1, 3, 5]) { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text(moodLabel(for: intValue))
                                .font(Typography.caption)
                                .foregroundStyle(Color.reflectTextTertiary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.reflectDivider.opacity(0.5))
                    AxisValueLabel(format: .dateTime.day())
                        .font(Typography.caption)
                        .foregroundStyle(Color.reflectTextTertiary)
                }
            }
            .frame(height: 120)
            .padding(.horizontal, Spacing.md)
        }
    }

    private func moodLabel(for value: Int) -> String {
        switch value {
        case 1:  return "😢"
        case 3:  return "😐"
        case 5:  return "😊"
        default: return ""
        }
    }
}

#Preview {
    MoodTrendChart(entries: [
        JournalEntry(content: "Day 1", mood: .neutral, createdAt: Calendar.current.date(byAdding: .day, value: -6, to: .now)!),
        JournalEntry(content: "Day 2", mood: .happy, createdAt: Calendar.current.date(byAdding: .day, value: -4, to: .now)!),
        JournalEntry(content: "Day 3", mood: .joyful, createdAt: Calendar.current.date(byAdding: .day, value: -2, to: .now)!),
        JournalEntry(content: "Day 4", mood: .sad, createdAt: Calendar.current.date(byAdding: .day, value: -1, to: .now)!)
    ])
    .padding()
}
