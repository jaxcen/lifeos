import Foundation
import AVFoundation

/// OpenAI Whisper 兼容的语音识别服务（适用于 mimo-v2.5 等）
final class WhisperSpeechService: SpeechServiceProtocol {
    private(set) var state: SpeechState = .idle
    private var stateHandler: ((SpeechState) -> Void)?
    private let baseURL: String
    private let apiKey: String
    private let modelName: String
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    init(baseURL: String, apiKey: String, modelName: String = "mimo-v2.5") {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.modelName = modelName
    }

    var isAvailable: Bool {
        !baseURL.isEmpty && !apiKey.isEmpty
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startListening() async throws {
        guard isAvailable else {
            throw SpeechServiceError.notAvailable
        }

        let granted = await requestPermission()
        guard granted else {
            throw SpeechServiceError.notAuthorized
        }

        // 配置音频会话
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .default)
        try session.setActive(true)

        // 创建临时文件
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".m4a"
        recordingURL = tempDir.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        guard let url = recordingURL else { return }
        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.record()
        audioRecorder = recorder

        updateState(.listening)
    }

    func stopListening() async throws -> String {
        audioRecorder?.stop()
        audioRecorder = nil

        updateState(.processing)

        guard let url = recordingURL else {
            updateState(.error("录音文件不存在"))
            return ""
        }

        do {
            let text = try await transcribe(audioFileURL: url)
            // 清理临时文件
            try? FileManager.default.removeItem(at: url)
            updateState(.completed(text))
            return text
        } catch {
            try? FileManager.default.removeItem(at: url)
            updateState(.error(error.localizedDescription))
            throw error
        }
    }

    func cancel() {
        audioRecorder?.stop()
        audioRecorder = nil
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordingURL = nil
        updateState(.idle)
    }

    func onStateChange(_ handler: @escaping (SpeechState) -> Void) {
        stateHandler = handler
    }

    // MARK: - Whisper API 调用

    private func transcribe(audioFileURL: URL) async throws -> String {
        let url = URL(string: "\(baseURL)/audio/transcriptions")!

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let audioData = try Data(contentsOf: audioFileURL)

        print("[STT] ➡️ 请求: \(url.absoluteString)")
        print("[STT] 模型: \(modelName), 音频大小: \(audioData.count) bytes")

        var body = Data()

        // model 字段
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(modelName)\r\n".data(using: .utf8)!)

        // language 字段
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
        body.append("zh\r\n".data(using: .utf8)!)

        // file 字段
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/mp4\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[STT] ❌ 无效响应类型")
            throw SpeechServiceError.networkError
        }

        print("[STT] 状态码: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "未知错误"
            print("[STT] ❌ 错误响应: \(errorBody.prefix(500))")
            throw SpeechServiceError.networkError
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let text = json?["text"] as? String ?? ""
        print("[STT] ✅ 识别结果: \(text.prefix(200))")
        return text
    }

    private func updateState(_ newState: SpeechState) {
        state = newState
        stateHandler?(newState)
    }
}
