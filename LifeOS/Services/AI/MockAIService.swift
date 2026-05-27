import Foundation

/// 模拟 AI 服务 - 用于开发和测试，提供高质量的模拟数据
final class MockAIService: AIServiceProtocol {

    func configure(with config: AIConfig) {
        // Mock 不需要配置
    }

    func generateDailyAlmanac(
        userProfile: UserProfile,
        recentEntries: [DailyEntry],
        todayQuestionnaire: DailyQuestionnaire?,
        longTermMemory: LongTermMemory?
    ) async throws -> DailyAlmanac {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 800_000_000)

        let almanac = DailyAlmanac()
        almanac.keyword = pickKeyword(for: userProfile, mood: todayQuestionnaire?.moodScore)
        almanac.yiList = generateYiList(for: userProfile, questionnaire: todayQuestionnaire)
        almanac.jiList = generateJiList(for: userProfile, questionnaire: todayQuestionnaire)
        almanac.reminder = generateReminder(for: userProfile)
        almanac.encouragement = generateEncouragement()
        return almanac
    }

    func generateDailyDiary(
        userProfile: UserProfile,
        todayEntries: [DailyEntry],
        todayQuestionnaire: DailyQuestionnaire?,
        todayAlmanac: DailyAlmanac?,
        longTermMemory: LongTermMemory?
    ) async throws -> AIDiary {
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let diary = AIDiary()
        diary.title = ["安静的一天", "微小的前进", "与自己对话", "平凡中的力量", "一天的呼吸"].randomElement()!
        diary.body = generateDiaryBody(for: userProfile, entries: todayEntries)
        diary.insight = ["今天的选择比昨天更清晰", "犹豫本身就是一种前进", "安静不是停滞，是在积蓄"].randomElement()!
        diary.observerNote = ["他今天比自己以为的更勇敢", "有些事不需要想清楚才能做", "今天的疲惫是真实的，也是值得的"].randomElement()!
        diary.detectedMood = ["平静", "略带焦虑", "温和", "若有所思", "踏实"].randomElement()!
        diary.energyPattern = ["早高晚缓", "全天稳定", "午后回升", "渐入佳境"].randomElement()!
        diary.goalPrediction = [
            "他今天的选择开始靠近他想成为的那个人",
            "还看不到明确的方向，但他在尝试",
            "今天的小决定里藏着大方向",
            nil
        ].randomElement() ?? nil
        return diary
    }

    func generateTomorrowForecast(
        userProfile: UserProfile,
        todayEntries: [DailyEntry],
        todayQuestionnaire: DailyQuestionnaire?,
        todayAlmanac: DailyAlmanac?,
        recentForecasts: [TomorrowForecast],
        longTermMemory: LongTermMemory?
    ) async throws -> TomorrowForecast {
        try await Task.sleep(nanoseconds: 600_000_000)

        let forecast = TomorrowForecast()
        forecast.predictedEnergy = "明天上午精力较好，适合处理需要专注的事"
        forecast.riskAlert = ["下午容易被琐事打断", "可能有社交消耗", "情绪可能因天气波动"].randomElement()
        forecast.suggestedActions = [
            "上午先完成一件最重要的小事",
            "午后给自己10分钟独处时间",
            "晚上记录一件今天做到的事"
        ]
        forecast.bestTimeSlot = "上午9-11点"
        forecast.focusSuggestion = "明天试着把注意力放在一件小事上"
        forecast.oneLineAdvice = ["少想多做", "先完成再完美", "允许自己慢一点"].randomElement()!
        return forecast
    }

    func analyzeWeeklyPattern(
        userProfile: UserProfile,
        weekEntries: [DailyEntry],
        weekQuestionnaires: [DailyQuestionnaire],
        weekAlmanacs: [DailyAlmanac],
        longTermMemory: LongTermMemory?
    ) async throws -> WeeklyAnalysis {
        try await Task.sleep(nanoseconds: 1_200_000_000)

        let analysis = WeeklyAnalysis()
        analysis.energyTrend = "本周能量先升后降，周三达到峰值"
        analysis.moodTrend = "整体平稳，周末略有回升"
        analysis.dominantThemes = ["自我觉察", "小步前进", "内在对话"]
        analysis.patternInsights = [
            "你在压力下倾向于内省而非行动",
            "你的创造力在安静时刻涌现"
        ]
        analysis.growthHighlights = [
            "这周你比上周多记录了2天",
            "你开始更诚实地面对自己的状态"
        ]
        analysis.suggestedFocus = "下周试试在精力最好的时候做最难的事"
        return analysis
    }

    func updateLongTermMemory(
        currentMemory: LongTermMemory?,
        userProfile: UserProfile,
        recentEntries: [DailyEntry],
        recentAlmanacs: [DailyAlmanac],
        recentDiaries: [AIDiary]
    ) async throws -> LongTermMemory {
        try await Task.sleep(nanoseconds: 500_000_000)

        let memory = currentMemory ?? LongTermMemory()
        memory.personalitySummary = "一个在安静中寻找方向的人。习惯用文字整理思绪，对自我成长有温和但持续的渴望。不喜欢被催促，但需要被看见。"
        memory.behavioralPatterns = [
            "压力大时倾向写下来而不是说出来",
            "喜欢在晚上记录当天的感受",
            "目标清晰但执行力波动"
        ]
        memory.emotionalPatterns = [
            "情绪整体稳定，偶尔有周期性低落",
            "在被理解时会明显积极"
        ]
        memory.growthAreas = ["行动力", "自我接纳", "社交舒适区"]
        memory.strengthsObserved = ["自我觉察力强", "表达清晰", "有持续反思的习惯"]
        memory.recurringThemes = ["想做vs在做", "独处vs连接", "完美vs完成"]
        memory.evolutionNotes.append("近期对自我的观察更加细腻，开始区分'想要'和'需要'")
        memory.version += 1
        memory.updatedAt = Date()
        return memory
    }

    // MARK: - Mock 数据生成

    private func pickKeyword(for profile: UserProfile, mood: Int?) -> String {
        let keywords = ["破局", "沉淀", "连接", "蓄力", "觉察", "精简", "深耕", "放下", "重启", "聚焦"]
        return keywords.randomElement()!
    }

    private func generateYiList(for profile: UserProfile, questionnaire: DailyQuestionnaire?) -> [String] {
        var yi: [String] = []
        let pool = [
            "主动推进一个小决定",
            "和信任的人说一句真心话",
            "花15分钟做那件拖了很久的事",
            "给自己一个不被打扰的小时",
            "记录下今天的一个感受",
            "对一个不确定的事说'先试试'",
            "在犹豫时选择更小的那一步",
            "把一个大目标拆成今天的一步"
        ]
        yi.append(contentsOf: pool.shuffled().prefix(3))
        return yi
    }

    private func generateJiList(for profile: UserProfile, questionnaire: DailyQuestionnaire?) -> [String] {
        let pool = [
            "反复等待完美状态",
            "同时开始太多事情",
            "用忙碌代替思考",
            "在社交媒体上寻找答案",
            "否定自己今天的所有努力",
            "把明天的焦虑提前到今天",
            "因为没做完就否定做了的部分"
        ]
        return Array(pool.shuffled().prefix(3))
    }

    private func generateReminder(for profile: UserProfile) -> String {
        let reminders = [
            "你今天需要的不是更多计划，而是一个可完成的动作",
            "不需要想清楚所有事，先走一步",
            "今天的你已经比昨天多知道了一点",
            "有些事不急，但值得今天开始想",
            "你不需要更好，你只需要继续"
        ]
        return reminders.randomElement()!
    }

    private func generateEncouragement() -> String {
        let list = [
            "你已经在路上了",
            "今天也是有效的一天",
            "慢慢来，比较快",
            "你的方向是对的",
            "存在本身就是进展"
        ]
        return list.randomElement()!
    }

    private func generateDiaryBody(for profile: UserProfile, entries: [DailyEntry]) -> String {
        let name = profile.name.isEmpty ? "他" : profile.name
        return """
        \(name)今天花了一些时间和自己待在一起。

        没有什么惊天动地的事发生，但他写下了一些文字。这些文字不长，也不华丽，但它们是真实的。

        在某个瞬间，他停下来想了想自己最近的状态。不是批判，只是看看。就像路过一面橱窗，不经意瞥见了自己的倒影。

        今天的一个小细节是：他在犹豫的时候，没有选择逃避，而是多停留了几秒。这几秒不算什么，但观察者注意到了。

        \(name)可能不知道，今天他已经做了最难的事——诚实地面对了此刻的自己。
        """
    }
}
