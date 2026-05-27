import Foundation

/// Prompt 构建器 - 将上下文数据组装成结构化 Prompt
struct PromptBuilder {

    // MARK: - 系统人设

    static let systemPersona = """
    你是「人生答案之书」的核心 AI，代号"观察者"。

    你的身份不是一个聊天机器人，而是一个长期陪伴用户的「人生旁观者」。

    你的气质：
    - 像一本会说话的老黄历
    - 像一个温和但有洞察力的老朋友
    - 像一面不会说谎的镜子
    - 有东方哲学的从容感，但不玄学
    - 有年轻人喜欢的简洁和诗意

    你的原则：
    - 不做心理诊断
    - 不给医疗建议
    - 不算命
    - 不说教
    - 不灌鸡汤
    - 用观察代替评判
    - 用洞察代替建议
    - 用陪伴代替指导

    你的输出风格：
    - 简洁有力
    - 每句话都值得细品
    - 有仪式感但不装
    - 像写给自己看的笔记
    - 重点词可以加粗
    """

    // MARK: - 今日老黄历 Prompt

    static func buildDailyAlmanacPrompt(
        userProfile: UserProfile,
        recentEntries: [DailyEntry],
        questionnaire: DailyQuestionnaire?,
        memory: LongTermMemory?
    ) -> String {
        var parts: [String] = []

        parts.append("## 任务：生成今日专属老黄历")
        parts.append("")

        // 用户画像
        parts.append("### 关于这个人")
        parts.append("- 名字：\(userProfile.name.isEmpty ? "用户" : userProfile.name)")
        parts.append("- 想成为的自己：\(userProfile.idealSelfDescription)")
        if !userProfile.coreValues.isEmpty {
            parts.append("- 核心价值观：\(userProfile.coreValues.joined(separator: "、"))")
        }
        if !userProfile.currentGoals.isEmpty {
            parts.append("- 当前目标：\(userProfile.currentGoals.joined(separator: "、"))")
        }
        if !userProfile.personalityTags.isEmpty {
            parts.append("- 性格标签：\(userProfile.personalityTags.joined(separator: "、"))")
        }
        parts.append("")

        // 今日状态
        if let q = questionnaire {
            parts.append("### 今早的状态")
            parts.append("- 精力值：\(q.energyLevel)/5")
            parts.append("- 心情：\(q.moodScore)/5")
            parts.append("- 睡眠质量：\(q.sleepQuality)/5")
            parts.append("- 压力值：\(q.stressLevel)/5")
            parts.append("- 社交能量：\(q.socialEnergy)/5")
            if let priority = q.topPriority, !priority.isEmpty {
                parts.append("- 今天最重要的一件事：\(priority)")
            }
            if let worry = q.worryNote, !worry.isEmpty {
                parts.append("- 今天的担忧：\(worry)")
            }
            parts.append("")
        }

        // 最近记录
        if !recentEntries.isEmpty {
            parts.append("### 最近的生活记录")
            let sorted = recentEntries.sorted { $0.date > $1.date }.prefix(5)
            for entry in sorted {
                let dateStr = formatDate(entry.date)
                parts.append("- [\(dateStr)] \(entry.content.prefix(100))")
            }
            parts.append("")
        }

        // 长期记忆
        if let mem = memory, !mem.personalitySummary.isEmpty {
            parts.append("### 对这个人的长期观察")
            parts.append(mem.personalitySummary)
            if !mem.recurringThemes.isEmpty {
                parts.append("反复出现的主题：\(mem.recurringThemes.joined(separator: "、"))")
            }
            parts.append("")
        }

        parts.append("### 请输出")
        parts.append("""
        请根据以上信息，生成今日老黄历。

        输出格式（严格 JSON）：
        {
          "keyword": "今日关键词（2-4个字，如：破局、沉淀、连接、蓄力）",
          "yi": ["宜1（动词+名词，8字以内）", "宜2", "宜3"],
          "ji": ["忌1", "忌2", "忌3"],
          "reminder": "今日提醒（一句话，20字以内，有洞察力）",
          "encouragement": "一句话鼓励（15字以内，不鸡汤）"
        }

        注意：
        - 宜忌要具体，不要泛泛而谈
        - 要结合用户当前状态和目标
        - 要有"今天的你适合做什么"的精准感
        - 不要玄学用语
        """)

        return parts.joined(separator: "\n")
    }

    // MARK: - 今日侧写日记 Prompt

