import Foundation

/// 语音识别状态
enum SpeechState: Equatable {
    case idle
    case listening
    case processing
    case completed(String)
    case error(String)
}

/// 语音服务协议
protocol SpeechServiceProtocol {
    /// 当前状态
    var state: SpeechState { get }

    /// 是否可用
    var isAvailable: Bool { get }

    /// 请求权限
    func requestPermission() async -> Bool

    /// 开始录音识别
    func startListening() async throws

    /// 停止录音识别
    func stopListening() async throws -> String

    /// 取消录音
    func cancel()

    /// 状态回调
    func onStateChange(_ handler: @escaping (SpeechState) -> Void)
}

/// 语音服务错误
enum SpeechServiceError: Error, LocalizedError {
    case notAuthorized
    case notAvailable
    case alreadyListening
    case noSpeechDetected
    case networkError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthorized: return "未获得语音识别权限"
        case .notAvailable: return "语音识别不可用"
        case .alreadyListening: return "已在录音中"
        case .noSpeechDetected: return "未检测到语音"
        case .networkError: return "网络错误"
        case .unknown(let e): return e.localizedDescription
        }
    }
}
