import SwiftUI

/// 设计系统 - 字体 (简约现代风)
extension Font {
    // MARK: - 标题
    /// 大标题 - 日期、关键词
    static let lifeDisplay = Font.system(size: 32, weight: .bold, design: .default)

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
    static let lifeReminder = Font.system(size: 15, weight: .regular)

    /// 侧写日记
    static let lifeDiary = Font.system(size: 15, weight: .regular)

    /// 鼓励语
    static let lifeEncouragement = Font.system(size: 14, weight: .medium)

    // MARK: - 现代风新增
    /// 关键词大字
    static let lifeKeywordDisplay = Font.system(size: 40, weight: .bold)

    /// 日期数字 - 轻盈
    static let lifeDateNumber = Font.system(size: 28, weight: .light)

    /// 日期标签 - 月/星期
    static let lifeDateLabel = Font.system(size: 11, weight: .medium)
}
