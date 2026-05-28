import SwiftUI

/// 毛笔墨迹文字 - 文字后方带有墨迹晕染效果
struct BrushStrokeText: View {
    let text: String
    var font: Font = .lifeKeywordDisplay
    var textColor: Color = .lifeText
    var washColor: Color = .lifeAccent

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                // 墨迹晕染 - 带旋转的圆角矩形
                RoundedRectangle(cornerRadius: 6)
                    .fill(washColor.opacity(0.12))
                    .rotationEffect(.degrees(-2))
                    .scaleEffect(x: 1.15, y: 1.4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [washColor.opacity(0.08), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .rotationEffect(.degrees(-2))
                            .scaleEffect(x: 1.15, y: 1.4)
                    )
            )
    }
}

#Preview {
    VStack(spacing: 24) {
        BrushStrokeText(text: "破局")
        BrushStrokeText(text: "沉淀", washColor: .lifeYi)
        BrushStrokeText(text: "连接", washColor: .washiBlue)
    }
    .padding()
    .background(Color.lifeBackground)
}