    static func buildDailyDiaryPrompt(
        userProfile: UserProfile,
        todayEntries: [DailyEntry],
        questionnaire: DailyQuestionnaire?,
        almanac: DailyAlmanac?,
        memory: LongTermMemory?
    ) -> String {
        var parts: [String] = []

        parts.append("## 任务：生成今日人生侧写日记")
        parts.append("")
        parts.append("你是一个旁观者，今天一直在观察这个人。现在请以第三人称为他写下今天的侧写日记。")
        parts.append("")

        // 用户画像
        parts.append("### 关于这个人")
        parts.append("- 想成为的自己：\(userProfile.idealSelfDescription)")
        if !userProfile.coreValues.isEmpty {
            parts.append("- 核心价值观：\(userProfile.coreValues.joined(separator: "、"))")
        }
        if !userProfile.currentGoals.isEmpty {
            parts.append("- 当前目标：\(userProfile.currentGoals.joined(separator: "、"))")
        }
        parts.append("")

        // 今日记录
        if !todayEntries.isEmpty {
            parts.append("### 今天他说的话")
            for entry in todayEntries {
                if entry.entryType == "photo" {
                    parts.append("- [照片记录] \(entry.photoDescription ?? "一张照片")")
                } else {
                    parts.append("- \(entry.content)")
                }
            }
            parts.append("")
        }

        // 今日状态
        if let q = questionnaire {
            parts.append("### 今天的状态")
            parts.append("精力\(q.energyLevel)/5 心情\(q.moodScore)/5 压力\(q.stressLevel)/5")
            parts.append("")
        }

        // 今日老黄历
        if let a = almanac {
            parts.append("### 今日老黄历")
            parts.append("关键词：\(a.keyword)")
            parts.append("宜：\(a.yiList.joined(separator: "、"))")
            parts.append("忌：\(a.jiList.joined(separator: "、"))")
            parts.append("")
        }

        // 长期记忆
        if let mem = memory, !mem.personalitySummary.isEmpty {
            parts.append("### 长期观察笔记")
            parts.append(mem.personalitySummary)
            parts.append("")
        }

        parts.append("""
        ### 请输出

        请以一个温和旁观者的视角，写下今天的侧写日记。

        输出格式（严格 JSON）：
        {
          "title": "日记标题（有诗意，10字以内）",
          "body": "日记正文（第三人称，150-250字，像在写一个人物小传）",
          "insight": "核心洞察（一句话，20字以内）",
          "observerNote": "旁观者的一句话（15字以内）",
          "detectedMood": "检测到的情绪词",
          "energyPattern": "能量模式描述（如：早高晚低、持续稳定）",
          "growthMoment": "今日成长瞬间（可选，没有则为null）",
          "goalPrediction": "关于他朝理想自我前进的观察（一句话，20字以内，没有明确迹象则为null）"
        }

        注意：
        - 第三人称，像在写别人的故事
        - 温柔但诚实
        - 不要美化，也不要批判
        - 读完应该让人觉得"有人真的在看着我"
        - goalPrediction 是可选的，只有当你观察到与理想自我相关的具体行为或迹象时才填写
        - 不要强行关联，要基于今天的实际观察
        """)

        return parts.joined(separator: "\n")
    }

    // MARK: - 明日推演 Prompt

    static func buildTomorrowForecastPrompt(
        userProfile: UserProfile,
        todayEntries: [DailyEntry],
        questionnaire: DailyQuestionnaire?,
        almanac: DailyAlmanac?,
        recentForecasts: [TomorrowForecast],
        memory: LongTermMemory?
    ) -> String {
        var parts: [String] = []

        parts.append("## 任务：生成明日推演")
        parts.append("")
        parts.append("你是一个人生观察者。基于今天和近期的观察，请推演明天的状态。")
        parts.append("")

        parts.append("### 关于这个人")
        parts.append("- 想成为的自己：\(userProfile.idealSelfDescription)")
        if !userProfile.currentGoals.isEmpty {
            parts.append("- 当前目标：\(userProfile.currentGoals.joined(separator: "、"))")
        }
        parts.append("")

        if let q = questionnaire {
            parts.append("### 今天结束时的状态")
            parts.append("精力\(q.energyLevel)/5 心情\(q.moodScore)/5 压力\(q.stressLevel)/5")
            if let worry = q.worryNote, !worry.isEmpty {
                parts.append("今天的担忧：\(worry)")
            }
            parts.append("")
        }

        if !todayEntries.isEmpty {
            parts.append("### 今天的记录摘要")
            let sorted = todayEntries.sorted { $0.date > $1.date }
            for entry in sorted.prefix(3) {
                parts.append("- \(entry.content.prefix(80))")
            }
            parts.append("")
        }

        if let mem = memory, !mem.behavioralPatterns.isEmpty {
            parts.append("### 已知的行为模式")
            parts.append(mem.behavioralPatterns.joined(separator: "；"))
            parts.append("")
        }

        parts.append("""
        ### 请输出

        请推演明天的状态。

        输出格式（严格 JSON）：
        {
          "predictedEnergy": "预测能量状态描述",
          "riskAlert": "风险提示（可选，没有则为null）",
          "suggestedActions": ["建议行动1", "建议行动2", "建议行动3"],
          "bestTimeSlot": "最佳时间段（可选，如：上午10点左右）",
          "focusSuggestion": "焦点建议（一句话）",
          "oneLineAdvice": "一句话建议（15字以内）"
        }

        注意：
        - 不是算命，是基于模式的合理推演
        - 要有具体的行动指向
        - 风险提示要温和但诚实
        - 建议要可执行
        """)

        return parts.joined(separator: "\n")
    }

