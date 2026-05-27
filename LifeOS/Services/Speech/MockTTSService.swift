import Foundation

/// 模拟 TTS 服务
final class MockTTSService: TTSServiceProtocol {
    private(set) var isPlaying = false

    func speak(_ text: String) async throws {
        isPlaying = true
        // 模拟朗读延迟
        try await Task.sleep(nanoseconds: UInt64(text.count) * 100_000_000)
        isPlaying = false
    }

    func stop() {
        isPlaying = false
    }
}
