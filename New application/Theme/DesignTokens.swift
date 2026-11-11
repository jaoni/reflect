import SwiftUI

// MARK: - Spacing System (8pt grid)

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Typography Scale

enum Typography {
    /// Hero greeting, large titles
    static let largeTitle: Font = .system(.largeTitle, design: .rounded, weight: .bold)
    /// Section headers, emphasis
    static let headline: Font = .system(.headline, design: .rounded, weight: .semibold)
    /// Standard body text
    static let body: Font = .system(.body, design: .default)
    /// Timestamps, metadata, section labels
    static let caption: Font = .system(.caption, design: .default, weight: .regular)
    /// Mood picker labels
    static let moodLabel: Font = .system(.subheadline, design: .rounded, weight: .medium)
    /// Journal content — serif for a "writing" feel
    static let editor: Font = .system(.body, design: .serif)
    /// Large mood emoji on detail view
    static let moodEmoji: Font = .system(size: 48)
}

// MARK: - Animation

enum AnimationTokens {
    static let quick: Animation = .spring(duration: 0.25, bounce: 0.2)
    static let standard: Animation = .spring(duration: 0.35, bounce: 0.15)
    static let slow: Animation = .spring(duration: 0.5, bounce: 0.1)
}

// MARK: - Corner Radii

enum CornerRadii {
    static let card: CGFloat = 16
    static let button: CGFloat = 12
    static let mood: CGFloat = 20
}
