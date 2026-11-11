import SwiftUI

struct JournalEntryCard: View {
    let entry: JournalEntry

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Mood accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(entry.mood.color)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Top row: emoji + preview
                HStack(alignment: .top, spacing: Spacing.sm) {
                    Text(entry.mood.emoji)
                        .font(.title3)

                    Text(entry.previewText)
                        .font(Typography.body)
                        .foregroundStyle(Color.reflectTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                // Tags
                if !entry.tags.isEmpty {
                    TagView(tags: entry.tags)
                }

                // Timestamp
                Text(entry.createdAt.timeString)
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextTertiary)
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .contentShape(Rectangle())
    }
}

#Preview {
    JournalEntryCard(
        entry: JournalEntry(
            content: "Had a wonderful morning walk through the park. The leaves are turning golden and the air was crisp.",
            mood: .happy
        )
    )
}
