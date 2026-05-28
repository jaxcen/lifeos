import Foundation
import Speech

/// Apple 系统语音识别服务
final class AppleSpeechService: SpeechServiceProtocol {
    private(set) var state: SpeechState = .idle
    private var stateHandler: ((SpeechState) -> Void)?
    /// 部分识别结果回调
    var partialTextHandler: ((String) -> Void)?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    var isAvailable: Bool {
        recognizer?.isAvailable ?? false
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startListening() async throws {
        guard isAvailable else {
            throw SpeechServiceError.notAvailable
        }

        // 检查权限
        let granted = await requestPermission()
        guard granted else {
            throw SpeechServiceError.notAuthorized
        }

        // 取消之前的任务
        recognitionTask?.cancel()
        recognitionTask = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        recognitionRequest = request

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        updateState(.listening)

        return try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false
            recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }

                if let result = result {
                    let text = result.bestTranscription.formattedString
                    if result.isFinal {
                        if !hasResumed {
                            hasResumed = true
                            self.stopAudioEngine()
                            self.updateState(.completed(text))
                            continuation.resume(returning: ())
                        }
                    } else {
                        // 实时更新部分识别结果
                        self.updateState(.listening)
                        // 通过回调通知上层最新的部分文本
                        self.partialTextHandler?(text)
                    }
                }

                if let error = error {
                    if !hasResumed {
                        hasResumed = true
                        self.stopAudioEngine()
                        self.updateState(.error(error.localizedDescription))
                        continuation.resume(throwing: SpeechServiceError.unknown(error))
                    }
                }
            }
        }
    }

    func stopListening() async throws -> String {
        stopAudioEngine()

        // 等待最终结果
        try await Task.sleep(nanoseconds: 300_000_000)

        if case .completed(let text) = state {
            return text
        }
        return ""
    }

    func cancel() {
        recognitionTask?.cancel()
        recognitionTask = nil
        stopAudioEngine()
        updateState(.idle)
    }

    func onStateChange(_ handler: @escaping (SpeechState) -> Void) {
        stateHandler = handler
    }

    private func stopAudioEngine() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
    }

    private func updateState(_ newState: SpeechState) {
        state = newState
        stateHandler?(newState)
    }
}
