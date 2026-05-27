import Foundation

/// TTS 服务协议
protocol TTSServiceProtocol {
    /// 是否正在播放
    var isPlaying: Bool { get }

    /// 朗读文字
    func speak(_ text: String) async throws

    /// 停止朗读
    func stop()
}
