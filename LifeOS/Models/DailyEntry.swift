import Foundation
import SwiftData

@Model
final class DailyEntry {
    var id: UUID
    var date: Date
    var content: String
    var entryType: String          // "text" / "voice" / "template"
    var templateName: String?      // 使用的模板名
    var moodTag: String?           // 情绪标签
    var createdAt: Date

    // 关联的语音转文字原文
    var voiceTranscript: String?

    // 照片记录
    var photoFilePath: String?       // Documents 目录下的相对路径
    var photoDescription: String?    // 照片说明文字

    init(
        date: Date = Date(),
        content: String,
        entryType: String = "text",
        templateName: String? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.content = content
        self.entryType = entryType
        self.templateName = templateName
        self.createdAt = Date()
    }
}
