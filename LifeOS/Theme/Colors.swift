import SwiftUI

/// 设计系统 - 颜色
extension Color {
    // MARK: - 主色调
    /// 米白 - 主背景
    static let lifeBackground = Color(hex: "FAF8F5")
    /// 暖灰 - 次要背景
    static let lifeCardBackground = Color.white
    /// 浅蓝 - 主强调色
    static let lifeAccent = Color(hex: "7EB8D0")
    /// 深蓝灰 - 文字
    static let lifeText = Color(hex: "2C3E50")
    /// 浅灰 - 次要文字
    static let lifeTextSecondary = Color(hex: "8E9AAD")

    // MARK: - 功能色
    /// 淡绿 - 宜/正面
    static let lifeYi = Color(hex: "8BC5A3")
    /// 浅橙 - 忌/注意
    static let lifeJi = Color(hex: "E8A87C")
    /// 暖棕 - 提醒
    static let lifeReminder = Color(hex: "C4A882")

    // MARK: - 情绪色
    static let moodCalm = Color(hex: "A8D8EA")
    static let moodEnergetic = Color(hex: "FFD3B6")
    static let moodReflective = Color(hex: "D5C4E0")
    static let moodAnxious = Color(hex: "FFB7B2")
    static let moodHappy = Color(hex: "C1E1C1")

    // MARK: - 卡片渐变
    static let cardGradientStart = Color.white
    static let cardGradientEnd = Color(hex: "FDFCFA")
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
