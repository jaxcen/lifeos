import Foundation

/// 模拟语音服务 - 用于开发测试
final class MockSpeechService: SpeechServiceProtocol {
    private(set) var state: SpeechState = .idle
    private var stateHandler: ((SpeechState) -> Void)?
    private var isRecording = false

    var isAvailable: Bool { true }

    func requestPermission() async -> Bool {
        true
    }

    func startListening() async throws {
        guard !isRecording else {
            throw SpeechServiceError.alreadyListening
        }
        isRecording = true
        updateState(.listening)
    }

    func stopListening() async throws -> String {
        guard isRecording else {
            throw SpeechServiceError.notAvailable
        }
        isRecording = false
        updateState(.processing)

        // 模拟处理延迟
        try await Task.sleep(nanoseconds: 500_000_000)

        let mockTexts = [
            "今天感觉还不错，上午把那个拖延了很久的邮件终于发出去了",
            "下午有点犯困，效率不高，但晚上散步的时候想通了一些事",
            "最近在想要不要换个工作方向，有点迷茫但也有点期待",
            "今天和朋友聊了很久，感觉被理解了，心情好了很多",
            "没什么特别的事，就是想记录一下今天的感受，平静但有点空"
        ]
        let result = mockTexts.randomElement()!
        updateState(.completed(result))
        return result
    }

    func cancel() {
        isRecording = false
        updateState(.idle)
    }

    func onStateChange(_ handler: @escaping (SpeechState) -> Void) {
        stateHandler = handler
    }

    private func updateState(_ newState: SpeechState) {
        state = newState
        stateHandler?(newState)
    }
}
