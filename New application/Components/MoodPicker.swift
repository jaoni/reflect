import SwiftUI

struct MoodPicker: View {
    @Binding var selectedMood: Mood

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        withAnimation(AnimationTokens.standard) {
                            selectedMood = mood
                        }
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Text(mood.emoji)
                            Text(mood.label)
                                .font(Typography.moodLabel)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm + 2)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(
                        selectedMood == mood
                            ? Color.reflectTextPrimary
                            : Color.reflectTextSecondary
                    )
                    .background(
                        Capsule()
                            .fill(
                                selectedMood == mood
                                    ? mood.color.opacity(0.2)
                                    : Color.reflectSurface
                            )
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                selectedMood == mood
                                    ? mood.color.opacity(0.5)
                                    : Color.clear,
                                lineWidth: 1.5
                            )
                    )
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

#Preview {
    @Previewable @State var mood: Mood = .neutral
    MoodPicker(selectedMood: $mood)
}
