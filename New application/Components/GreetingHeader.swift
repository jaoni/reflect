import SwiftUI

struct GreetingHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(greeting)
                .font(Typography.caption)
                .foregroundStyle(Color.reflectTextSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text(Date.now.fullDateString)
                .font(Typography.largeTitle)
                .foregroundStyle(Color.reflectTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 0..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }
}

#Preview {
    GreetingHeader()
}
