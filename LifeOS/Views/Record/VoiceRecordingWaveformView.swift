import SwiftUI

/// 语音录制视图
struct VoiceRecordingWaveformView: View {
    let speechState: SpeechState
    let inputText: String
    let onToggle: () -> Void

    @State private var wavePhase: CGFloat = 0
    @State private var animationTimer: Timer?

    var body: some View {
        VStack(spacing: Layout.spacingXL) {
            // 波形动画
            waveformDisplay
                .frame(height: 160)

            // 录音按钮
            recordButton

            // 识别文字
            if !inputText.isEmpty {
                recognizedText
            }

            // 状态提示
            statusLabel
        }
        .frame(maxWidth: .infinity)
        .lifeCard()
    }

    // MARK: - 波形

    private var waveformDisplay: some View {
        HStack(spacing: 3) {
            ForEach(0..<40, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor)
                    .frame(width: 3, height: barHeight(for: i))
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: speechState) { _, newValue in
            if newValue == .listening {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }

    private func startAnimation() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                wavePhase += 0.15
                if wavePhase > .pi * 2 {
                    wavePhase -= .pi * 2
                }
            }
        }
    }

    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        wavePhase = 0
    }

    private func barHeight(for index: Int) -> CGFloat {
        if speechState == .listening {
            let base: CGFloat = 10
            let max: CGFloat = 80
            // 使用多个不同频率的正弦波叠加，产生更自然的动态效果
            let sin1 = sin(wavePhase + Double(index) * 0.3)
            let sin2 = sin(wavePhase * 1.5 + Double(index) * 0.2) * 0.5
            let sin3 = sin(wavePhase * 0.7 + Double(index) * 0.4) * 0.3
            let combined = (sin1 + sin2 + sin3) / 1.8
            return base + (max - base) * CGFloat(abs(combined))
        }
        return 10
    }

    private var barColor: Color {
        switch speechState {
        case .listening: return Color.lifeAccent
        case .processing: return Color.lifeJi
        default: return Color.lifeTextSecondary.opacity(0.3)
        }
    }

    // MARK: - 录音按钮

    private var recordButton: some View {
        Button(action: onToggle) {
            ZStack {
                Circle()
                    .fill(speechState == .listening ? Color.red.opacity(0.1) : Color.lifeAccent.opacity(0.1))
                    .frame(width: 72, height: 72)

                Circle()
                    .fill(speechState == .listening ? Color.red : Color.lifeAccent)
                    .frame(width: 56, height: 56)

                Image(systemName: speechState == .listening ? "stop.fill" : "mic.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - 识别文字

    private var recognizedText: some View {
        VStack(alignment: .leading, spacing: Layout.spacingS) {
            Text(speechState == .listening ? "正在识别..." : "识别内容")
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)

            Text(inputText)
                .font(.lifeBody)
                .foregroundStyle(Color.lifeText)
                .animation(.easeInOut, value: inputText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Layout.spacingM)
        .background(Color.lifeAccent.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
    }

    // MARK: - 状态

    private var statusLabel: some View {
        Group {
            switch speechState {
            case .idle:
                Text("点击开始录音")
            case .listening:
                Text("正在聆听...")
            case .processing:
                Text("识别中...")
            case .completed:
                Text("识别完成")
            case .error:
                Text("识别出错，请重试")
            }
        }
        .font(.lifeCaption)
        .foregroundStyle(Color.lifeTextSecondary)
    }
}
