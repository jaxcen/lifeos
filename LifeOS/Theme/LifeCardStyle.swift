import SwiftUI

/// 通用卡片样式
struct LifeCardModifier: ViewModifier {
    var padding: CGFloat = Layout.cardPadding

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.lifeCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius))
            .shadow(
                color: .black.opacity(0.04),
                radius: Layout.cardShadowRadius,
                y: Layout.cardShadowY
            )
    }
}

extension View {
    func lifeCard(padding: CGFloat = Layout.cardPadding) -> some View {
        modifier(LifeCardModifier(padding: padding))
    }
}

/// 胶囊按钮样式
struct PillButtonStyle: ButtonStyle {
    var color: Color = .lifeAccent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.lifeBodyEmphasis)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(color)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    static var lifePill: PillButtonStyle { PillButtonStyle() }
    static func lifePill(color: Color) -> PillButtonStyle {
        PillButtonStyle(color: color)
    }
}
