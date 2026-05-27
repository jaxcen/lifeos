import SwiftUI

/// 侧写日记详情 - 底部弹出
struct DiaryDetailView: View {
    let diary: AIDiary
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appDI) private var di
    @State private var isSpeaking = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Layout.spacingXL) {
                    // 标题
                    Text(diary.title)
                        .font(.lifeDisplay)
                        .foregroundStyle(Color.lifeText)

                    // 正文
                    Text(diary.body)
                        .font(.lifeDiary)
                        .foregroundStyle(Color.lifeText)
                        .lineSpacing(8)

                    Divider()

                    // 洞察
                    VStack(alignment: .leading, spacing: Layout.spacingS) {
                        Label("核心洞察", systemImage: "sparkles")
                            .font(.lifeCaption)
                            .foregroundStyle(Color.lifeTextSecondary)

                        Text(diary.insight)
                            .font(.lifeBodyEmphasis)
                            .foregroundStyle(Color.lifeAccent)
                    }

                    // 情绪
                    HStack(spacing: Layout.spacingL) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("情绪")
                                .font(.lifeCaption)
                                .foregroundStyle(Color.lifeTextSecondary)
                            Text(diary.detectedMood)
                                .font(.lifeBodyEmphasis)
                                .foregroundStyle(Color.lifeText)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("能量")
                                .font(.lifeCaption)
                                .foregroundStyle(Color.lifeTextSecondary)
                            Text(diary.energyPattern)
                                .font(.lifeBodyEmphasis)
                                .foregroundStyle(Color.lifeText)
                        }
                    }

                    // 成长瞬间
                    if let moment = diary.growthMoment, !moment.isEmpty {
                        VStack(alignment: .leading, spacing: Layout.spacingS) {
                            Label("成长瞬间", systemImage: "leaf")
                                .font(.lifeCaption)
                                .foregroundStyle(Color.lifeTextSecondary)

                            Text(moment)
                                .font(.lifeBody)
                                .foregroundStyle(Color.lifeText)
                        }
                    }

                    // 成长轨迹预测
                    if let prediction = diary.goalPrediction, !prediction.isEmpty {
                        VStack(alignment: .leading, spacing: Layout.spacingS) {
                            Label("成长轨迹", systemImage: "arrow.up.right")
                                .font(.lifeCaption)
                                .foregroundStyle(Color.lifeTextSecondary)

                            Text(prediction)
                                .font(.lifeBodyEmphasis)
                                .foregroundStyle(Color.lifeYi)
                        }
                    }

                    // 旁观者的话
                    Text("「\(diary.observerNote)」")
                        .font(.lifeEncouragement)
                        .foregroundStyle(Color.lifeTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Layout.spacingL)
                }
                .padding(Layout.spacingXL)
            }
            .background(Color.lifeBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task { await toggleSpeech() }
                    } label: {
                        Image(systemName: isSpeaking ? "stop.circle.fill" : "speaker.wave.2.fill")
                            .foregroundStyle(isSpeaking ? Color.lifeJi : Color.lifeAccent)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        di.ttsService.stop()
                        dismiss()
                    }
                    .foregroundStyle(Color.lifeAccent)
                }
            }
        }
    }

    private func toggleSpeech() async {
        if isSpeaking {
            di.ttsService.stop()
            isSpeaking = false
        } else {
            isSpeaking = true
            do {
                // 朗读正文 + 洞察
                let textToSpeak = diary.body + "。" + diary.insight
                try await di.ttsService.speak(textToSpeak)
            } catch {
                print("朗读失败: \(error)")
            }
            // 播放结束后 isSpeaking 会通过 TTS service 的 delegate 自动重置
            // 但为了保险，这里也检查一下
            try? await Task.sleep(nanoseconds: 500_000_000)
            if !di.ttsService.isPlaying {
                isSpeaking = false
            }
        }
    }
}
