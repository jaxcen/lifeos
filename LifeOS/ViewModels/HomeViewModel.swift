import Foundation
import SwiftData

/// 首页状态
enum HomeLoadingState: Equatable {
    case idle
    case loading(String)  // 带提示文字
    case loaded
    case error(String)
}

/// 洞察页 ViewModel - 支持日期导航
@Observable
final class HomeViewModel {
    var showDiarySheet = false
    var showForecastSheet = false

    /// 当前选中日期
    var selectedDate: Date = Date()

    let aiGenerationService: AIGenerationService

    var loadingState: HomeLoadingState {
        aiGenerationService.loadingState
    }
    var currentAlmanac: DailyAlmanac? {
        aiGenerationService.currentAlmanac
    }
    var currentDiary: AIDiary? {
        aiGenerationService.currentDiary
    }
    var currentForecast: TomorrowForecast? {
        aiGenerationService.currentForecast
    }

    init(aiService: AIServiceProtocol, modelContext: ModelContext) {
        self.aiGenerationService = AIGenerationService(
            aiService: aiService,
            modelContext: modelContext
        )
    }

    // MARK: - 日期计算

    /// 选中日期的格式化字符串
    var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: selectedDate)
    }

    /// 选中日期的星期
    var selectedWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }

    /// 是否是今天
    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    /// 是否是未来日期
    var isFuture: Bool {
        selectedDate > Date()
    }

    /// 是否有今日记录
    var hasEntriesForSelectedDate: Bool {
        aiGenerationService.hasEntries(for: selectedDate)
    }

    // MARK: - 日期范围 (用于纸堆翻页)

    /// 可浏览的日期范围：以 selectedDate 为中心，前后各 3 天
    var visibleDates: [Date] {
        let calendar = Calendar.current
        let center = calendar.startOfDay(for: selectedDate)
        return (-3...3).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: center)
        }
    }

    /// 当前选中日期在 visibleDates 中的索引
    var selectedIndex: Int {
        // selectedDate 始终是 visibleDates 的中心，索引为 3
        return 3
    }

    /// 导航到指定索引
    func navigateToIndex(_ index: Int) {
        guard index >= 0 && index < visibleDates.count else { return }
        let calendar = Calendar.current
        let center = calendar.startOfDay(for: selectedDate)
        if let newDate = calendar.date(byAdding: .day, value: index - 3, to: center) {
            selectedDate = newDate
            loadData(for: newDate)
        }
    }

    // MARK: - 导航

    func navigateToDate(_ date: Date) {
        selectedDate = date
        loadData(for: date)
    }

    // MARK: - 加载数据

    func loadTodayData() {
        navigateToDate(Date())
    }

    func loadData(for date: Date) {
        aiGenerationService.loadData(for: date)
    }

    // MARK: - 生成老黄历

    func generateAlmanac() async {
        await aiGenerationService.generateAlmanac(for: selectedDate)
    }

    // MARK: - 生成侧写日记

    func generateDiary() async {
        await aiGenerationService.generateDiary(for: selectedDate)
        if currentDiary != nil {
            showDiarySheet = true
        }
    }

    // MARK: - 生成明日推演

    func generateForecast() async {
        await aiGenerationService.generateForecast(for: selectedDate)
        if currentForecast != nil {
            showForecastSheet = true
        }
    }
}
