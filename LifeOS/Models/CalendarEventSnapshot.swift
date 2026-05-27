import Foundation
import SwiftData

/// 日历事件快照 - 用于 AI 分析
@Model
final class CalendarEventSnapshot {
    var id: UUID
    var date: Date
    var events: [CalendarEventData]
    var fetchedAt: Date

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.events = []
        self.fetchedAt = Date()
    }
}

/// 单个日历事件
struct CalendarEventData: Codable, Hashable {
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let location: String?
    let notes: String?
}
