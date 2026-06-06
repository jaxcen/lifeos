import SwiftUI
import SwiftData

/// 记录后自动生成日记流程
struct PostRecordFlow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let aiService: AIGenerationService?

    @State private var isGenerating = true
    @State private var isProgressComplete = false
    @State private var errorMessage: String?
    @State private var generatedDiary: AIDiary?

    var body: some View {
        Group {
            if isGenerating {
                ZStack(alignment: .topTrailing) {
                    PredictionProgressView(
                        title: "正在预测它的今天",
                        subtitle: "把刚才的记录折成今天的性格切片",
                        isComplete: isProgressComplete
                    )

                    closeButton
                }
            } else if let diary = generatedDiary {
                DiaryDetailView(diary: diary)
            } else if let error = errorMessage {
                NavigationStack {
                    errorView(error)
                        .background(Color.lifeBackground)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("关闭") { dismiss() }
                                    .foregroundStyle(Color.lifeAccent)
                            }
                        }
                }
            }
        }
        .task {
            await generateDiary()
        }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.lifeText)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
        .padding(.trailing, 18)
    }

    // MARK: - 错误

    private func errorView(_ message: String) -> some View {
        VStack(spacing: Layout.spacingXL) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Color.lifeJi)

            Text("生成失败")
                .font(.lifeHeadline)
                .foregroundStyle(Color.lifeText)

            Text(message)
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
                .multilineTextAlignment(.center)

            Button("重试") {
                Task { await generateDiary() }
            }
            .buttonStyle(.lifePill)

            Spacer()
            Spacer()
        }
        .padding(Layout.spacingXL)
    }

    // MARK: - 生成逻辑

    private func generateDiary() async {
        guard let service = aiService else {
            await MainActor.run {
                errorMessage = "AI 服务未初始化"
                isGenerating = false
            }
            return
        }

        await MainActor.run {
            isGenerating = true
            isProgressComplete = false
            errorMessage = nil
        }

        let startedAt = ContinuousClock.now
        await service.generateDiary()

        let elapsed = startedAt.duration(to: .now)
        let minimumDuration = Duration.seconds(3)
        if elapsed < minimumDuration {
            try? await Task.sleep(for: minimumDuration - elapsed)
        }

        let diary = service.currentDiaries.first
        if diary != nil {
            await MainActor.run {
                isProgressComplete = true
            }
            try? await Task.sleep(for: .milliseconds(420))
        }

        await MainActor.run {
            isGenerating = false
            if let diary {
                generatedDiary = diary
            } else if case .error(let msg) = service.loadingState {
                errorMessage = msg
            } else {
                errorMessage = "生成失败，请重试"
            }
        }
    }
}
