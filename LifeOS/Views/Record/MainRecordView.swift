import SwiftUI
import SwiftData
import PhotosUI

private struct MethodVisual {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let gradient: [Color]
}

private extension RecordingMethod {
    var expansionID: String {
        switch self {
        case .text: return "record-method-text"
        case .voice: return "record-method-voice"
        case .photo: return "record-method-photo"
        }
    }
}

/// 新首页 - 记录页
struct MainRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDI) private var di
    @State private var viewModel: MainRecordViewModel?
    @State private var showPostRecord = false
    @State private var aiService: AIGenerationService?
    @State private var isRecordPanelExpanded = false
    @Namespace private var recordExpansionNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                homeBackground

                ScrollView(showsIndicators: false) {
                    VStack(spacing: isRecordPanelExpanded ? 16 : 22) {
                        homeHeader

                        if isRecordPanelExpanded {
                            expandedRecordPanel
                                .transition(.identity)
                        } else {
                            recordingMethodStage
                            collapsedQuickInput
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 36)
                }
            }
            .navigationBarHidden(true)
            .animation(.spring(response: 0.42, dampingFraction: 0.86), value: isRecordPanelExpanded)
            .animation(.spring(response: 0.34, dampingFraction: 0.82), value: viewModel?.selectedMethod ?? .text)
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

    private var homeBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.lifeMistBackground,
                    Color.lifeLavenderMist.opacity(0.9),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.lifeSoftLavender.opacity(0.38))
                .frame(width: 280, height: 280)
                .blur(radius: 34)
                .offset(x: 120, y: -180)

            Circle()
                .fill(Color.lifeSoftSky.opacity(0.42))
                .frame(width: 260, height: 260)
                .blur(radius: 38)
                .offset(x: -150, y: 240)
        }
        .ignoresSafeArea()
    }

    private var homeHeader: some View {
        let compact = isRecordPanelExpanded

        return ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: compact ? 10 : 24) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel?.todayDateString ?? "今天")
                            .font(.system(size: compact ? 32 : 48, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.lifeText)

                        HStack(spacing: 12) {
                            Text(viewModel?.todayWeekday ?? "")
                            Image(systemName: "sun.max")
                            Text("晴 26°C")
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.lifeTextSecondary)
                    }

                    Spacer(minLength: 12)

                    todayReviewMascot(compact: compact)
                        .padding(.top, compact ? 2 : 8)
                }

                if compact {
                    Text("继续记录此刻的想法")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.lifeTextSecondary)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(greetingText)
                        Text("今天想用什么方式")
                        Text("记录你的想法呢？")
                    }
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.lifeText)
                    .lineSpacing(3)
                    .padding(.top, 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: compact ? 104 : 300)
    }

    private func todayReviewMascot(compact: Bool) -> some View {
        ZStack(alignment: .trailing) {
            if compact {
                MascotVideoView(resourceName: "lifeos-mascot")
                    .frame(width: 58, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                MascotVideoView(resourceName: "lifeos-mascot")
                    .frame(width: 112, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .offset(x: -42, y: 12)

                Text("今日回顾")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.lifeAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Color.white.opacity(0.32), in: Capsule())
            }
        }
        .frame(width: compact ? 64 : 166, height: compact ? 58 : 116)
        .glassEffect(.regular, in: Capsule())
        .shadow(color: Color.lifeAccent.opacity(0.12), radius: 14, y: 8)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "嗨，早上好呀！"
        case 12..<13:
            return "嗨，中午好呀！"
        case 13..<18:
            return "嗨，下午好呀！"
        default: return "嗨，晚上好呀！"
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

    private var recordingMethodStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 120, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 120, style: .continuous))
                .frame(height: 118)
                .offset(y: 64)

            HStack(alignment: .bottom, spacing: -14) {
                methodFeatureCard(.text)
                    .frame(width: 118, height: 164)
                    .rotationEffect(.degrees(-5))
                    .offset(y: 12)

                methodFeatureCard(.voice)
                    .frame(width: 128, height: 180)
                    .rotationEffect(.degrees(2))
                    .zIndex(1)

                methodFeatureCard(.photo)
                    .frame(width: 118, height: 164)
                    .rotationEffect(.degrees(5))
                    .offset(y: 12)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 214)
    }

    private var collapsedQuickInput: some View {
        Button {
            selectMethod(viewModel?.selectedMethod ?? .text)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text("写下你此刻的想法...")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.lifeTextSecondary.opacity(0.62))
                    .padding(.top, 22)
                    .padding(.horizontal, 22)

                Spacer(minLength: 54)

                HStack {
                    Label("我的日记", systemImage: "book.closed")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.lifeAccent)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color.lifeAccent.opacity(0.09), in: Capsule())

                    Spacer()

                    Image(systemName: "arrow.up")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.lifeAccent.opacity(0.45), in: Circle())
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }
            .frame(height: 172)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(.white.opacity(0.78), lineWidth: 1)
            )
            .shadow(color: Color.lifeAccent.opacity(0.08), radius: 24, y: 14)
        }
        .buttonStyle(.plain)
    }

    private var expandedRecordPanel: some View {
        let method = viewModel?.selectedMethod ?? .text
        let visual = methodVisual(method)

        return VStack(spacing: 16) {
            HStack(spacing: 10) {
                methodIconBlock(method, visual: visual)
                    .frame(width: 72, height: 64)

                VStack(alignment: .leading, spacing: 4) {
                    Text(visual.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.lifeText)
                    Text(visual.subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.lifeTextSecondary)
                }

                Spacer()

                HStack(spacing: 6) {
                    ForEach(RecordingMethod.allCases, id: \.self) { item in
                        Button {
                            selectMethod(item)
                        } label: {
                            Image(systemName: methodVisual(item).icon)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(item == method ? .white : methodVisual(item).color)
                                .frame(width: 34, height: 34)
                                .background(item == method ? methodVisual(item).color : Color.white.opacity(0.36), in: Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            inputArea
        }
        .padding(18)
        .background(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.white.opacity(0.12))
                .matchedGeometryEffect(id: method.expansionID, in: recordExpansionNamespace)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: visual.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(0.76)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(.white.opacity(0.82), lineWidth: 1)
        )
        .shadow(color: visual.color.opacity(0.22), radius: 24, y: 14)
    }

    private func methodIconBlock(_ method: RecordingMethod, visual: MethodVisual) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(visual.color.opacity(0.13))

            if method == .text {
                Text("AI")
                    .font(.system(size: 27, weight: .medium, design: .rounded))
                    .foregroundStyle(visual.color)
            } else {
                Image(systemName: visual.icon)
                    .font(.system(size: 27, weight: .semibold))
                    .foregroundStyle(visual.color)
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

    private func methodFeatureCard(_ method: RecordingMethod) -> some View {
        let isSelected = (viewModel?.selectedMethod ?? .text) == method
        let visual = methodVisual(method)

        return Button {
            selectMethod(method)
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(visual.color.opacity(0.13))
                        .frame(height: 50)

                    if method == .text {
                        Text("AI")
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                    } else {
                        Image(systemName: visual.icon)
                            .font(.system(size: 28, weight: .semibold))
                    }
                }
                .foregroundStyle(visual.color)

                VStack(spacing: 4) {
                    Text(visual.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.lifeText)
                        .minimumScaleFactor(0.82)

                    Text(visual.subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.lifeTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.top, 18)
            .padding(.bottom, 12)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.16))
                    .matchedGeometryEffect(id: method.expansionID, in: recordExpansionNamespace)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: visual.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(isSelected ? visual.color.opacity(0.55) : .white.opacity(0.75), lineWidth: isSelected ? 1.4 : 1)
            )
            .shadow(color: visual.color.opacity(isSelected ? 0.32 : 0.16), radius: isSelected ? 20 : 12, y: isSelected ? 10 : 7)
            .scaleEffect(isSelected ? 1.07 : 0.98)
            .offset(y: isSelected ? -8 : 0)
        }
        .buttonStyle(.plain)
    }

    private func compactMethodChip(_ method: RecordingMethod) -> some View {
        let isSelected = (viewModel?.selectedMethod ?? .text) == method
        let visual = methodVisual(method)

        return Button {
            selectMethod(method)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: visual.icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(method.rawValue)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundStyle(isSelected ? .white : visual.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                Group {
                    if isSelected {
                        Capsule().fill(visual.color)
                    } else {
                        Capsule().fill(.white.opacity(0.28))
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }

    private var startHint: some View {
        Text("点选一种记录方式开始")
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.lifeTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.72), lineWidth: 1))
            .shadow(color: Color.lifeAccent.opacity(0.08), radius: 16, y: 8)
    }

    private func selectMethod(_ method: RecordingMethod) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
            viewModel?.selectedMethod = method
            isRecordPanelExpanded = true
        }
    }

    private func methodVisual(_ method: RecordingMethod) -> MethodVisual {
        switch method {
        case .text:
            return MethodVisual(
                title: "文字记录",
                subtitle: "记录此刻的想法",
                icon: "text.cursor",
                color: Color.lifeAccent,
                gradient: [Color.white, Color.lifeSoftLavender.opacity(0.68)]
            )
        case .voice:
            return MethodVisual(
                title: "语音记录",
                subtitle: "说出你的心里话",
                icon: "mic.fill",
                color: Color.lifeVoiceAccent,
                gradient: [Color.white, Color.lifeSoftPeach.opacity(0.78)]
            )
        case .photo:
            return MethodVisual(
                title: "图片记录",
                subtitle: "用图片记录生活",
                icon: "camera.fill",
                color: Color.lifePhotoAccent,
                gradient: [Color.white, Color.lifeSoftSky.opacity(0.82)]
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
            if let template = viewModel?.selectedTemplate {
                templateBanner(template)
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
            }

            TextEditor(text: Binding(
                get: { viewModel?.inputText ?? "" },
                set: { viewModel?.inputText = $0 }
            ))
            .font(.lifeBody)
            .foregroundStyle(Color.lifeText)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 170)
            .padding(.horizontal, 18)
            .padding(.top, viewModel?.selectedTemplate == nil ? 18 : 8)
            .overlay(alignment: .topLeading) {
                if viewModel?.inputText.isEmpty ?? true {
                    Text(placeholderText)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.lifeTextSecondary.opacity(0.58))
                        .padding(.top, viewModel?.selectedTemplate == nil ? 26 : 16)
                        .padding(.leading, 23)
                        .allowsHitTesting(false)
                }
            }

            HStack {
                Button {
                    viewModel?.showTemplateSheet = true
                } label: {
                    Label("我的日记", systemImage: "book.closed")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.lifeAccent)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color.lifeAccent.opacity(0.09), in: Capsule())
                }

                Spacer()

                Button {
                    Task {
                        await viewModel?.save()
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 58)
                        .background(
                            (viewModel?.canSave ?? false)
                                ? Color.lifeAccent
                                : Color.lifeAccent.opacity(0.35),
                            in: Circle()
                        )
                        .shadow(color: Color.lifeAccent.opacity((viewModel?.canSave ?? false) ? 0.32 : 0), radius: 14, y: 8)
                }
                .disabled(!(viewModel?.canSave ?? false))
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.86), lineWidth: 1)
        )
        .shadow(color: Color.lifeAccent.opacity(0.08), radius: 24, y: 14)
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
        .background(Color.lifeAccent.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        .padding(18)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.75), lineWidth: 1)
        )
        .shadow(color: Color.lifeAccent.opacity(0.08), radius: 24, y: 14)
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
        .padding(18)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.75), lineWidth: 1)
        )
        .shadow(color: Color.lifeAccent.opacity(0.08), radius: 24, y: 14)
        .animation(.easeInOut(duration: 0.2), value: viewModel?.canSave ?? false)
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
