import Foundation
import SwiftData

/// 记录模板
struct EntryTemplate: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let placeholder: String
    let prompt: String

    static let templates: [EntryTemplate] = [
        EntryTemplate(
            name: "今日感谢",
            icon: "heart",
            placeholder: "今天有什么让你感激的事...",
            prompt: "写下今天让你感激的一件事，无论大小"
        ),
        EntryTemplate(
            name: "睡前回顾",
            icon: "moon.stars",
            placeholder: "今天过得怎么样...",
            prompt: "用三句话回顾今天"
        ),
        EntryTemplate(
            name: "今日目标",
            icon: "target",
            placeholder: "今天想完成什么...",
            prompt: "今天最重要的一件事是什么"
        ),
        EntryTemplate(
            name: "压力自检",
            icon: "brain.head.profile",
            placeholder: "最近有什么让你感到压力的事...",
            prompt: "现在的压力来自哪里，给它打个分"
        ),
        EntryTemplate(
            name: "明日小行动",
            icon: "arrow.right.circle",
            placeholder: "明天想做的一件小事...",
            prompt: "给明天的自己一个小小的行动建议"
        ),
        EntryTemplate(
            name: "宜忌反馈",
            icon: "text.book.closed",
            placeholder: "今天的宜忌准吗...",
            prompt: "今天的老黄历准不准，哪里准，哪里不准"
        )
    ]
}

/// 记录页 ViewModel
@Observable
final class RecordViewModel {
    // MARK: - 状态
    var inputText = ""
    var selectedTemplate: EntryTemplate?
    var showTemplateSheet = false
    var showVoiceInput = false
    var isSaving = false
    var savedMessage: String?
    var questionnaire: DailyQuestionnaire

    // MARK: - 语音
    var speechState: SpeechState = .idle
    private let speechService: SpeechServiceProtocol
    /// 已提交的文本（在语音识别开始前的文本）
    private var committedText: String = ""

    // MARK: - 依赖
    private let modelContext: ModelContext

    init(speechService: SpeechServiceProtocol, modelContext: ModelContext) {
        self.speechService = speechService
        self.modelContext = modelContext
        self.questionnaire = DailyQuestionnaire()

        speechService.onStateChange { [weak self] state in
            Task { @MainActor in
                self?.speechState = state
                if case .completed(let text) = state {
                    self?.inputText = (self?.committedText ?? "") + text
                }
            }
        }

        // 设置部分识别结果回调（实时显示）
        if let appleSpeech = speechService as? AppleSpeechService {
            appleSpeech.partialTextHandler = { [weak self] partialText in
                Task { @MainActor in
                    // 实时更新输入文本（替换当前的部分文本）
                    self?.inputText = (self?.committedText ?? "") + partialText
                }
            }
        }
    }

    // MARK: - 模板

    func selectTemplate(_ template: EntryTemplate) {
        selectedTemplate = template
        inputText = ""
        showTemplateSheet = false
    }

    func clearTemplate() {
        selectedTemplate = nil
        inputText = ""
    }

    // MARK: - 语音

    func toggleVoiceInput() async {
        if speechState == .listening {
            do {
                _ = try await speechService.stopListening()
            } catch {
                print("语音停止错误: \(error)")
            }
        } else {
            // 保存当前文本作为已提交文本
            committedText = inputText
            do {
                try await speechService.startListening()
            } catch {
                print("语音启动错误: \(error)")
            }
        }
    }

    // MARK: - 保存

    func saveEntry() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        await MainActor.run {
            isSaving = true
        }

        let entry = DailyEntry(
            content: inputText,
            entryType: selectedTemplate != nil ? "template" : "text",
            templateName: selectedTemplate?.name
        )

        await MainActor.run {
            modelContext.insert(entry)
            savedMessage = "已记录"
            inputText = ""
            selectedTemplate = nil
            isSaving = false

            // 2秒后清除提示
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                self.savedMessage = nil
            }
        }
    }

    func saveQuestionnaire() {
        // 检查今天是否已有问卷
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let descriptor = FetchDescriptor<DailyQuestionnaire>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.energyLevel = questionnaire.energyLevel
            existing.moodScore = questionnaire.moodScore
            existing.sleepQuality = questionnaire.sleepQuality
            existing.stressLevel = questionnaire.stressLevel
            existing.socialEnergy = questionnaire.socialEnergy
            existing.topPriority = questionnaire.topPriority
            existing.worryNote = questionnaire.worryNote
            existing.gratitudeNote = questionnaire.gratitudeNote
        } else {
            modelContext.insert(questionnaire)
        }
    }
}
