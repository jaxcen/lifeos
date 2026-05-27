import SwiftUI
import SwiftData

/// 记录输入页面
struct RecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDI) private var di
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RecordViewModel?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 顶部标签栏
                topTabs

                Divider()

                // 输入区域
                ScrollView {
                    VStack(spacing: Layout.spacingL) {
                        // 模板提示
                        if let template = viewModel?.selectedTemplate {
                            templateBanner(template)
                        }

                        // 文字输入
                        textInputArea

                        // 问卷区域
                        questionnaireSection
                    }
                    .padding(Layout.spacingL)
                }

                // 底部操作栏
                bottomBar
            }
            .background(Color.lifeBackground)
            .navigationTitle("记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(Color.lifeAccent)
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showTemplateSheet ?? false },
                set: { viewModel?.showTemplateSheet = $0 }
            )) {
                TemplatePickerSheet(
                    selectedTemplate: viewModel?.selectedTemplate,
                    onSelect: { template in
                        viewModel?.selectTemplate(template)
                    }
                )
            }
            .overlay {
                if let saved = viewModel?.savedMessage {
                    savedToast(saved)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = RecordViewModel(
                        speechService: di.speechService,
                        modelContext: modelContext
                    )
                }
            }
        }
    }

    // MARK: - 顶部标签

    private var topTabs: some View {
        HStack(spacing: Layout.spacingL) {
            ForEach(["记录", "问卷"], id: \.self) { tab in
                Text(tab)
                    .font(.lifeBodyEmphasis)
                    .foregroundStyle(tab == "记录" ? Color.lifeAccent : Color.lifeTextSecondary)
                    .padding(.vertical, Layout.spacingM)
            }
            Spacer()
        }
        .padding(.horizontal, Layout.spacingL)
        .background(Color.lifeBackground)
    }

    // MARK: - 模板提示

    private func templateBanner(_ template: EntryTemplate) -> some View {
        HStack {
            Image(systemName: template.icon)
                .foregroundStyle(Color.lifeAccent)
            Text(template.name)
                .font(.lifeBodyEmphasis)
                .foregroundStyle(Color.lifeText)
            Spacer()
            Button {
                viewModel?.clearTemplate()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.lifeTextSecondary)
            }
        }
        .padding(Layout.spacingM)
        .background(Color.lifeAccent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
    }

    // MARK: - 文字输入

    private var textInputArea: some View {
        VStack(alignment: .leading, spacing: Layout.spacingS) {
            TextEditor(text: Binding(
                get: { viewModel?.inputText ?? "" },
                set: { viewModel?.inputText = $0 }
            ))
            .font(.lifeBody)
            .foregroundStyle(Color.lifeText)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 160)
            .overlay(alignment: .topLeading) {
                if viewModel?.inputText.isEmpty ?? true {
                    Text(placeholderText)
                        .font(.lifeBody)
                        .foregroundStyle(Color.lifeTextSecondary.opacity(0.5))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
        }
        .lifeCard()
    }

    private var placeholderText: String {
        if let template = viewModel?.selectedTemplate {
            return template.placeholder
        }
        return "写下你此刻的想法..."
    }

    // MARK: - 问卷区域

    private var questionnaireSection: some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            Text("今日状态")
                .font(.lifeHeadline)
                .foregroundStyle(Color.lifeText)

            if let q = viewModel?.questionnaire {
                QuestionnaireSliderRow(
                    title: "精力",
                    icon: "bolt",
                    value: Binding(get: { q.energyLevel }, set: { q.energyLevel = $0 }),
                    color: .lifeYi
                )

                QuestionnaireSliderRow(
                    title: "心情",
                    icon: "heart",
                    value: Binding(get: { q.moodScore }, set: { q.moodScore = $0 }),
                    color: .moodCalm
                )

                QuestionnaireSliderRow(
                    title: "睡眠",
                    icon: "moon",
                    value: Binding(get: { q.sleepQuality }, set: { q.sleepQuality = $0 }),
                    color: .moodReflective
                )

                QuestionnaireSliderRow(
                    title: "压力",
                    icon: "brain.head.profile",
                    value: Binding(get: { q.stressLevel }, set: { q.stressLevel = $0 }),
                    color: .moodAnxious
                )
            }
        }
        .lifeCard()
    }

    // MARK: - 底部栏

    private var bottomBar: some View {
        HStack(spacing: Layout.spacingL) {
            // 模板按钮
            Button {
                viewModel?.showTemplateSheet = true
            } label: {
                Image(systemName: "text.book.closed")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.lifeAccent)
                    .frame(width: 44, height: 44)
                    .background(Color.lifeAccent.opacity(0.1))
                    .clipShape(Circle())
            }

            // 语音按钮
            Button {
                Task {
                    await viewModel?.toggleVoiceInput()
                }
            } label: {
                Image(systemName: viewModel?.speechState == .listening ? "stop.circle.fill" : "mic")
                    .font(.system(size: 20))
                    .foregroundStyle(viewModel?.speechState == .listening ? .red : Color.lifeAccent)
                    .frame(width: 44, height: 44)
                    .background(Color.lifeAccent.opacity(0.1))
                    .clipShape(Circle())
            }

            Spacer()

            // 保存按钮
            Button {
                Task {
                    viewModel?.saveQuestionnaire()
                    await viewModel?.saveEntry()
                }
            } label: {
                HStack(spacing: Layout.spacingXS) {
                    Image(systemName: "checkmark")
                    Text("记录")
                }
                .font(.lifeBodyEmphasis)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    (viewModel?.inputText.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
                        ? Color.lifeAccent.opacity(0.5)
                        : Color.lifeAccent
                )
                .clipShape(Capsule())
            }
            .disabled(viewModel?.inputText.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        }
        .padding(.horizontal, Layout.spacingL)
        .padding(.vertical, Layout.spacingM)
        .background(Color.lifeCardBackground)
        .shadow(color: .black.opacity(0.05), radius: 8, y: -2)
    }

    // MARK: - 保存提示

    private func savedToast(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .font(.lifeBodyEmphasis)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.lifeYi)
                .clipShape(Capsule())
                .padding(.bottom, 100)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: message)
    }
}

/// 问卷滑块行
struct QuestionnaireSliderRow: View {
    let title: String
    let icon: String
    @Binding var value: Int
    let color: Color

    var body: some View {
        HStack(spacing: Layout.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 24)

            Text(title)
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeText)
                .frame(width: 32)

            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Int($0.rounded()) }
            ), in: 1...5, step: 1)
            .tint(color)

            Text("\(value)")
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
                .frame(width: 16)
        }
    }
}

#Preview {
    RecordView()
        .modelContainer(for: [
            UserProfile.self,
            DailyEntry.self,
            DailyQuestionnaire.self
        ], inMemory: true)
}
