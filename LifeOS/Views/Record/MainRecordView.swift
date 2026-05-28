import SwiftUI
import SwiftData
import PhotosUI

/// 新首页 - 记录页
struct MainRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDI) private var di
    @State private var viewModel: MainRecordViewModel?
    @State private var showPostRecord = false
    @State private var aiService: AIGenerationService?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 日期头部
                DateHeaderView(
                    date: viewModel?.todayDateString ?? "",
                    weekday: viewModel?.todayWeekday ?? ""
                )

                ScrollView {
                    VStack(spacing: Layout.spacingL) {
                        // 记录方式选择
                        recordingMethodBar

                        // 输入区域
                        inputArea

                        // 问卷（可折叠）
                        questionnaireToggle
                    }
                    .padding(Layout.spacingL)
                    .padding(.bottom, Layout.spacingXL)
                }
            }
            .background(Color.lifeBackground)
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
            .photosPicker(
                isPresented: Binding(
                    get: { viewModel?.showPhotoPicker ?? false },
                    set: { viewModel?.showPhotoPicker = $0 }
                ),
                selection: Binding(
                    get: { viewModel?.selectedPhotos ?? [] },
                    set: { viewModel?.selectedPhotos = $0 }
                ),
                maxSelectionCount: 1
            )
            .onChange(of: viewModel?.selectedPhotos ?? []) { _, _ in
                Task {
                    await viewModel?.loadPhoto()
                }
            }
            .fullScreenCover(isPresented: $showPostRecord) {
                PostRecordFlow(aiService: aiService)
            }
            .overlay {
                if let saved = viewModel?.savedMessage {
                    savedToast(saved)
                }
            }
            .onAppear {
                if viewModel == nil {
                    let vm = MainRecordViewModel(
                        speechService: di.speechService,
                        modelContext: modelContext
                    )
                    vm.onSaveComplete = {
                        if aiService == nil {
                            aiService = AIGenerationService(
                                aiService: di.aiService,
                                modelContext: modelContext
                            )
                        }
                        showPostRecord = true
                    }
                    viewModel = vm
                }
            }
        }
    }

    // MARK: - 记录方式选择

    private var recordingMethodBar: some View {
        HStack(spacing: Layout.spacingM) {
            ForEach(RecordingMethod.allCases, id: \.self) { method in
                methodButton(method)
            }
        }
    }

    private func methodButton(_ method: RecordingMethod) -> some View {
        let isSelected = viewModel?.selectedMethod == method

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel?.selectedMethod = method
            }
        } label: {
            VStack(spacing: Layout.spacingS) {
                Image(systemName: method.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .white : Color.lifeAccent)

                Text(method.rawValue)
                    .font(.lifeCaption)
                    .foregroundStyle(isSelected ? .white : Color.lifeText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Layout.spacingL)
            .background(isSelected ? Color.lifeAccent : Color.lifeCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
            .shadow(
                color: isSelected ? Color.lifeAccent.opacity(0.3) : .black.opacity(0.04),
                radius: isSelected ? 8 : 4,
                y: isSelected ? 4 : 2
            )
        }
    }

    // MARK: - 输入区域

    @ViewBuilder
    private var inputArea: some View {
        switch viewModel?.selectedMethod ?? .text {
        case .text:
            textInputArea
        case .voice:
            voiceInputArea
        case .photo:
            photoInputArea
        }
    }

    private var textInputArea: some View {
        VStack(spacing: 0) {
            // 模板提示
            if let template = viewModel?.selectedTemplate {
                templateBanner(template)
                    .padding(.horizontal, Layout.spacingM)
                    .padding(.top, Layout.spacingM)
            }

            // 文字输入
            TextEditor(text: Binding(
                get: { viewModel?.inputText ?? "" },
                set: { viewModel?.inputText = $0 }
            ))
            .font(.lifeBody)
            .foregroundStyle(Color.lifeText)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 120)
            .padding(.horizontal, Layout.spacingM)
            .overlay(alignment: .topLeading) {
                if viewModel?.inputText.isEmpty ?? true {
                    Text(placeholderText)
                        .font(.lifeBody)
                        .foregroundStyle(Color.lifeTextSecondary.opacity(0.5))
                        .padding(.top, 8)
                        .padding(.leading, Layout.spacingM + 5)
                        .allowsHitTesting(false)
                }
            }

            // 底部工具栏
            HStack {
                // 模板按钮
                Button {
                    viewModel?.showTemplateSheet = true
                } label: {
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.lifeAccent)
                        .frame(width: 36, height: 36)
                        .background(Color.lifeAccent.opacity(0.1))
                        .clipShape(Circle())
                }

                Spacer()

                // 发送按钮
                Button {
                    Task {
                        await viewModel?.save()
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            (viewModel?.canSave ?? false)
                                ? Color.lifeAccent
                                : Color.lifeAccent.opacity(0.4)
                        )
                }
                .disabled(!(viewModel?.canSave ?? false))
            }
            .padding(.horizontal, Layout.spacingM)
            .padding(.vertical, Layout.spacingS)
        }
        .lifeCard(padding: 0)
    }

    private var placeholderText: String {
        if let template = viewModel?.selectedTemplate {
            return template.placeholder
        }
        return "写下你此刻的想法..."
    }

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

    private var voiceInputArea: some View {
        VStack(spacing: Layout.spacingM) {
            VoiceRecordingWaveformView(
                speechState: viewModel?.speechState ?? .idle,
                inputText: viewModel?.inputText ?? "",
                onToggle: {
                    Task { await viewModel?.toggleVoiceInput() }
                }
            )

            // 发送按钮 - 识别完成后显示
            if viewModel?.canSave == true {
                Button {
                    Task {
                        await viewModel?.save()
                    }
                } label: {
                    HStack(spacing: Layout.spacingXS) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 20))
                        Text("记录")
                            .font(.lifeBodyEmphasis)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.lifeAccent)
                    .clipShape(Capsule())
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel?.canSave ?? false)
    }

    private var photoInputArea: some View {
        VStack(spacing: Layout.spacingM) {
            PhotoEntryView(
                photoImage: Binding(
                    get: { viewModel?.photoImage },
                    set: { viewModel?.photoImage = $0 }
                ),
                photoDescription: Binding(
                    get: { viewModel?.photoDescription ?? "" },
                    set: { viewModel?.photoDescription = $0 }
                ),
                selectedPhotos: Binding(
                    get: { viewModel?.selectedPhotos ?? [] },
                    set: { viewModel?.selectedPhotos = $0 }
                ),
                showPhotoPicker: Binding(
                    get: { viewModel?.showPhotoPicker ?? false },
                    set: { viewModel?.showPhotoPicker = $0 }
                )
            )

            // 发送按钮 - 照片选择完成后显示
            if viewModel?.canSave == true {
                Button {
                    Task {
                        await viewModel?.save()
                    }
                } label: {
                    HStack(spacing: Layout.spacingXS) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 20))
                        Text("记录")
                            .font(.lifeBodyEmphasis)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.lifeAccent)
                    .clipShape(Capsule())
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel?.canSave ?? false)
    }

    // MARK: - 问卷

    private var questionnaireToggle: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel?.showQuestionnaire.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(Color.lifeAccent)
                    Text("今日状态")
                        .font(.lifeBodyEmphasis)
                        .foregroundStyle(Color.lifeText)
                    Spacer()
                    Image(systemName: viewModel?.showQuestionnaire == true ? "chevron.up" : "chevron.down")
                        .foregroundStyle(Color.lifeTextSecondary)
                }
                .padding(Layout.spacingM)
            }

            if viewModel?.showQuestionnaire == true {
                if let q = viewModel?.questionnaire {
                    VStack(spacing: Layout.spacingM) {
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
                    .padding(.horizontal, Layout.spacingM)
                    .padding(.bottom, Layout.spacingM)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .lifeCard(padding: 0)
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
