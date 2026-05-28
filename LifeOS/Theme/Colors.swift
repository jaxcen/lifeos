import SwiftUI

/// 设计系统 - 颜色 (和紙手帳風)
extension Color {
    // MARK: - 主色调
    /// 暖 parchment cream - 主背景
    static let lifeBackground = Color(hex: "F7F3ED")
    /// 暖纸白 - 卡片背景
    static let lifeCardBackground = Color(hex: "FFFCF7")
    /// 赭石 - 主强调色 (印章色)
    static let lifeAccent = Color(hex: "C4956A")
    /// 暖深棕 - 文字
    static let lifeText = Color(hex: "3D3529")
    /// 暖灰褐 - 次要文字
    static let lifeTextSecondary = Color(hex: "9E9485")

    // MARK: - 功能色
    /// 鼠尾草绿 - 宜/正面
    static let lifeYi = Color(hex: "8BAF7E")
    /// 暖琥珀 - 忌/注意
    static let lifeJi = Color(hex: "D4916B")
    /// 和紙棕 - 提醒
    static let lifeReminder = Color(hex: "B8A089")

    // MARK: - 情绪色
    static let moodCalm = Color(hex: "A8D8EA")
    static let moodEnergetic = Color(hex: "FFD3B6")
    static let moodReflective = Color(hex: "D5C4E0")
    static let moodAnxious = Color(hex: "FFB7B2")
    static let moodHappy = Color(hex: "C1E1C1")

    // MARK: - 卡片渐变
    static let cardGradientStart = Color(hex: "FFFCF7")
    static let cardGradientEnd = Color(hex: "F9F4ED")

    // MARK: - 和紙風 (Washi Style)
    /// 牛皮纸棕 - 和纸条
    static let washiTan = Color(hex: "D4A574")
    /// 雾蓝 - 和纸条
    static let washiBlue = Color(hex: "9BB5C4")
    /// 玫瑰灰 - 和纸条
    static let washiRose = Color(hex: "C9A0B0")
    /// 纸纹叠加色 (用于 grain 效果)
    static let paperGrain = Color(hex: "E8DFD3")
    /// 略暖的纸色 - 用于日记卡片
    static let paperWarm = Color(hex: "FFF8F0")
    /// 略冷的纸色 - 用于预测卡片
    static let paperCool = Color(hex: "F5F3F0")
}

// MARK: - Hex 颜色初始化
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
