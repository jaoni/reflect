import SwiftUI
import SwiftData

struct JournalEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let entry: JournalEntry?

    @State private var content: String
    @State private var selectedMood: Mood
    @State private var tags: [String]
    @FocusState private var isEditorFocused: Bool

    init(entry: JournalEntry?) {
        self.entry = entry
        _content = State(initialValue: entry?.content ?? "")
        _selectedMood = State(initialValue: entry?.mood ?? .neutral)
        _tags = State(initialValue: entry?.tags ?? [])
    }

    private var isNewEntry: Bool { entry == nil }
    private var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Date display
                Text(Date.now.fullDateString)
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextSecondary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                // Mood picker
                MoodPicker(selectedMood: $selectedMood)
                    .padding(.vertical, Spacing.md)

                // Tags
                TagInputField(tags: $tags)
                    .padding(.bottom, Spacing.sm)

                Divider()
                    .padding(.horizontal, Spacing.md)

                // Text editor with placeholder
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .font(Typography.editor)
                        .lineSpacing(6)
                        .textEditorStyle(.plain)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.top, Spacing.sm)
                        .focused($isEditorFocused)

                    if content.isEmpty {
                        Text("What's on your mind?")
                            .font(Typography.editor)
                            .foregroundStyle(Color.reflectTextTertiary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.md)
                            .allowsHitTesting(false)
                    }
                }
            }
            .navigationTitle(isNewEntry ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isEditorFocused = true
                }
            }
        }
    }

    private func save() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if let entry {
            entry.content = trimmedContent
            entry.mood = selectedMood
            entry.tags = tags
            entry.updatedAt = .now
        } else {
            let newEntry = JournalEntry(content: trimmedContent, mood: selectedMood)
            newEntry.tags = tags
            modelContext.insert(newEntry)
        }
        dismiss()
    }
}

#Preview {
    JournalEditorView(entry: nil)
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
