import SwiftUI

/// 日记聚合而成的书
struct DiaryBook: Identifiable, Equatable {
    static func == (lhs: DiaryBook, rhs: DiaryBook) -> Bool {
        lhs.id == rhs.id
    }
    let id: UUID
    let title: String
    let subtitle: String
    let coverColor: Color
    let coverIcon: String
    let chapters: [BookChapter]
    let isDemo: Bool

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        coverColor: Color,
        coverIcon: String,
        chapters: [BookChapter],
        isDemo: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coverColor = coverColor
        self.coverIcon = coverIcon
        self.chapters = chapters
        self.isDemo = isDemo
    }

    var chapterCount: Int { chapters.count }

    /// 日期范围描述
    var dateRange: String {
        guard let first = chapters.first?.date, let last = chapters.last?.date else {
            return subtitle
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }
}

/// 书中的一章（对应一篇日记）
struct BookChapter: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let body: String
    let insight: String
    let observerNote: String
    let detectedMood: String
    let goalPrediction: String?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        body: String,
        insight: String,
        observerNote: String,
        detectedMood: String,
        goalPrediction: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.body = body
        self.insight = insight
        self.observerNote = observerNote
        self.detectedMood = detectedMood
        self.goalPrediction = goalPrediction
    }
}
