import SwiftUI
import SwiftData

/// 记录后自动生成日记流程
struct PostRecordFlow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let aiService: AIGenerationService?

    @State private var isGenerating = true
    @State private var errorMessage: String?
    @State private var generatedDiary: AIDiary?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isGenerating {
                    generatingView
                } else if let diary = generatedDiary {
                    DiaryDetailView(diary: diary)
                } else if let error = errorMessage {
                    errorView(error)
                }
            }
            .background(Color.lifeBackground)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(Color.lifeAccent)
                }
            }
        }
        .task {
            await generateDiary()
        }
    }

    // MARK: - 生成中

    private var generatingView: some View {
        VStack(spacing: Layout.spacingXXL) {
            Spacer()

            AIGeneratingView(message: "正在写今天的观察日记")

            Text("基于你刚才的记录，为你生成一篇第三人称的观察日记")
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Layout.spacingXXL)

            Spacer()
            Spacer()
        }
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
            errorMessage = nil
        }

        await service.generateDiary()

        await MainActor.run {
            isGenerating = false
            if let diary = service.currentDiaries.first {
                generatedDiary = diary
            } else if case .error(let msg) = service.loadingState {
                errorMessage = msg
            } else {
                errorMessage = "生成失败，请重试"
            }
        }
    }
}
