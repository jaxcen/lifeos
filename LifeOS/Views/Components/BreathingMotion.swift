import SwiftUI

// MARK: - 呼吸动效

/// 呼吸修饰符 - 缓慢的缩放呼吸
struct BreathingModifier: ViewModifier {
    var minScale: CGFloat = 0.985
    var maxScale: CGFloat = 1.02
    var duration: Double = 4.2
    var anchor: UnitPoint = .center

    @State private var inhale = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(inhale ? maxScale : minScale, anchor: anchor)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    inhale = true
                }
            }
    }
}

/// 漂浮修饰符 - 缓慢的上下漂移
struct FloatingModifier: ViewModifier {
    var amplitude: CGFloat = 4
    var duration: Double = 4.6
    var delay: Double = 0

    @State private var lifted = false

    func body(content: Content) -> some View {
        content
            .offset(y: lifted ? -amplitude : amplitude)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    lifted = true
                }
            }
    }
}

extension View {
    /// 呼吸感 - 像缓慢的吸气与呼气
    func breathing(
        minScale: CGFloat = 0.985,
        maxScale: CGFloat = 1.02,
        duration: Double = 4.2,
        anchor: UnitPoint = .center
    ) -> some View {
        modifier(BreathingModifier(minScale: minScale, maxScale: maxScale, duration: duration, anchor: anchor))
    }

    /// 漂浮感 - 缓慢的上下漂移
    func floating(amplitude: CGFloat = 4, duration: Double = 4.6, delay: Double = 0) -> some View {
        modifier(FloatingModifier(amplitude: amplitude, duration: duration, delay: delay))
    }
}

// MARK: - 暖呼吸背景

/// 全局背景 - 暖奶油底色 + 缓慢漂移的柔光团
struct WarmBreathingBackground: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                LinearGradient(
                    colors: [
                        Color.lifeMistBackground,
                        Color.lifeLavenderMist,
                        Color(hex: "FFFDF9")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Circle()
                    .fill(Color.lifeSoftPeach.opacity(0.55))
                    .frame(width: 320, height: 320)
                    .blur(radius: 58)
                    .offset(
                        x: 140 + 20 * sin(t / 9),
                        y: -220 + 16 * cos(t / 11)
                    )

                Circle()
                    .fill(Color.lifeSoftLavender.opacity(0.38))
                    .frame(width: 270, height: 270)
                    .blur(radius: 66)
                    .offset(
                        x: -150 + 18 * cos(t / 10),
                        y: 190 + 20 * sin(t / 13)
                    )

                Circle()
                    .fill(Color.lifeSunriseSoft.opacity(0.6))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(
                        x: 36 * sin(t / 14),
                        y: 430 + 12 * cos(t / 12)
                    )
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - 日出穹顶

/// 日出穹顶 - 吉祥物身后呼吸的暖色半圆
struct SunriseDome: View {
    var width: CGFloat = 300

    var body: some View {
        Circle()
            .trim(from: 0.5, to: 1.0)
            .fill(
                LinearGradient(
                    colors: [
                        Color.lifeSunrise.opacity(0.78),
                        Color.lifeSunriseSoft.opacity(0.28)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width, height: width)
            .frame(height: width / 2, alignment: .top)
            .breathing(minScale: 0.97, maxScale: 1.03, duration: 5.2, anchor: .bottom)
    }
}

#Preview {
    ZStack {
        WarmBreathingBackground()

        VStack {
            SunriseDome(width: 280)
            Spacer()
        }
        .padding(.top, 160)
    }
}
