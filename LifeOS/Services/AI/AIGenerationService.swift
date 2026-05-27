import Foundation
import SwiftData

/// AI 内容生成共享服务
@Observable
final class AIGenerationService {
    var loadingState: HomeLoadingState = .idle
    var todayAlmanac: DailyAlmanac?
    var todayDiary: AIDiary?
    var tomorrowForecast: TomorrowForecast?

    private let aiService: AIServiceProtocol
    private let modelContext: ModelContext

    init(aiService: AIServiceProtocol, modelContext: ModelContext) {
        self.aiService = aiService
        self.modelContext = modelContext
    }

    // MARK: - 加载今日已有数据

    func loadTodayData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DailyAlmanac>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        todayAlmanac = try? modelContext.fetch(descriptor).first

        let diaryDescriptor = FetchDescriptor<AIDiary>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        todayDiary = try? modelContext.fetch(diaryDescriptor).first

        let forecastDescriptor = FetchDescriptor<TomorrowForecast>(
            predicate: #Predicate { $0.forDate >= startOfDay }
        )
        tomorrowForecast = try? modelContext.fetch(forecastDescriptor).first
    }

    // MARK: - 生成老黄历

    func generateAlmanac() async {
        guard loadingState != .loading("正在生成今日老黄历...") else { return }

        await MainActor.run {
            loadingState = .loading("正在生成今日老黄历...")
        }

        do {
            let profile = try fetchOrCreateProfile()
            let entries = fetchRecentEntries(days: 7)
            let questionnaire = fetchTodayQuestionnaire()
            let memory = fetchLongTermMemory()

            print("[AIGen] 生成老黄历 - 近期条目: \(entries.count)")
            let almanac = try await aiService.generateDailyAlmanac(
                userProfile: profile,
                recentEntries: entries,
                todayQuestionnaire: questionnaire,
                longTermMemory: memory
            )

            print("[AIGen] ✅ 老黄历生成成功")
            await MainActor.run {
                modelContext.insert(almanac)
                self.todayAlmanac = almanac
                loadingState = .loaded
            }
        } catch {
            print("[AIGen] ❌ 老黄历生成失败: \(error)")
            await MainActor.run {
                loadingState = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - 生成侧写日记

    func generateDiary() async {
        await MainActor.run {
            loadingState = .loading("正在写今天的侧写日记...")
        }

        do {
            let profile = try fetchOrCreateProfile()
            let entries = fetchTodayEntries()
            let questionnaire = fetchTodayQuestionnaire()
            let memory = fetchLongTermMemory()

            print("[AIGen] 生成日记 - 条目数: \(entries.count), 画像: \(profile.name.isEmpty ? "空" : profile.name)")

            let diary = try await aiService.generateDailyDiary(
                userProfile: profile,
                todayEntries: entries,
                todayQuestionnaire: questionnaire,
                todayAlmanac: todayAlmanac,
                longTermMemory: memory
            )

            print("[AIGen] ✅ 日记生成成功: \(diary.title)")
            await MainActor.run {
                modelContext.insert(diary)
                self.todayDiary = diary
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

    func generateForecast() async {
        await MainActor.run {
            loadingState = .loading("正在推演明天...")
        }

        do {
            let profile = try fetchOrCreateProfile()
            let entries = fetchTodayEntries()
            let questionnaire = fetchTodayQuestionnaire()
            let memory = fetchLongTermMemory()

            let forecast = try await aiService.generateTomorrowForecast(
                userProfile: profile,
                todayEntries: entries,
                todayQuestionnaire: questionnaire,
                todayAlmanac: todayAlmanac,
                recentForecasts: [],
                longTermMemory: memory
            )

            await MainActor.run {
                modelContext.insert(forecast)
                self.tomorrowForecast = forecast
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

    func fetchRecentEntries(days: Int) -> [DailyEntry] {
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { $0.date >= start },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchTodayEntries() -> [DailyEntry] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchTodayQuestionnaire() -> DailyQuestionnaire? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
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
