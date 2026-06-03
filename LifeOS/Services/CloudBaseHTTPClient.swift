import Foundation

/// CloudBase HTTP 客户端错误
enum CloudBaseError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let statusCode, let message):
            return "HTTP 错误 \(statusCode): \(message ?? "未知错误")"
        case .decodingError(let error):
            return "解码错误: \(error.localizedDescription)"
        }
    }
}

/// CloudBase API 响应
struct CloudBaseResponse<T: Codable>: Codable {
    let success: Bool?
    let code: String?
    let message: String?
    let data: T?

    // 有些响应直接返回数据，没有包装
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Bool.self, forKey: .success)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        data = try container.decodeIfPresent(T.self, forKey: .data)
    }
}

/// CloudBase HTTP 客户端
final class CloudBaseHTTPClient {
    static let shared = CloudBaseHTTPClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - 发送请求

    /// 发送 HTTP 请求
    func send<T: Codable>(
        to path: String,
        method: String = "POST",
        body: [String: Any]? = nil,
        token: String? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: CloudBaseConfig.baseURL + path) else {
            throw CloudBaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 设置认证头
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            // 使用 Publishable Key（需要 Bearer 前缀）
            request.setValue("Bearer \(CloudBaseConfig.publishableKey)", forHTTPHeaderField: "Authorization")
        }

        // 设置请求体
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw CloudBaseError.invalidResponse
            }

            // 打印响应（调试用）
            if let jsonString = String(data: data, encoding: .utf8) {
                print("[CloudBase] Response: \(jsonString)")
            }

            // 检查 HTTP 状态码
            if httpResponse.statusCode >= 400 {
                let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                let errorMessage = errorBody?["message"] as? String
                throw CloudBaseError.httpError(
                    statusCode: httpResponse.statusCode,
                    message: errorMessage
                )
            }

            // 解码响应
            do {
                let result = try decoder.decode(T.self, from: data)
                return result
            } catch {
                throw CloudBaseError.decodingError(error)
            }
        } catch let error as CloudBaseError {
            throw error
        } catch {
            throw CloudBaseError.networkError(error)
        }
    }

    /// 发送请求并返回原始字典
    func sendRaw(
        to path: String,
        method: String = "POST",
        body: [String: Any]? = nil,
        token: String? = nil
    ) async throws -> [String: Any] {
        guard let url = URL(string: CloudBaseConfig.baseURL + path) else {
            throw CloudBaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            // 使用 Publishable Key（需要 Bearer 前缀）
            request.setValue("Bearer \(CloudBaseConfig.publishableKey)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudBaseError.invalidResponse
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw CloudBaseError.invalidResponse
        }

        if httpResponse.statusCode >= 400 {
            let errorMessage = json["message"] as? String
            throw CloudBaseError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorMessage
            )
        }

        return json
    }
}
