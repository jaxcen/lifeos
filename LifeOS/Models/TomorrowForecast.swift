import Foundation
import SwiftData

/// 明日推演
@Model
final class TomorrowForecast {
    var id: UUID
    var forDate: Date              // 推演的目标日期
    var generatedAt: Date

    // 推演内容
    var predictedEnergy: String    // 预测能量状态
    var riskAlert: String?         // 风险提示
    var suggestedActions: [String] // 建议行动
    var bestTimeSlot: String?      // 最佳时间段
    var focusSuggestion: String    // 焦点建议
    var oneLineAdvice: String      // 一句话建议

    init(forDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()) {
        self.id = UUID()
        self.forDate = forDate
        self.predictedEnergy = ""
        self.suggestedActions = []
        self.focusSuggestion = ""
        self.oneLineAdvice = ""
        self.generatedAt = Date()
    }
}
