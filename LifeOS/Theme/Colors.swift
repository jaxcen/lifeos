import SwiftUI

/// 设计系统 - 颜色 (暖奶油 · 简约现代风)
extension Color {
    // MARK: - 主色调
    /// 暖米白 - 主背景
    static let lifeBackground = Color(hex: "FAF6EF")
    /// 纯白 - 卡片背景
    static let lifeCardBackground = Color(hex: "FFFFFF")
    /// 深靛蓝 - 主强调色
    static let lifeAccent = Color(hex: "5856D6")
    /// 深灰 - 文字
    static let lifeText = Color(hex: "1D1D1F")
    /// 中灰 - 次要文字
    static let lifeTextSecondary = Color(hex: "86868B")

    // MARK: - 全局暖奶油主题
    static let lifeMistBackground = Color(hex: "FFF9F1")
    static let lifeLavenderMist = Color(hex: "FFF1E2")
    static let lifeSoftLavender = Color(hex: "E3E1FB")
    static let lifeSoftPeach = Color(hex: "FFE3C7")
    static let lifeSoftSky = Color(hex: "DCEBFA")
    static let lifeVoiceAccent = Color(hex: "F28D63")
    static let lifePhotoAccent = Color(hex: "6EA7E8")

    // MARK: - 日出暖色
    /// 日出橙 - 吉祥物穹顶
    static let lifeSunrise = Color(hex: "FFC18A")
    /// 日出浅杏 - 穹顶过渡
    static let lifeSunriseSoft = Color(hex: "FFE8CF")
    /// 暖沙色 - 书架托板
    static let lifeShelfWood = Color(hex: "F0DFC8")

    // MARK: - 功能色
    /// 翠绿 - 宜/正面
    static let lifeYi = Color(hex: "34C759")
    /// 珊瑚橙 - 忌/注意
    static let lifeJi = Color(hex: "FF9500")
    /// 浅紫 - 提醒
    static let lifeReminder = Color(hex: "AF52DE")

    // MARK: - 情绪色
    static let moodCalm = Color(hex: "5AC8FA")
    static let moodEnergetic = Color(hex: "FF9F0A")
    static let moodReflective = Color(hex: "BF5AF2")
    static let moodAnxious = Color(hex: "FF453A")
    static let moodHappy = Color(hex: "30D158")

    // MARK: - 卡片渐变
    static let cardGradientStart = Color(hex: "FFFFFF")
    static let cardGradientEnd = Color(hex: "F5F5F7")

    // MARK: - 装饰色
    /// 浅蓝 - 装饰条
    static let washiTan = Color(hex: "64D2FF")
    /// 雾蓝 - 装饰条
    static let washiBlue = Color(hex: "5AC8FA")
    /// 玫瑰灰 - 装饰条
    static let washiRose = Color(hex: "FF6B9D")
    /// 薄荷绿 - 装饰条（用户记录）
    static let washiGreen = Color(hex: "34C759")
    /// 纹理叠加色
    static let paperGrain = Color(hex: "E5E5EA")
    /// 暖白 - 用于日记卡片
    static let paperWarm = Color(hex: "FAFAFA")
    /// 冷白 - 用于预测卡片
    static let paperCool = Color(hex: "F2F2F7")
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
