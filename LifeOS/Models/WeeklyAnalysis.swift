import Foundation
import SwiftData

/// 7 天人格趋势分析
@Model
final class WeeklyAnalysis {
    var id: UUID
    var weekStartDate: Date
    var weekEndDate: Date
    var generatedAt: Date

    // 趋势分析
    var energyTrend: String            // 能量趋势
    var moodTrend: String              // 情绪趋势
    var dominantThemes: [String]       // 本周主导主题
    var patternInsights: [String]      // 模式洞察
    var growthHighlights: [String]     // 成长亮点
    var suggestedFocus: String         // 下周建议焦点

    // 数据摘要
    var averageEnergy: Double
    var averageMood: Double
    var entryCount: Int

    init(weekStartDate: Date = Date()) {
        self.id = UUID()
        self.weekStartDate = weekStartDate
        self.weekEndDate = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) ?? weekStartDate
        self.dominantThemes = []
        self.patternInsights = []
        self.growthHighlights = []
        self.suggestedFocus = ""
        self.energyTrend = ""
        self.moodTrend = ""
        self.averageEnergy = 0
        self.averageMood = 0
        self.entryCount = 0
        self.generatedAt = Date()
    }
}
