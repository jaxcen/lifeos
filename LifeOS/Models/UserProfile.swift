import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    // 我想成为的自己
    var idealSelfDescription: String
    var coreValues: [String]       // 核心价值观，如 ["自由", "创造", "连接"]
    var currentGoals: [String]     // 当前目标
    var personalityTags: [String]  // AI 提取的性格标签

    // 用户自选画像
    var lifeStage: String?         // 学生 / 职场新人 / 自由职业 / ...
    var focusAreas: [String]       // 关注领域：事业、健康、关系、创造力...

    // 偏好
    var preferredTone: String      // 温暖 / 理性 / 幽默 / 哲思
    var notificationTime: Date?    // 每日推送时间

    var isProfileComplete: Bool {
        !name.isEmpty && !idealSelfDescription.isEmpty && !coreValues.isEmpty
    }

    init(
        name: String = "",
        idealSelfDescription: String = "",
        coreValues: [String] = [],
        currentGoals: [String] = []
    ) {
        self.id = UUID()
        self.name = name
        self.idealSelfDescription = idealSelfDescription
        self.coreValues = coreValues
        self.currentGoals = currentGoals
        self.personalityTags = []
        self.focusAreas = []
        self.preferredTone = "温暖"
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
