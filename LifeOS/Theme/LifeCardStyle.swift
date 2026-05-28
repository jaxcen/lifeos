import SwiftUI

// MARK: - 纸质卡片样式

/// 纸质卡片修饰符 - 带纸纹和暖色阴影
struct PaperCardModifier: ViewModifier {
    var padding: CGFloat = Layout.cardPadding
    var tintColor: Color = .lifeCardBackground

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // 基底纸色
                    RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                        .fill(tintColor)

                    // 对角渐变 - 模拟纸张吸墨不均
                    RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    tintColor.opacity(0),
                                    Color.paperGrain.opacity(0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // 纸纹 grain 效果
                    PaperGrainView()
                        .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius))
            .shadow(
                color: .black.opacity(0.06),
                radius: Layout.cardShadowRadius,
                y: Layout.cardShadowY
            )
    }
}

/// 纸纹 grain 效果 - 细微纹理叠加
struct PaperGrainView: View {
    var body: some View {
        Canvas { context, size in
            // 用随机散布的小矩形模拟纸张纤维
            let grainCount = 60
            for _ in 0..<grainCount {
                let x = CGFloat.random(in: 0..<size.width)
                let y = CGFloat.random(in: 0..<size.height)
                let w = CGFloat.random(in: 1...3)
                let h = CGFloat.random(in: 1...2)
                let rect = CGRect(x: x, y: y, width: w, height: h)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(Color.paperGrain.opacity(Double.random(in: 0.03...0.07)))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

/// 旧版卡片修饰符 (兼容保留)
struct LifeCardModifier: ViewModifier {
    var padding: CGFloat = Layout.cardPadding

    func body(content: Content) -> some View {
        content
            .modifier(PaperCardModifier(padding: padding))
    }
}

extension View {
    /// 新版纸质卡片样式
    func paperCard(padding: CGFloat = Layout.cardPadding, tint: Color = .lifeCardBackground) -> some View {
        modifier(PaperCardModifier(padding: padding, tintColor: tint))
    }

    /// 兼容旧版卡片样式
    func lifeCard(padding: CGFloat = Layout.cardPadding) -> some View {
        modifier(PaperCardModifier(padding: padding))
    }
}

// MARK: - 和纸条装饰

/// 和纸条修饰符 - 在卡片一角添加装饰性和纸条
struct WashiTapeModifier: ViewModifier {
    var color: Color = .washiTan
    var position: UnitPoint = .topTrailing

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                WashiTapeStrip(color: color)
                    .frame(width: 60, height: Layout.washiStripHeight)
                    .rotationEffect(.degrees(Layout.washiStripRotation))
                    .offset(x: offset.width, y: offset.height)
            }
    }

    private var alignment: Alignment {
        switch position {
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        default: return .topTrailing
        }
    }

    private var offset: CGSize {
        switch position {
        case .topLeading: return CGSize(width: -8, height: -6)
        case .topTrailing: return CGSize(width: 8, height: -6)
        case .bottomLeading: return CGSize(width: -8, height: 6)
        case .bottomTrailing: return CGSize(width: 8, height: 6)
        default: return .zero
        }
    }
}

/// 和纸条形状
struct WashiTapeStrip: View {
    var color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color.opacity(0.45))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
    }
}

extension View {
    func washiTape(_ color: Color = .washiTan, position: UnitPoint = .topTrailing) -> some View {
        modifier(WashiTapeModifier(color: color, position: position))
    }
}

// MARK: - 胶囊按钮样式

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
