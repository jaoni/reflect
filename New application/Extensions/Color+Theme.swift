import SwiftUI

extension Color {
    // MARK: - Base Palette
    static let reflectBackground = Color(.systemBackground)
    static let reflectSurface = Color(.secondarySystemBackground)
    static let reflectTextPrimary = Color(.label)
    static let reflectTextSecondary = Color(.secondaryLabel)
    static let reflectTextTertiary = Color(.tertiaryLabel)

    // MARK: - Accent
    static let reflectAccent = Color.indigo

    // MARK: - Mood Colors (deliberately muted and desaturated)
    static let moodJoyful = Color(red: 1.0, green: 0.78, blue: 0.24)     // Warm gold
    static let moodHappy = Color(red: 0.55, green: 0.82, blue: 0.53)     // Soft sage green
    static let moodNeutral = Color(red: 0.60, green: 0.65, blue: 0.72)   // Calm slate
    static let moodSad = Color(red: 0.55, green: 0.62, blue: 0.85)       // Muted periwinkle
    static let moodAwful = Color(red: 0.78, green: 0.52, blue: 0.55)     // Dusty rose

    // MARK: - UI
    static let reflectDivider = Color(.separator)
}
