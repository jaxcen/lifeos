import SwiftUI

/// 纸质背景 - 全局纸纹底色
struct PaperBackground: View {
    var color: Color = .lifeBackground

    var body: some View {
        ZStack {
            color

            // 对角渐变 - 模拟纸张自然色差
            LinearGradient(
                colors: [
                    color,
                    Color.paperGrain.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 纸纹 grain
            Canvas { context, size in
                let count = 120
                for _ in 0..<count {
                    let x = CGFloat.random(in: 0..<size.width)
                    let y = CGFloat.random(in: 0..<size.height)
                    let w = CGFloat.random(in: 0.5...2)
                    let h = CGFloat.random(in: 0.5...1.5)
                    let rect = CGRect(x: x, y: y, width: w, height: h)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(Color.paperGrain.opacity(Double.random(in: 0.02...0.05)))
                    )
                }
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    PaperBackground()
}
