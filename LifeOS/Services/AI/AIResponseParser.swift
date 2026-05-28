import Foundation

/// AI 响应解析器 - 将 LLM 原始响应解析为结构化数据
struct AIResponseParser {

    // MARK: - 解析今日老黄历

    static func parseDailyAlmanac(_ response: String, date: Date = Date()) throws -> DailyAlmanac {
        let json = try extractJSON(from: response)
        let almanac = DailyAlmanac(date: date)
        almanac.keyword = json["keyword"] as? String ?? ""
        almanac.yiList = json["yi"] as? [String] ?? []
        almanac.jiList = json["ji"] as? [String] ?? []
        almanac.reminder = json["reminder"] as? String ?? ""
        almanac.encouragement = json["encouragement"] as? String ?? ""
        return almanac
    }

    // MARK: - 解析今日观察日记

    static func parseDailyDiary(_ response: String, date: Date = Date()) throws -> AIDiary {
        let json = try extractJSON(from: response)
        let diary = AIDiary(date: date)
        diary.title = json["title"] as? String ?? ""
        diary.body = json["body"] as? String ?? ""
        diary.insight = json["insight"] as? String ?? ""
        diary.observerNote = json["observerNote"] as? String ?? ""
        diary.detectedMood = json["detectedMood"] as? String ?? ""
        diary.energyPattern = json["energyPattern"] as? String ?? ""
        diary.growthMoment = json["growthMoment"] as? String
        diary.goalPrediction = json["goalPrediction"] as? String
        return diary
    }

    // MARK: - 解析明日推演

    static func parseTomorrowForecast(_ response: String) throws -> TomorrowForecast {
        let json = try extractJSON(from: response)
        let forecast = TomorrowForecast()
        forecast.predictedEnergy = json["predictedEnergy"] as? String ?? ""
        forecast.riskAlert = json["riskAlert"] as? String
        forecast.suggestedActions = json["suggestedActions"] as? [String] ?? []
        forecast.bestTimeSlot = json["bestTimeSlot"] as? String
        forecast.focusSuggestion = json["focusSuggestion"] as? String ?? ""
        forecast.oneLineAdvice = json["oneLineAdvice"] as? String ?? ""
        return forecast
    }

    // MARK: - 解析周分析

    static func parseWeeklyAnalysis(_ response: String, weekStart: Date = Date()) throws -> WeeklyAnalysis {
        let json = try extractJSON(from: response)
        let analysis = WeeklyAnalysis(weekStartDate: weekStart)
        analysis.energyTrend = json["energyTrend"] as? String ?? ""
        analysis.moodTrend = json["moodTrend"] as? String ?? ""
        analysis.dominantThemes = json["dominantThemes"] as? [String] ?? []
        analysis.patternInsights = json["patternInsights"] as? [String] ?? []
        analysis.growthHighlights = json["growthHighlights"] as? [String] ?? []
        analysis.suggestedFocus = json["suggestedFocus"] as? String ?? ""
        return analysis
    }

    // MARK: - 解析长期记忆更新

    static func parseLongTermMemoryUpdate(_ response: String, currentMemory: LongTermMemory?) throws -> LongTermMemory {
        let json = try extractJSON(from: response)
        let memory = currentMemory ?? LongTermMemory()
        memory.personalitySummary = json["personalitySummary"] as? String ?? memory.personalitySummary
        memory.behavioralPatterns = json["behavioralPatterns"] as? [String] ?? memory.behavioralPatterns
        memory.emotionalPatterns = json["emotionalPatterns"] as? [String] ?? memory.emotionalPatterns
        memory.growthAreas = json["growthAreas"] as? [String] ?? memory.growthAreas
        memory.strengthsObserved = json["strengthsObserved"] as? [String] ?? memory.strengthsObserved
        memory.recurringThemes = json["recurringThemes"] as? [String] ?? memory.recurringThemes

        if let note = json["evolutionNote"] as? String, !note.isEmpty {
            memory.evolutionNotes.append(note)
        }

        memory.version += 1
        memory.updatedAt = Date()
        return memory
    }

    // MARK: - JSON 提取

    /// 从 LLM 响应中提取 JSON（处理 markdown 代码块等情况）
    private static func extractJSON(from response: String) throws -> [String: Any] {
        var text = response.trimmingCharacters(in: .whitespacesAndNewlines)

        // 尝试从 ```json ... ``` 中提取
        if let startRange = text.range(of: "```json"),
           let endRange = text.range(of: "```", range: startRange.upperBound..<text.endIndex) {
            text = String(text[startRange.upperBound..<endRange.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let startRange = text.range(of: "```"),
                  let endRange = text.range(of: "```", range: startRange.upperBound..<text.endIndex) {
            text = String(text[startRange.upperBound..<endRange.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // 尝试找到 JSON 对象
        if let firstBrace = text.firstIndex(of: "{"),
           let lastBrace = text.lastIndex(of: "}") {
            text = String(text[firstBrace...lastBrace])
        }

        guard let data = text.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AIServiceError.parsingError("无法从响应中提取 JSON: \(response.prefix(200))")
        }

        return json
    }
}
