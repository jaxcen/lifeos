import SwiftUI

/// 设计系统 - 字体
extension Font {
    // MARK: - 标题
    /// 大标题 - 日期、关键词
    static let lifeDisplay = Font.system(size: 32, weight: .bold, design: .serif)

    /// 标题
    static let lifeTitle = Font.system(size: 22, weight: .semibold)

    /// 副标题
    static let lifeHeadline = Font.system(size: 17, weight: .semibold)

    // MARK: - 正文
    /// 正文
    static let lifeBody = Font.system(size: 16, weight: .regular)

    /// 正文强调
    static let lifeBodyEmphasis = Font.system(size: 16, weight: .medium)

    /// 小字
    static let lifeCaption = Font.system(size: 13, weight: .regular)

    /// 标签
    static let lifeTag = Font.system(size: 12, weight: .medium)

    // MARK: - 特殊
    /// 宜忌文字
    static let lifeAlmanacItem = Font.system(size: 15, weight: .medium)

    /// 提醒文字
    static let lifeReminder = Font.system(size: 15, weight: .regular, design: .serif)

    /// 侧写日记
    static let lifeDiary = Font.system(size: 15, weight: .regular, design: .serif)

    /// 鼓励语
    static let lifeEncouragement = Font.system(size: 14, weight: .medium, design: .serif)
}
