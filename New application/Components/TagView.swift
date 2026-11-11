import SwiftUI

struct TagView: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(Typography.caption)
                        .foregroundStyle(Color.reflectAccent)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.reflectAccent.opacity(0.1))
                        )
                }
            }
        }
    }
}

#Preview {
    TagView(tags: ["gratitude", "morning", "work", "health"])
        .padding()
}
