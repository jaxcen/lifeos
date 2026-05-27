import Foundation

/// OpenAI 兼容的 LLM 客户端（适用于 mimo-v2.5、DeepSeek、通义等）
final class OpenAICompatibleLLMClient: LLMClientProtocol {
    let provider: ModelProvider
    private let baseURL: String
    private let apiKey: String
    private let session: URLSession

    init(provider: ModelProvider, baseURL: String, apiKey: String) {
        self.provider = provider
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = URLSession.shared
    }

    func chat(messages: [LLMMessage], config: AIConfig) async throws -> LLMResponse {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60

        let modelName = config.modelName ?? provider.defaultModelName
        let body: [String: Any] = [
            "model": modelName,
            "messages": messages.map { ["role": $0.role.rawValue, "content": $0.content] },
            "temperature": config.temperature,
            "max_tokens": config.maxTokens
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("[LLM] ➡️ 请求: \(url.absoluteString)")
        print("[LLM] 模型: \(modelName), 消息数: \(messages.count)")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[LLM] ❌ 无效响应类型")
            throw AIServiceError.networkError(URLError(.badServerResponse))
        }

        print("[LLM] 状态码: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "未知错误"
            print("[LLM] ❌ 错误响应: \(errorBody.prefix(500))")
            if httpResponse.statusCode == 429 {
                throw AIServiceError.rateLimited
            }
            throw AIServiceError.networkError(URLError(.badServerResponse, userInfo: [
                NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorBody)"
            ]))
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        // mimo-v2.5 可能将内容放在 reasoning_content 中
        let content = message?["content"] as? String
            ?? message?["reasoning_content"] as? String
            ?? ""

        print("[LLM] ✅ 响应内容: \(content.prefix(200))")

        let usage = json?["usage"] as? [String: Any]
        let tokenUsage = usage.map {
            TokenUsage(
                promptTokens: $0["prompt_tokens"] as? Int ?? 0,
                completionTokens: $0["completion_tokens"] as? Int ?? 0,
                totalTokens: $0["total_tokens"] as? Int ?? 0
            )
        }

        return LLMResponse(
            content: content,
            usage: tokenUsage,
            model: json?["model"] as? String
        )
    }
}
