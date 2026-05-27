import Foundation
import SwiftData

/// 首页状态
enum HomeLoadingState: Equatable {
    case idle
    case loading(String)  // 带提示文字
    case loaded
    case error(String)
}

/// 首页 ViewModel - 委托给 AIGenerationService
@Observable
final class HomeViewModel {
    var showDiarySheet = false
    var showForecastSheet = false

    let aiGenerationService: AIGenerationService

    var loadingState: HomeLoadingState {
        aiGenerationService.loadingState
    }
    var todayAlmanac: DailyAlmanac? {
        aiGenerationService.todayAlmanac
    }
    var todayDiary: AIDiary? {
        aiGenerationService.todayDiary
    }
    var tomorrowForecast: TomorrowForecast? {
        aiGenerationService.tomorrowForecast
    }

    init(aiService: AIServiceProtocol, modelContext: ModelContext) {
        self.aiGenerationService = AIGenerationService(
            aiService: aiService,
            modelContext: modelContext
        )
    }

    // MARK: - 今日日期

    var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: Date())
    }

    var todayWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    // MARK: - 加载数据

    func loadTodayData() {
        aiGenerationService.loadTodayData()
    }

    // MARK: - 生成老黄历

    func generateAlmanac() async {
        await aiGenerationService.generateAlmanac()
    }

    // MARK: - 生成侧写日记

    func generateDiary() async {
        await aiGenerationService.generateDiary()
        if todayDiary != nil {
            showDiarySheet = true
        }
    }

    // MARK: - 生成明日推演

    func generateForecast() async {
        await aiGenerationService.generateForecast()
        if tomorrowForecast != nil {
            showForecastSheet = true
        }
    }
}
