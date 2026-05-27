import Foundation

/// AI 任务类型
enum AITaskType: String, CaseIterable {
    case generateDailyAlmanac       // 生成今日老黄历
    case generateDailyDiary         // 生成今日侧写日记
    case generateTomorrowForecast   // 生成明日推演
    case analyzeWeeklyPattern       // 分析 7 天趋势
    case updateLongTermMemory       // 更新长期记忆
}

/// AI 服务错误
enum AIServiceError: Error, LocalizedError {
    case notConfigured
    case networkError(Error)
    case parsingError(String)
    case rateLimited
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "AI 服务未配置"
        case .networkError(let e): return "网络错误: \(e.localizedDescription)"
        case .parsingError(let s): return "解析错误: \(s)"
        case .rateLimited: return "请求过于频繁，请稍后再试"
        case .unknown(let e): return "未知错误: \(e.localizedDescription)"
        }
    }
}

/// AI 服务协议 - 高层业务接口
protocol AIServiceProtocol {
    /// 配置 AI 服务
    func configure(with config: AIConfig)

    /// 生成今日老黄历
    func generateDailyAlmanac(
        userProfile: UserProfile,
        recentEntries: [DailyEntry],
        todayQuestionnaire: DailyQuestionnaire?,
        longTermMemory: LongTermMemory?
    ) async throws -> DailyAlmanac

    /// 生成今日侧写日记
    func generateDailyDiary(
        userProfile: UserProfile,
        todayEntries: [DailyEntry],
        todayQuestionnaire: DailyQuestionnaire?,
        todayAlmanac: DailyAlmanac?,
        longTermMemory: LongTermMemory?
    ) async throws -> AIDiary

    /// 生成明日推演
    func generateTomorrowForecast(
        userProfile: UserProfile,
        todayEntries: [DailyEntry],
        todayQuestionnaire: DailyQuestionnaire?,
        todayAlmanac: DailyAlmanac?,
        recentForecasts: [TomorrowForecast],
        longTermMemory: LongTermMemory?
    ) async throws -> TomorrowForecast

    /// 分析 7 天趋势
    func analyzeWeeklyPattern(
        userProfile: UserProfile,
        weekEntries: [DailyEntry],
        weekQuestionnaires: [DailyQuestionnaire],
        weekAlmanacs: [DailyAlmanac],
        longTermMemory: LongTermMemory?
    ) async throws -> WeeklyAnalysis

    /// 更新长期记忆
    func updateLongTermMemory(
        currentMemory: LongTermMemory?,
        userProfile: UserProfile,
        recentEntries: [DailyEntry],
        recentAlmanacs: [DailyAlmanac],
        recentDiaries: [AIDiary]
    ) async throws -> LongTermMemory
}
