import Foundation
import SwiftData

/// AI 的长期人格记忆 - 记录 AI 对用户的理解
@Model
final class LongTermMemory {
    var id: UUID
    var updatedAt: Date

    // 人格画像（AI 持续更新）
    var personalitySummary: String     // 性格总结
    var behavioralPatterns: [String]   // 行为模式
    var emotionalPatterns: [String]    // 情绪模式
    var growthAreas: [String]          // 成长领域
    var strengthsObserved: [String]    // 观察到的优势

    // 关键事件记忆
    var keyMoments: [MemoryMoment]     // 关键时刻
    var recurringThemes: [String]      // 反复出现的主题

    // 演化记录
    var evolutionNotes: [String]       // 人格演化笔记
    var version: Int                   // 记忆版本号

    init() {
        self.id = UUID()
        self.personalitySummary = ""
        self.behavioralPatterns = []
        self.emotionalPatterns = []
        self.growthAreas = []
        self.strengthsObserved = []
        self.keyMoments = []
        self.recurringThemes = []
        self.evolutionNotes = []
        self.version = 0
        self.updatedAt = Date()
    }
}

/// 关键时刻记录
struct MemoryMoment: Codable, Hashable {
    let date: Date
    let description: String
    let category: String    // "突破" / "低谷" / "转变" / "坚持"
    let significance: String
}
