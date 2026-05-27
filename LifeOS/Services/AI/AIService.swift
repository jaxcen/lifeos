import Foundation

/// AI 服务实现 - 通过 LLMClient 调用真实大模型
final class AIService: AIServiceProtocol {

    private var config: AIConfig = .default
    private let llmClient: LLMClientProtocol

    init(llmClient: LLMClientProtocol) {
        self.llmClient = llmClient
    }

    func configure(with config: AIConfig) {
        self.config = config
    }

    func generateDailyAlmanac(
        userProfile: UserProfile,
        recentEntries: [DailyEntry],
        todayQuestionnaire: DailyQuestionnaire?,
        longTermMemory: LongTermMemory?
    ) async throws -> DailyAlmanac {
        let prompt = PromptBuilder.buildDailyAlmanacPrompt(
            userProfile: userProfile,
            recentEntries: recentEntries,
            questionnaire: todayQuestionnaire,
            memory: longTermMemory
        )

        let response = try await llmClient.complete(
            systemPrompt: PromptBuilder.systemPersona,
            userPrompt: prompt,
            config: config
        )

        let almanac = try AIResponseParser.parseDailyAlmanac(response.content)
        almanac.generationModel = response.model
        return almanac
    }

    func generateDailyDiary(
        userProfile: UserProfile,
        todayEntries: [DailyEntry],
        todayQuestionnaire: DailyQuestionnaire?,
        todayAlmanac: DailyAlmanac?,
        longTermMemory: LongTermMemory?
    ) async throws -> AIDiary {
        let prompt = PromptBuilder.buildDailyDiaryPrompt(
            userProfile: userProfile,
            todayEntries: todayEntries,
            questionnaire: todayQuestionnaire,
            almanac: todayAlmanac,
            memory: longTermMemory
        )

        let response = try await llmClient.complete(
            systemPrompt: PromptBuilder.systemPersona,
            userPrompt: prompt,
            config: config
        )

        return try AIResponseParser.parseDailyDiary(response.content)
    }

    func generateTomorrowForecast(
        userProfile: UserProfile,
        todayEntries: [DailyEntry],
        todayQuestionnaire: DailyQuestionnaire?,
        todayAlmanac: DailyAlmanac?,
        recentForecasts: [TomorrowForecast],
        longTermMemory: LongTermMemory?
    ) async throws -> TomorrowForecast {
        let prompt = PromptBuilder.buildTomorrowForecastPrompt(
            userProfile: userProfile,
            todayEntries: todayEntries,
            questionnaire: todayQuestionnaire,
            almanac: todayAlmanac,
            recentForecasts: recentForecasts,
            memory: longTermMemory
        )

        let response = try await llmClient.complete(
            systemPrompt: PromptBuilder.systemPersona,
            userPrompt: prompt,
            config: config
        )

        return try AIResponseParser.parseTomorrowForecast(response.content)
    }

    func analyzeWeeklyPattern(
        userProfile: UserProfile,
        weekEntries: [DailyEntry],
        weekQuestionnaires: [DailyQuestionnaire],
        weekAlmanacs: [DailyAlmanac],
        longTermMemory: LongTermMemory?
    ) async throws -> WeeklyAnalysis {
        let prompt = PromptBuilder.buildWeeklyAnalysisPrompt(
            userProfile: userProfile,
            weekEntries: weekEntries,
            weekQuestionnaires: weekQuestionnaires,
            weekAlmanacs: weekAlmanacs,
            memory: longTermMemory
        )

        let response = try await llmClient.complete(
            systemPrompt: PromptBuilder.systemPersona,
            userPrompt: prompt,
            config: config
        )

        return try AIResponseParser.parseWeeklyAnalysis(response.content)
    }

    func updateLongTermMemory(
        currentMemory: LongTermMemory?,
        userProfile: UserProfile,
        recentEntries: [DailyEntry],
        recentAlmanacs: [DailyAlmanac],
        recentDiaries: [AIDiary]
    ) async throws -> LongTermMemory {
        let prompt = PromptBuilder.buildUpdateMemoryPrompt(
            currentMemory: currentMemory,
            userProfile: userProfile,
            recentEntries: recentEntries,
            recentAlmanacs: recentAlmanacs,
            recentDiaries: recentDiaries
        )

        let response = try await llmClient.complete(
            systemPrompt: PromptBuilder.systemPersona,
            userPrompt: prompt,
            config: config
        )

        return try AIResponseParser.parseLongTermMemoryUpdate(response.content, currentMemory: currentMemory)
    }
}