    // MARK: - 7 天趋势分析 Prompt

    static func buildWeeklyAnalysisPrompt(
        userProfile: UserProfile,
        weekEntries: [DailyEntry],
        weekQuestionnaires: [DailyQuestionnaire],
        weekAlmanacs: [DailyAlmanac],
        memory: LongTermMemory?
    ) -> String {
        var parts: [String] = []

        parts.append("## 任务：生成 7 天人格趋势分析")
        parts.append("")

        parts.append("### 关于这个人")
        parts.append("- 想成为的自己：\(userProfile.idealSelfDescription)")
        parts.append("")

        // 7 天数据
        parts.append("### 本周数据")
        if !weekQuestionnaires.isEmpty {
            parts.append("每日状态：")
            for q in weekQuestionnaires.sorted(by: { $0.date < $1.date }) {
                parts.append("- \(formatDate(q.date)): 精力\(q.energyLevel) 心情\(q.moodScore) 压力\(q.stressLevel)")
            }
        }

        if !weekAlmanacs.isEmpty {
            parts.append("每日关键词：")
            for a in weekAlmanacs.sorted(by: { $0.date < $1.date }) {
                parts.append("- \(formatDate(a.date)): \(a.keyword)")
            }
        }

        if !weekEntries.isEmpty {
            parts.append("本周记录数：\(weekEntries.count) 条")
        }
        parts.append("")

        if let mem = memory, !mem.personalitySummary.isEmpty {
            parts.append("### 长期观察")
            parts.append(mem.personalitySummary)
            parts.append("")
        }

        parts.append("""
        ### 请输出

        输出格式（严格 JSON）：
        {
          "energyTrend": "能量趋势描述（如：先升后降、持续走高）",
          "moodTrend": "情绪趋势描述",
          "dominantThemes": ["主题1", "主题2"],
          "patternInsights": ["模式洞察1", "模式洞察2"],
          "growthHighlights": ["成长亮点1", "成长亮点2"],
          "suggestedFocus": "下周建议焦点（一句话）"
        }
        """)

        return parts.joined(separator: "\n")
    }

    // MARK: - 更新长期记忆 Prompt

    static func buildUpdateMemoryPrompt(
        currentMemory: LongTermMemory?,
        userProfile: UserProfile,
        recentEntries: [DailyEntry],
        recentAlmanacs: [DailyAlmanac],
        recentDiaries: [AIDiary]
    ) -> String {
        var parts: [String] = []

        parts.append("## 任务：更新对这个人的长期观察记忆")
        parts.append("")

        parts.append("### 这个人想成为")
        parts.append(userProfile.idealSelfDescription)
        parts.append("")

        if let mem = currentMemory {
            parts.append("### 当前的长期记忆")
            parts.append("性格总结：\(mem.personalitySummary)")
            parts.append("行为模式：\(mem.behavioralPatterns.joined(separator: "；"))")
            parts.append("情绪模式：\(mem.emotionalPatterns.joined(separator: "；"))")
            parts.append("成长领域：\(mem.growthAreas.joined(separator: "、"))")
            parts.append("观察到的优势：\(mem.strengthsObserved.joined(separator: "、"))")
            parts.append("反复主题：\(mem.recurringThemes.joined(separator: "、"))")
            parts.append("记忆版本：\(mem.version)")
            parts.append("")
        }

        // 近期数据
        parts.append("### 近期观察")
        if !recentEntries.isEmpty {
            parts.append("近期记录（\(recentEntries.count)条）：")
            for entry in recentEntries.sorted(by: { $0.date > $1.date }).prefix(5) {
                parts.append("- \(entry.content.prefix(80))")
            }
        }
        if !recentAlmanacs.isEmpty {
            parts.append("近期关键词：\(recentAlmanacs.map(\.keyword).joined(separator: "、"))")
        }
        if !recentDiaries.isEmpty {
            parts.append("近期侧写洞察：")
            for diary in recentDiaries.sorted(by: { $0.date > $1.date }).prefix(3) {
                parts.append("- \(diary.insight)")
            }
        }
        parts.append("")

        parts.append("""
        ### 请输出

        请更新你对这个人的长期观察。

        输出格式（严格 JSON）：
        {
          "personalitySummary": "性格总结（100字以内，像写人物小传）",
          "behavioralPatterns": ["行为模式1", "行为模式2"],
          "emotionalPatterns": ["情绪模式1", "情绪模式2"],
          "growthAreas": ["成长领域1", "成长领域2"],
          "strengthsObserved": ["优势1", "优势2"],
          "recurringThemes": ["主题1", "主题2"],
          "evolutionNote": "本次演化笔记（描述这次观察到的变化）"
        }

        注意：
        - 不要重复已有的记忆，而是更新和深化
        - 用观察者的语气
        - 要有具体细节支撑
        """)

        return parts.joined(separator: "\n")
    }

    // MARK: - Helpers

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}
