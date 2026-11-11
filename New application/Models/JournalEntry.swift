import Foundation
import SwiftData

@Model
final class JournalEntry {
    // CloudKit requires default values for all stored properties
    var id: UUID = UUID()
    var content: String = ""
    var moodRawValue: String = "neutral"
    var tags: [String] = []
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    /// Type-safe mood access (not persisted — derived from moodRawValue)
    @Transient
    var mood: Mood {
        get { Mood(rawValue: moodRawValue) ?? .neutral }
        set { moodRawValue = newValue.rawValue }
    }

    /// First line of content, truncated for card preview
    @Transient
    var previewText: String {
        let firstLine = content.components(separatedBy: .newlines).first ?? content
        return String(firstLine.prefix(120))
    }

    init(
        content: String = "",
        mood: Mood = .neutral,
        tags: [String] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = UUID()
        self.content = content
        self.moodRawValue = mood.rawValue
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
