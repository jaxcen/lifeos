import Foundation
import SwiftData
import PhotosUI
import SwiftUI

/// 记录方式
enum RecordingMethod: String, CaseIterable {
    case text = "文字"
    case voice = "语音"
    case photo = "照片"

    var icon: String {
        switch self {
        case .text: return "text.cursor"
        case .voice: return "mic.fill"
        case .photo: return "camera.fill"
        }
    }
}

/// 新首页记录 ViewModel
@Observable
final class MainRecordViewModel {
    // MARK: - 记录方式
    var selectedMethod: RecordingMethod = .text

    // MARK: - 文字输入
    var inputText = ""
    var selectedTemplate: EntryTemplate?
    var showTemplateSheet = false

    // MARK: - 语音
    var speechState: SpeechState = .idle
    private let speechService: SpeechServiceProtocol
    /// 已提交的文本（在语音识别开始前的文本）
    private var committedText: String = ""

    // MARK: - 照片
    var showPhotoPicker = false
    var selectedPhotos: [PhotosPickerItem] = []
    var photoImage: UIImage?
    var photoDescription = ""

    // MARK: - 问卷
    var questionnaire = DailyQuestionnaire()
    var showQuestionnaire = false

    // MARK: - 状态
    var isSaving = false
    var savedMessage: String?
    var onSaveComplete: (() -> Void)?

    // MARK: - 依赖
    private let modelContext: ModelContext
    private let photoStorage: PhotoStorageService

    init(speechService: SpeechServiceProtocol, modelContext: ModelContext, photoStorage: PhotoStorageService = PhotoStorageService()) {
        self.speechService = speechService
        self.modelContext = modelContext
        self.photoStorage = photoStorage

        speechService.onStateChange { [weak self] state in
            Task { @MainActor in
                self?.speechState = state
                if case .completed(let text) = state {
                    self?.inputText += text
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
            _ = try? await speechService.stopListening()
        } else {
            // 保存当前文本作为已提交文本
            committedText = inputText
            do {
                try await speechService.startListening()
            } catch {
                await MainActor.run {
                    speechState = .error("语音识别启动失败: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - 照片

    func loadPhoto() async {
        guard let item = selectedPhotos.first else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            await MainActor.run {
                self.photoImage = image
            }
        }
    }

    // MARK: - 保存

    var canSave: Bool {
        switch selectedMethod {
        case .text:
            return !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .voice:
            return !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .photo:
            return photoImage != nil
        }
    }

    func save() async {
        guard canSave else { return }

        await MainActor.run { isSaving = true }

        // 先保存问卷
        saveQuestionnaire()

        // 根据方式保存记录
        switch selectedMethod {
        case .text, .voice:
            await saveTextEntry()
        case .photo:
            await savePhotoEntry()
        }

        await MainActor.run {
            isSaving = false
            savedMessage = "已记录"
            onSaveComplete?()

            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                self.savedMessage = nil
            }
        }
    }

    private func saveTextEntry() async {
        let entry = DailyEntry(
            content: inputText,
            entryType: selectedMethod == .voice ? "voice" : (selectedTemplate != nil ? "template" : "text"),
            templateName: selectedTemplate?.name
        )
        if selectedMethod == .voice {
            entry.voiceTranscript = inputText
        }

        await MainActor.run {
            modelContext.insert(entry)
            inputText = ""
            selectedTemplate = nil
        }
    }

    private func savePhotoEntry() async {
        guard let image = photoImage else { return }

        let entryId = UUID()
        let entry = DailyEntry(
            content: photoDescription.isEmpty ? "照片记录" : photoDescription,
            entryType: "photo"
        )
        entry.id = entryId

        if let imageData = PhotoStorageService.compressImage(image) {
            entry.photoFilePath = photoStorage.savePhoto(imageData, entryId: entryId)
        }
        entry.photoDescription = photoDescription.isEmpty ? nil : photoDescription

        await MainActor.run {
            modelContext.insert(entry)
            photoImage = nil
            photoDescription = ""
            selectedPhotos = []
        }
    }

    private func saveQuestionnaire() {
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
        } else {
            modelContext.insert(questionnaire)
        }
    }
}
