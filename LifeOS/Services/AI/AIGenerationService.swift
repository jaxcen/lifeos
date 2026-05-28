import Foundation
import SwiftData

/// AI 内容生成共享服务 - 支持日期参数化
@Observable
final class AIGenerationService {
    var loadingState: HomeLoadingState = .idle
    var currentAlmanac: DailyAlmanac?
    var currentDiaries: [AIDiary] = []
    var currentForecast: TomorrowForecast?

    private let aiService: AIServiceProtocol
    private let modelContext: ModelContext

    init(aiService: AIServiceProtocol, modelContext: ModelContext) {
        self.aiService = aiService
        self.modelContext = modelContext
    }

    // MARK: - 加载指定日期数据

    func loadData(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DailyAlmanac>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        currentAlmanac = try? modelContext.fetch(descriptor).first

        let diaryDescriptor = FetchDescriptor<AIDiary>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay },
            sortBy: [SortDescriptor(\.generatedAt, order: .reverse)]
        )
        currentDiaries = (try? modelContext.fetch(diaryDescriptor)) ?? []

        // 预测是针对"明天"的，所以查 forDate == 该日期的下一天
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let tomorrowEnd = calendar.date(byAdding: .day, value: 1, to: tomorrow)!
        let forecastDescriptor = FetchDescriptor<TomorrowForecast>(
            predicate: #Predicate { $0.forDate >= tomorrow && $0.forDate < tomorrowEnd }
        )
        currentForecast = try? modelContext.fetch(forecastDescriptor).first
    }

    /// 兼容旧接口
    func loadTodayData() {
        loadData(for: Date())
    }

    // MARK: - 检查指定日期是否有记录

    func hasEntries(for date: Date) -> Bool {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return (try? modelContext.fetch(descriptor).first) != nil
    }

    // MARK: - 生成老黄历

    func generateAlmanac(for date: Date = Date()) async {
        guard loadingState != .loading("正在生成今日锦囊...") else { return }

        await MainActor.run {
            loadingState = .loading("正在生成今日锦囊...")
        }

        do {
            let profile = try fetchOrCreateProfile()
            let entries = fetchRecentEntries(days: 7, from: date)
            let questionnaire = fetchQuestionnaire(for: date)
            let memory = fetchLongTermMemory()

            print("[AIGen] 生成锦囊 - 日期: \(date), 近期条目: \(entries.count)")
            let almanac = try await aiService.generateDailyAlmanac(
                userProfile: profile,
                recentEntries: entries,
                todayQuestionnaire: questionnaire,
                longTermMemory: memory
            )

            print("[AIGen] ✅ 锦囊生成成功")
            await MainActor.run {
                modelContext.insert(almanac)
                self.currentAlmanac = almanac
                loadingState = .loaded
            }
        } catch {
            print("[AIGen] ❌ 锦囊生成失败: \(error)")
            await MainActor.run {
                loadingState = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - 生成观察日记

    func generateDiary(for date: Date = Date()) async {
        await MainActor.run {
            loadingState = .loading("正在写今天的观察日记...")
        }

        do {
            let profile = try fetchOrCreateProfile()
            let entries = fetchEntries(for: date)
            let questionnaire = fetchQuestionnaire(for: date)
            let memory = fetchLongTermMemory()

            print("[AIGen] 生成日记 - 条目数: \(entries.count)")

            let diary = try await aiService.generateDailyDiary(
                userProfile: profile,
                todayEntries: entries,
                todayQuestionnaire: questionnaire,
                todayAlmanac: currentAlmanac,
                longTermMemory: memory
            )

            print("[AIGen] ✅ 日记生成成功: \(diary.title)")
            await MainActor.run {
                modelContext.insert(diary)
                self.currentDiaries.insert(diary, at: 0)
                loadingState = .loaded
            }
        } catch {
            print("[AIGen] ❌ 日记生成失败: \(error)")
            await MainActor.run {
                loadingState = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - 生成明日推演

    func generateForecast(for date: Date = Date()) async {
        await MainActor.run {
            loadingState = .loading("正在推演明天...")
        }

        do {
            let profile = try fetchOrCreateProfile()
            let entries = fetchEntries(for: date)
            let questionnaire = fetchQuestionnaire(for: date)
            let memory = fetchLongTermMemory()

            let forecast = try await aiService.generateTomorrowForecast(
                userProfile: profile,
                todayEntries: entries,
                todayQuestionnaire: questionnaire,
                todayAlmanac: currentAlmanac,
                recentForecasts: [],
                longTermMemory: memory
            )

            await MainActor.run {
                modelContext.insert(forecast)
                self.currentForecast = forecast
                loadingState = .loaded
            }
        } catch {
            await MainActor.run {
                loadingState = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - 数据获取

    func fetchOrCreateProfile() throws -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        if let profile = try modelContext.fetch(descriptor).first {
            return profile
        }
        let profile = UserProfile()
        modelContext.insert(profile)
        return profile
    }

    /// 获取指定日期前 N 天的记录
    func fetchRecentEntries(days: Int, from date: Date = Date()) -> [DailyEntry] {
        let start = Calendar.current.date(byAdding: .day, value: -days, to: date)!
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { $0.date >= start },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// 获取指定日期的记录
    func fetchEntries(for date: Date) -> [DailyEntry] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// 获取指定日期的问卷
    func fetchQuestionnaire(for date: Date) -> DailyQuestionnaire? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let descriptor = FetchDescriptor<DailyQuestionnaire>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func fetchLongTermMemory() -> LongTermMemory? {
        let descriptor = FetchDescriptor<LongTermMemory>(
            sortBy: [SortDescriptor(\.version, order: .reverse)]
        )
        return try? modelContext.fetch(descriptor).first
    }
}
