import SwiftUI

struct JournalDetailView: View {
    let entry: JournalEntry
    let onEdit: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Mood display (centered)
                VStack(spacing: Spacing.sm) {
                    Text(entry.mood.emoji)
                        .font(Typography.moodEmoji)

                    Text(entry.mood.label)
                        .font(Typography.moodLabel)
                        .foregroundStyle(entry.mood.color)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.xl)

                // Date
                Text(entry.createdAt.detailDateString)
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextSecondary)
                    .padding(.horizontal, Spacing.md)

                // Tags
                if !entry.tags.isEmpty {
                    TagView(tags: entry.tags)
                        .padding(.horizontal, Spacing.md)
                }

                Divider()
                    .padding(.horizontal, Spacing.md)

                // Entry content
                Text(entry.content)
                    .font(Typography.editor)
                    .lineSpacing(6)
                    .foregroundStyle(Color.reflectTextPrimary)
                    .padding(.horizontal, Spacing.md)
                    .textSelection(.enabled)

                Spacer(minLength: Spacing.xxl)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { onEdit() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        JournalDetailView(
            entry: JournalEntry(
                content: "Had a wonderful morning walk through the park. The leaves are turning golden and the air was crisp.\n\nI stopped by the coffee shop on the corner and had a great conversation with the barista about their new seasonal blend.",
                mood: .happy
            )
        ) { }
    }
}
