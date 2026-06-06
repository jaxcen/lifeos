import SwiftUI

/// AI 生成中视图
struct AIGeneratingView: View {
    let message: String

    var body: some View {
        PredictionProgressView(title: message, isComplete: true)
    }
}

struct PredictionProgressView: View {
    let title: String
    var subtitle: String = "正在从今天的记录里校准明天的可能性"
    var isComplete: Bool

    @State private var value = 0
    @State private var glow = false

    init(
        title: String,
        subtitle: String = "正在从今天的记录里校准明天的可能性",
        isComplete: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isComplete = isComplete
    }

    var body: some View {
        ZStack {
            backgroundPulse

            VStack(spacing: 26) {
                Text("\(value)")
                    .font(.system(size: 170, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.58)
                    .lineLimit(1)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.lifeAccent, Color.lifeAccent.opacity(0.82), Color.lifePhotoAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.lifeAccent.opacity(0.2), radius: 22, y: 14)
                    .frame(maxWidth: .infinity)
                    .frame(height: 210)

                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.lifeText)

                    Text(subtitle)
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: isComplete) {
            await runCountUp()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }

    private var backgroundPulse: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.lifeMistBackground,
                    Color.lifeLavenderMist.opacity(0.82),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.lifeSoftLavender.opacity(0.78))
                .frame(width: 300, height: 300)
                .blur(radius: 34)
                .offset(x: glow ? 82 : 24, y: glow ? -180 : -120)

            Circle()
                .fill(Color.lifeSoftSky.opacity(0.68))
                .frame(width: 240, height: 240)
                .blur(radius: 32)
                .offset(x: glow ? -120 : -68, y: glow ? 190 : 136)
        }
        .ignoresSafeArea()
    }

    private func runCountUp() async {
        if value == 100 {
            return
        }

        if value == 0 {
            for nextValue in 1...88 {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(for: .milliseconds(27))
                await MainActor.run {
                    value = nextValue
                }
            }

            for nextValue in 89...93 {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(for: .milliseconds(145))
                await MainActor.run {
                    value = nextValue
                }
            }
        }

        while !Task.isCancelled && !isComplete {
            try? await Task.sleep(for: .milliseconds(80))
        }

        guard !Task.isCancelled, isComplete else { return }
        await MainActor.run {
            withAnimation(.easeOut(duration: 0.18)) {
                value = 100
            }
        }
    }
}

#Preview {
    AIGeneratingView(message: "正在预测它的今天")
}
