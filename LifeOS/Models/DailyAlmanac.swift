import Foundation
import SwiftData

/// 今日老黄历 - AI 生成的每日宜忌
@Model
final class DailyAlmanac {
    var id: UUID
    var date: Date

    // 核心内容
    var keyword: String            // 今日关键词，如 "破局"、"沉淀"、"连接"
    var yiList: [String]           // 今日宜
    var jiList: [String]           // 今日忌
    var reminder: String           // 今日提醒
    var encouragement: String      // 一句话鼓励

    // 元信息
    var generatedAt: Date
    var generationModel: String?   // 生成所用模型
    var isFromCache: Bool          // 是否来自缓存

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.keyword = ""
        self.yiList = []
        self.jiList = []
        self.reminder = ""
        self.encouragement = ""
        self.generatedAt = Date()
        self.isFromCache = false
    }
}
