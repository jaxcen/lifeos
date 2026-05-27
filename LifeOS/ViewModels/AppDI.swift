import SwiftUI
import SwiftData

/// 依赖注入容器
@Observable
final class AppDI {
    let aiService: AIServiceProtocol
    let speechService: SpeechServiceProtocol
    let ttsService: TTSServiceProtocol
    let photoStorage: PhotoStorageService

    init(
        aiService: AIServiceProtocol = MockAIService(),
        speechService: SpeechServiceProtocol = MockSpeechService(),
        ttsService: TTSServiceProtocol = MockTTSService(),
        photoStorage: PhotoStorageService = PhotoStorageService()
    ) {
        self.aiService = aiService
        self.speechService = speechService
        self.ttsService = ttsService
        self.photoStorage = photoStorage
    }

    // MARK: - 使用 MiMo 服务初始化

    /// 使用 mimo-v2.5 创建完整的 DI 容器
    /// LLM 和 TTS 使用 mimo API，STT 使用 Apple 系统语音识别
    static func mimo(baseURL: String, apiKey: String) -> AppDI {
        let llmClient = OpenAICompatibleLLMClient(
            provider: .mimo,
            baseURL: baseURL,
            apiKey: apiKey
        )
        let aiService = AIService(llmClient: llmClient)

        // 语音识别使用 Apple 系统服务（mimo API 不支持 STT 端点）
        let speechService = AppleSpeechService()

        let ttsService = MimoTTSService(
            baseURL: baseURL,
            apiKey: apiKey
        )

        return AppDI(
            aiService: aiService,
            speechService: speechService,
            ttsService: ttsService
        )
    }
}

/// 环境注入 Key
private struct AppDIKey: EnvironmentKey {
    static let defaultValue = AppDI()
}

extension EnvironmentValues {
    var appDI: AppDI {
        get { self[AppDIKey.self] }
        set { self[AppDIKey.self] = newValue }
    }
}
