import SwiftUI
import Charts

struct MoodDistributionChart: View {
    let distribution: [Mood: Int]

    private var dataPoints: [(mood: Mood, count: Int)] {
        Mood.allCases.compactMap { mood in
            guard let count = distribution[mood], count > 0 else { return nil }
            return (mood: mood, count: count)
        }
    }

    var body: some View {
        if !dataPoints.isEmpty {
            Chart(dataPoints, id: \.mood) { point in
                BarMark(
                    x: .value("Count", point.count),
                    y: .value("Mood", point.mood.emoji)
                )
                .foregroundStyle(point.mood.color)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(Typography.caption)
                        .foregroundStyle(Color.reflectTextTertiary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.system(size: 20))
                }
            }
            .frame(height: CGFloat(dataPoints.count) * 36)
            .padding(.horizontal, Spacing.md)
        }
    }
}

#Preview {
    MoodDistributionChart(distribution: [
        .joyful: 3,
        .happy: 5,
        .neutral: 2,
        .sad: 1
    ])
    .padding()
}
