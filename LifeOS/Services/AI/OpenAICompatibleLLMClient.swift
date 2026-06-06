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
            "max_completion_tokens": config.maxTokens
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("[LLM] ➡️ 请求: \(url.absoluteString)")
        print("[LLM] 模型: \(modelName), 消息数: \(messages.count)")

        let retryableStatusCodes = Set([500, 502, 503, 504])
        let maximumAttempts = 3

        for attempt in 1...maximumAttempts {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[LLM] ❌ 无效响应类型")
                throw AIServiceError.networkError(URLError(.badServerResponse))
            }

            print("[LLM] 状态码: \(httpResponse.statusCode)，尝试 \(attempt)/\(maximumAttempts)")

            if httpResponse.statusCode == 200 {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let choices = json?["choices"] as? [[String: Any]]
                let message = choices?.first?["message"] as? [String: Any]
                let rawContent = message?["content"] as? String ?? ""
                let reasoningContent = message?["reasoning_content"] as? String ?? ""
                let content = rawContent.isEmpty ? reasoningContent : rawContent

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

            let errorBody = String(data: data, encoding: .utf8) ?? "未知错误"
            print("[LLM] ❌ 错误响应: \(errorBody.prefix(500))")

            if httpResponse.statusCode == 429 {
                throw AIServiceError.rateLimited
            }

            if retryableStatusCodes.contains(httpResponse.statusCode), attempt < maximumAttempts {
                let delay = UInt64(attempt) * 650_000_000
                print("[LLM] 服务暂时不可用，\(Double(delay) / 1_000_000_000) 秒后自动重试")
                try await Task.sleep(nanoseconds: delay)
                continue
            }

            let description = retryableStatusCodes.contains(httpResponse.statusCode)
                ? "MiMo 服务暂时不可用，已自动重试，请稍后再试"
                : "HTTP \(httpResponse.statusCode): \(errorBody)"
            throw AIServiceError.networkError(URLError(.badServerResponse, userInfo: [
                NSLocalizedDescriptionKey: description
            ]))
        }

        throw AIServiceError.networkError(URLError(.badServerResponse))
    }
}
