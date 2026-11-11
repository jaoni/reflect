import SwiftUI

struct TagInputField: View {
    @Binding var tags: [String]
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    private let maxTags = 10
    private let maxLength = 30

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Existing tags
            if !tags.isEmpty {
                WrappingHStack(tags: tags) { tag in
                    HStack(spacing: Spacing.xs) {
                        Text(tag)
                            .font(Typography.caption)
                            .foregroundStyle(Color.reflectAccent)

                        Button {
                            withAnimation(AnimationTokens.standard) {
                                tags.removeAll { $0 == tag }
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.reflectAccent.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, Spacing.sm + 2)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        Capsule()
                            .fill(Color.reflectAccent.opacity(0.1))
                    )
                }
            }

            // Input row
            if tags.count < maxTags {
                HStack(spacing: Spacing.sm) {
                    TextField("Add tag...", text: $inputText)
                        .font(Typography.body)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isInputFocused)
                        .onSubmit { addTag() }

                    Button {
                        addTag()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.reflectAccent)
                    }
                    .buttonStyle(.plain)
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1.0)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }

    private func addTag() {
        let trimmed = inputText
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .prefix(maxLength)

        let tag = String(trimmed)

        guard !tag.isEmpty, !tags.contains(tag), tags.count < maxTags else {
            inputText = ""
            return
        }

        withAnimation(AnimationTokens.standard) {
            tags.append(tag)
        }
        inputText = ""
    }
}

// MARK: - Wrapping Layout

struct WrappingHStack<Content: View>: View {
    let tags: [String]
    let content: (String) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
        .frame(height: totalHeight)
        .padding(.horizontal, Spacing.md)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                content(tag)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height + Spacing.xs
                        }
                        let result = width
                        if tag == tags.last {
                            width = 0
                        } else {
                            width -= dimension.width + Spacing.xs
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if tag == tags.last {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: HeightPreferenceKey.self,
                    value: geo.size.height
                )
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { newHeight in
            totalHeight = newHeight
        }
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    @Previewable @State var tags = ["gratitude", "morning", "work"]
    VStack {
        TagInputField(tags: $tags)
        Spacer()
    }
    .padding(.top)
}
