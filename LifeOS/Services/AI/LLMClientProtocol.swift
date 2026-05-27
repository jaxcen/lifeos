import Foundation

/// LLM 消息角色
enum MessageRole: String, Codable {
    case system
    case user
    case assistant
}

/// LLM 消息
struct LLMMessage: Codable {
    let role: MessageRole
    let content: String
}

/// LLM 响应
struct LLMResponse: Codable {
    let content: String
    let usage: TokenUsage?
    let model: String?
}

/// Token 使用量
struct TokenUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
}

/// LLM 客户端协议 - 底层大模型调用接口
protocol LLMClientProtocol {
    /// 当前使用的模型提供商
    var provider: ModelProvider { get }

    /// 发送聊天请求
    func chat(messages: [LLMMessage], config: AIConfig) async throws -> LLMResponse

    /// 发送单轮请求（便捷方法）
    func complete(systemPrompt: String, userPrompt: String, config: AIConfig) async throws -> LLMResponse
}

extension LLMClientProtocol {
    func complete(systemPrompt: String, userPrompt: String, config: AIConfig = .default) async throws -> LLMResponse {
        let messages = [
            LLMMessage(role: .system, content: systemPrompt),
            LLMMessage(role: .user, content: userPrompt)
        ]
        return try await chat(messages: messages, config: config)
    }
}
