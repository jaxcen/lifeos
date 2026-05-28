import Foundation
import SwiftData

/// 书架 ViewModel
@Observable
final class BookshelfViewModel {
    var books: [DiaryBook] = []
    var selectedBook: DiaryBook?

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 加载所有日记并聚合为书
    func loadBooks() {
        let descriptor = FetchDescriptor<AIDiary>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let diaries = (try? modelContext.fetch(descriptor)) ?? []

        var result: [DiaryBook] = []

        // 尝试主题聚合
        if let themedBooks = DiaryBookAggregator.aggregateByTheme(diaries: diaries) {
            result.append(contentsOf: themedBooks)
        } else {
            // 回退到按月聚合
            let monthlyBooks = DiaryBookAggregator.aggregateByMonth(diaries: diaries)
            result.append(contentsOf: monthlyBooks)
        }

        // 不足 3 本时补充演示书
        if result.count < 3 {
            let demoBooks = DemoBookshelfData.books.filter { demo in
                !result.contains(where: { $0.title == demo.title })
            }
            result.append(contentsOf: demoBooks.prefix(3 - result.count))
        }

        self.books = result
    }
}
