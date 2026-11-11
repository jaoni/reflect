import SwiftUI
import FoundationModels

struct AIUnavailableCard: View {
    let availability: SystemLanguageModel.Availability

    private var info: (title: String, subtitle: String, icon: String) {
        switch availability {
        case .available:
            return ("", "", "")
        case .unavailable(.deviceNotEligible):
            return (
                "AI Insights Unavailable",
                "This device doesn't support Apple Intelligence. Mood statistics are still available below.",
                "iphone.slash"
            )
        case .unavailable(.appleIntelligenceNotEnabled):
            return (
                "Enable Apple Intelligence",
                "Turn on Apple Intelligence in Settings to unlock AI-powered reflections and insights.",
                "sparkles"
            )
        case .unavailable(.modelNotReady):
            return (
                "AI Model Downloading",
                "Apple Intelligence is setting up. AI insights will be available once the download completes.",
                "arrow.down.circle"
            )
        default:
            return (
                "AI Insights Unavailable",
                "AI-powered insights aren't available right now. Mood statistics are still shown below.",
                "sparkles"
            )
        }
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: info.icon)
                .font(.title2)
                .foregroundStyle(Color.reflectAccent.opacity(0.6))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(info.title)
                    .font(Typography.headline)
                    .foregroundStyle(Color.reflectTextPrimary)

                Text(info.subtitle)
                    .font(Typography.caption)
                    .foregroundStyle(Color.reflectTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadii.card)
                .fill(Color.reflectSurface)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        AIUnavailableCard(availability: .unavailable(.deviceNotEligible))
        AIUnavailableCard(availability: .unavailable(.appleIntelligenceNotEnabled))
        AIUnavailableCard(availability: .unavailable(.modelNotReady))
    }
    .padding()
}
