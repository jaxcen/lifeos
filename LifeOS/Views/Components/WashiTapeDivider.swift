import SwiftUI

/// 和纸条分隔线 - 装饰性分隔元素
struct WashiTapeDivider: View {
    var color: Color = .washiTan
    var width: CGFloat = 120

    var body: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 2)
                .fill(color.opacity(0.35))
                .frame(width: width, height: Layout.washiStripHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.12), .clear, .white.opacity(0.06)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .rotationEffect(.degrees(Layout.washiStripRotation))
            Spacer()
        }
        .padding(.vertical, Layout.spacingS)
    }
}

#Preview {
    VStack(spacing: 20) {
        WashiTapeDivider()
        WashiTapeDivider(color: .washiBlue)
        WashiTapeDivider(color: .washiRose, width: 80)
    }
    .padding()
    .background(Color.lifeBackground)
}
