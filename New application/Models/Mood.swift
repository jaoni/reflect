import SwiftUI

enum Mood: String, Codable, CaseIterable, Identifiable {
    case joyful
    case happy
    case neutral
    case sad
    case awful

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .joyful:  return "😊"
        case .happy:   return "🙂"
        case .neutral: return "😐"
        case .sad:     return "😔"
        case .awful:   return "😢"
        }
    }

    var label: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .joyful:  return .moodJoyful
        case .happy:   return .moodHappy
        case .neutral: return .moodNeutral
        case .sad:     return .moodSad
        case .awful:   return .moodAwful
        }
    }

    /// Numeric representation for charting (1–5 scale)
    var numericValue: Int {
        switch self {
        case .awful:   return 1
        case .sad:     return 2
        case .neutral: return 3
        case .happy:   return 4
        case .joyful:  return 5
        }
    }
}
