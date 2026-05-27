import Foundation

/// AI 模型提供商枚举
enum ModelProvider: String, CaseIterable, Codable {
    case openai = "OpenAI"
    case claude = "Claude"
    case gemini = "Gemini"
    case tongyi = "通义千问"
    case zhipu = "智谱"
    case deepseek = "DeepSeek"
    case mimo = "MiMo"
    case mock = "模拟"

    var defaultModelName: String {
        switch self {
        case .openai: return "gpt-4o"
        case .claude: return "claude-sonnet-4-20250514"
        case .gemini: return "gemini-2.0-flash"
        case .tongyi: return "qwen-max"
        case .zhipu: return "glm-4"
        case .deepseek: return "deepseek-chat"
        case .mimo: return "mimo-v2.5"
        case .mock: return "mock-model"
        }
    }

    var baseURL: String {
        switch self {
        case .openai: return "https://api.openai.com/v1"
        case .claude: return "https://api.anthropic.com/v1"
        case .gemini: return "https://generativelanguage.googleapis.com/v1beta"
        case .tongyi: return "https://dashscope.aliyuncs.com/api/v1"
        case .zhipu: return "https://open.bigmodel.cn/api/paas/v4"
        case .deepseek: return "https://api.deepseek.com/v1"
        case .mimo: return "" // 用户配置
        case .mock: return ""
        }
    }
}

/// AI 服务配置
struct AIConfig {
    var provider: ModelProvider
    var apiKey: String
    var modelName: String?
    var temperature: Double
    var maxTokens: Int

    static let `default` = AIConfig(
        provider: .mimo,
        apiKey: "",
        temperature: 0.8,
        maxTokens: 2000
    )
}
