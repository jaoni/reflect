import SwiftUI

struct FloatingComposeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.reflectAccent)
                        .shadow(color: Color.reflectAccent.opacity(0.3), radius: 8, y: 4)
                )
        }
        .padding(Spacing.lg)
    }
}

#Preview {
    FloatingComposeButton { }
}
