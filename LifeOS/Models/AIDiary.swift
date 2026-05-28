import Foundation
import SwiftData

/// AI 生成的今日人生观察日记
@Model
final class AIDiary {
    var id: UUID
    var date: Date

    // 侧写内容 - 第三人称观察视角
    var title: String              // 日记标题
    var body: String               // 日记正文
    var insight: String            // 核心洞察
    var observerNote: String       // 旁观者的一句话

    // 情感分析
    var detectedMood: String       // AI 检测到的情绪
    var energyPattern: String      // 能量模式描述
    var growthMoment: String?      // 今日成长瞬间
    var goalPrediction: String?    // 朝理想自我前进的观察

    var generatedAt: Date

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.title = ""
        self.body = ""
        self.insight = ""
        self.observerNote = ""
        self.detectedMood = ""
        self.energyPattern = ""
        self.generatedAt = Date()
    }
}
