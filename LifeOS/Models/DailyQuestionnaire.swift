import Foundation
import SwiftData

@Model
final class DailyQuestionnaire {
    var id: UUID
    var date: Date

    // 1-5 分
    var energyLevel: Int           // 精力值
    var moodScore: Int             // 心情
    var sleepQuality: Int          // 睡眠质量
    var stressLevel: Int           // 压力值
    var socialEnergy: Int          // 社交能量

    // 今日关注
    var topPriority: String?       // 今天最重要的一件事
    var worryNote: String?         // 今天的担忧
    var gratitudeNote: String?     // 今天的感恩

    var createdAt: Date

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.energyLevel = 3
        self.moodScore = 3
        self.sleepQuality = 3
        self.stressLevel = 3
        self.socialEnergy = 3
        self.createdAt = Date()
    }
}
