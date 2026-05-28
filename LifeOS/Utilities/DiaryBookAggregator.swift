import SwiftUI

/// 将多篇日记聚合为书
struct DiaryBookAggregator {

    /// 按月聚合日记为书
    static func aggregateByMonth(diaries: [AIDiary]) -> [DiaryBook] {
        let sorted = diaries.sorted { $0.date < $1.date }
        let grouped = Dictionary(grouping: sorted) { diary in
            Calendar.current.dateComponents([.year, .month], from: diary.date)
        }

        return grouped.sorted { lhs, rhs in
            if lhs.key.year != rhs.key.year {
                return (lhs.key.year ?? 0) < (rhs.key.year ?? 0)
            }
            return (lhs.key.month ?? 0) < (rhs.key.month ?? 0)
        }.compactMap { components, diaries in
            guard let month = components.month else { return nil }
            let chapters = diaries.map { diaryToChapter($0) }
            let mood = dominantMood(from: diaries)
            let title = monthTitle(month: month, mood: mood)
            let color = moodColor(mood)
            let icon = moodIcon(mood)

            return DiaryBook(
                title: title,
                subtitle: monthSubtitle(year: components.year, month: month),
                coverColor: color,
                coverIcon: icon,
                chapters: chapters
            )
        }
    }

    /// 按主题聚合（需要至少 10 篇日记）
    static func aggregateByTheme(diaries: [AIDiary]) -> [DiaryBook]? {
        guard diaries.count >= 10 else { return nil }

        let themes: [(keywords: [String], title: String, color: Color, icon: String)] = [
            (["平静", "沉稳", "安静", "从容"], "静水深流", Color.moodCalm, "leaf.fill"),
            (["焦虑", "紧张", "不安", "迷茫"], "穿过迷雾", Color.moodReflective, "cloud.fog.fill"),
            (["成长", "突破", "进步", "坚持"], "向上生长", Color.moodHappy, "arrow.up.circle.fill"),
            (["疲惫", "劳累", "压力", "倦怠"], "休憩时光", Color.moodAnxious, "moon.stars.fill"),
            (["开心", "快乐", "满足", "幸福"], "温暖日常", Color.moodEnergetic, "sun.max.fill")
        ]

        var books: [DiaryBook] = []
        var usedDiaries: Set<UUID> = []

        for theme in themes {
            let matched = diaries.filter { diary in
                !usedDiaries.contains(diary.id) &&
                theme.keywords.contains(where: { keyword in
                    diary.detectedMood.contains(keyword) || diary.insight.contains(keyword)
                })
            }
            guard matched.count >= 2 else { continue }

            let chapters = matched.map { diaryToChapter($0) }
            usedDiaries.formUnion(matched.map(\.id))

            books.append(DiaryBook(
                title: theme.title,
                subtitle: "\(chapters.count)篇",
                coverColor: theme.color,
                coverIcon: theme.icon,
                chapters: chapters
            ))
        }

        return books.count >= 2 ? books : nil
    }

    // MARK: - Helpers

    private static func diaryToChapter(_ diary: AIDiary) -> BookChapter {
        BookChapter(
            id: diary.id,
            title: diary.title,
            date: diary.date,
            body: diary.body,
            insight: diary.insight,
            observerNote: diary.observerNote,
            detectedMood: diary.detectedMood,
            goalPrediction: diary.goalPrediction
        )
    }

    private static func dominantMood(from diaries: [AIDiary]) -> String {
        let moods = diaries.map(\.detectedMood)
        let counts = Dictionary(moods.map { ($0, 1) }, uniquingKeysWith: +)
        return counts.max(by: { $0.value < $1.value })?.key ?? ""
    }

    private static func monthTitle(month: Int, mood: String) -> String {
        let monthNames = [
            1: "一月", 2: "二月", 3: "三月", 4: "四月",
            5: "五月", 6: "六月", 7: "七月", 8: "八月",
            9: "九月", 10: "十月", 11: "十一月", 12: "十二月"
        ]
        let name = monthNames[month] ?? "\(month)月"
        if mood.isEmpty {
            return name
        }
        return "\(name)手记"
    }

    private static func monthSubtitle(year: Int?, month: Int) -> String {
        guard let year = year else { return "\(month)月" }
        return "\(year).\(month)"
    }

    private static func moodColor(_ mood: String) -> Color {
        if mood.contains("平静") || mood.contains("沉稳") || mood.contains("安静") {
            return .moodCalm
        } else if mood.contains("焦虑") || mood.contains("紧张") || mood.contains("不安") {
            return .moodReflective
        } else if mood.contains("成长") || mood.contains("突破") {
            return .moodHappy
        } else if mood.contains("疲惫") || mood.contains("压力") {
            return .moodAnxious
        } else if mood.contains("开心") || mood.contains("快乐") || mood.contains("满足") {
            return .moodEnergetic
        }
        return .lifeAccent
    }

    private static func moodIcon(_ mood: String) -> String {
        if mood.contains("平静") || mood.contains("沉稳") {
            return "leaf.fill"
        } else if mood.contains("焦虑") || mood.contains("不安") {
            return "cloud.fog.fill"
        } else if mood.contains("成长") || mood.contains("突破") {
            return "arrow.up.circle.fill"
        } else if mood.contains("疲惫") || mood.contains("压力") {
            return "moon.stars.fill"
        } else if mood.contains("开心") || mood.contains("快乐") {
            return "sun.max.fill"
        }
        return "book.closed.fill"
    }
}
