import SwiftUI

/// AI 生成中视图
struct AIGeneratingView: View {
    let message: String
    @State private var dotCount = 0

    var body: some View {
        VStack(spacing: Layout.spacingL) {
            // 呼吸动画圆点
            Circle()
                .fill(Color.lifeAccent.opacity(0.3))
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .fill(Color.lifeAccent.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .fill(Color.lifeAccent)
                                .frame(width: 16, height: 16)
                        )
                )
                .scaleEffect(breathingScale)
                .animation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                    value: breathingScale
                )

            Text(message + String(repeating: ".", count: dotCount))
                .font(.lifeBody)
                .foregroundStyle(Color.lifeTextSecondary)
                .animation(.default, value: dotCount)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.spacingXXL)
        .lifeCard()
        .onAppear {
            dotCount = 0
            startDotAnimation()
            breathingScale = 1.2
        }
    }

    @State private var breathingScale: CGFloat = 1.0

    private func startDotAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            dotCount = (dotCount + 1) % 4
        }
    }
}

#Preview {
    AIGeneratingView(message: "正在生成今日老黄历")
        .padding()
        .background(Color.lifeBackground)
}
