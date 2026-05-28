import Foundation
import AVFoundation

/// MiMo TTS 服务 - 通过 chat/completions 接口使用 mimo-v2.5-tts 模型生成语音
final class MimoTTSService: NSObject, TTSServiceProtocol {
    private let baseURL: String
    private let apiKey: String
    private let modelName: String
    private var audioPlayer: AVAudioPlayer?
    private(set) var isPlaying = false

    init(baseURL: String, apiKey: String, modelName: String = "mimo-v2.5-tts") {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.modelName = modelName
        super.init()
    }

    func speak(_ text: String) async throws {
        stop()

        print("[TTS] 开始生成语音，文本: \(text.prefix(50))...")
        let audioData = try await generateSpeech(text: text)

        await MainActor.run {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default)
                try session.setActive(true)

                audioPlayer = try AVAudioPlayer(data: audioData)
                audioPlayer?.delegate = self
                let started = audioPlayer?.play() ?? false
                isPlaying = true
                print("[TTS] ✅ 播放开始: \(started), 数据大小: \(audioData.count) bytes")
            } catch {
                print("[TTS] ❌ 播放失败: \(error)")
            }
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }

    // MARK: - API 调用（通过 chat/completions）

    private func generateSpeech(text: String) async throws -> Data {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60

        // mimo-v2.5-tts 需要 assistant 角色的消息作为要朗读的文本
        let body: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "user", "content": "请朗读以下文字"],
                ["role": "assistant", "content": text]
            ],
            "max_completion_tokens": 4096
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("[TTS] ➡️ 请求: \(url.absoluteString)")
        print("[TTS] 模型: \(modelName), 文本长度: \(text.count)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[TTS] ❌ 无效响应类型")
            throw NSError(domain: "MimoTTS", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "TTS 无效响应"
            ])
        }

        print("[TTS] 状态码: \(httpResponse.statusCode), 数据大小: \(data.count) bytes")

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "未知错误"
            print("[TTS] ❌ 错误响应: \(errorBody.prefix(500))")
            throw NSError(domain: "MimoTTS", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "TTS 生成失败: HTTP \(httpResponse.statusCode): \(errorBody)"
            ])
        }

        // 解析响应，提取 audio.data（base64 编码的 WAV 音频）
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let audio = message["audio"] as? [String: Any],
              let base64Data = audio["data"] as? String else {
            print("[TTS] ❌ 响应格式错误，无法提取音频数据")
            // 打印响应内容以便调试
            let responseStr = String(data: data, encoding: .utf8) ?? "无法解码"
            print("[TTS] 响应内容: \(responseStr.prefix(500))")
            throw NSError(domain: "MimoTTS", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "TTS 响应格式错误"
            ])
        }

        guard let decodedData = Data(base64Encoded: base64Data) else {
            print("[TTS] ❌ Base64 解码失败")
            throw NSError(domain: "MimoTTS", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "TTS 音频数据解码失败"
            ])
        }

        print("[TTS] ✅ 音频数据: \(decodedData.count) bytes (base64: \(base64Data.count) chars)")
        return decodedData
    }
}

// MARK: - AVAudioPlayerDelegate

extension MimoTTSService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        print("[TTS] 解码错误: \(error?.localizedDescription ?? "未知")")
    }
}
