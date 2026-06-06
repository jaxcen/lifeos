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

/// 新首页 - 记录页
struct MainRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDI) private var di
    @Query(sort: \DailyEntry.createdAt, order: .reverse) private var allEntries: [DailyEntry]
    let resetSignal: Int

    @State private var viewModel: MainRecordViewModel?
    @State private var showPostRecord = false
    @State private var aiService: AIGenerationService?
    @State private var showForecastFlow = false
    @State private var isForecasting = false
    @State private var isForecastProgressComplete = false
    @State private var forecastErrorMessage: String?
    @State private var isRecordPanelExpanded = false

    init(resetSignal: Int = 0) {
        self.resetSignal = resetSignal
    }

    var body: some View {
        NavigationStack {
            ZStack {
                homeBackground

                if isRecordPanelExpanded {
                    VStack(spacing: 16) {
                        homeHeader
                        expandedRecordPanel
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            homeHeader
                            mascotHero
                            recordingMethodStage
                            collapsedQuickInput
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        .padding(.bottom, 104)
                    }
                }
            }
            .navigationBarHidden(true)
            .toolbar(isRecordPanelExpanded ? .hidden : .visible, for: .tabBar)
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
            .fullScreenCover(isPresented: $showForecastFlow) {
                forecastFlow
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
                        ensureAIService()
                        showPostRecord = true
                    }
                    viewModel = vm
                }
                ensureAIService()
                aiService?.loadTodayData()
            }
            .onChange(of: resetSignal) { _, _ in
                withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                    isRecordPanelExpanded = false
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

                    tomorrowCrystalButton(compact: compact)
                        .padding(.top, compact ? 2 : 8)
                }

                Text(compact ? "继续记录此刻" : "记录今天，预测明天")
                    .font(.system(size: compact ? 16 : 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.lifeTextSecondary)
                    .padding(.top, compact ? 0 : 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: compact ? 96 : 138)
    }

    private func tomorrowCrystalButton(compact: Bool) -> some View {
        Button {
            startTomorrowForecast()
        } label: {
            HStack(spacing: compact ? 0 : 9) {
                CrystalBallIcon(size: compact ? 38 : 36)
                    .padding(.leading, compact ? 0 : 1)

                if !compact {
                    Text("预测明天")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.lifeAccent)
                }
            }
            .padding(.leading, compact ? 0 : 10)
            .padding(.trailing, compact ? 0 : 16)
            .frame(width: compact ? 58 : 150, height: 58)
            .glassEffect(.regular, in: Capsule())
            .shadow(color: Color.lifeAccent.opacity(0.12), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var mascotHero: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 12) {
                Label("\(todayEntryCount) 条记录", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.lifeText)

                Text(todayEntryCount == 0 ? "留下第一条线索" : "记录越完整，明天的预测越清晰")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.lifeTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 5) {
                    ForEach(0..<5, id: \.self) { index in
                        Capsule()
                            .fill(index < predictionSignalLevel ? Color.lifeAccent : Color.lifeAccent.opacity(0.12))
                            .frame(width: 17, height: 6)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)

            ZStack(alignment: .bottom) {
                Circle()
                    .trim(from: 0, to: 0.5)
                    .fill(Color.lifeSoftPeach.opacity(0.78))
                    .frame(width: 238, height: 238)
                    .rotationEffect(.degrees(180))
                    .offset(y: 68)
                    .blur(radius: 0.4)

                MascotVideoView()
                    .frame(width: 218, height: 218)
                    .offset(y: 20)
            }
            .frame(width: 230, height: 178)
            .clipped()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 178)
    }

    private var todayEntryCount: Int {
        allEntries.filter { Calendar.current.isDateInToday($0.date) }.count
    }

    private var predictionSignalLevel: Int {
        min(5, todayEntryCount)
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

    private var recordingMethodStage: some View {
        HStack(spacing: 10) {
            ForEach(RecordingMethod.allCases, id: \.self) { method in
                modeDomeButton(method)
            }
        }
        .frame(height: 94)
    }

    private func modeDomeButton(_ method: RecordingMethod) -> some View {
        let isSelected = (viewModel?.selectedMethod ?? .text) == method
        let visual = methodVisual(method)

        return Button {
            selectMethod(method)
        } label: {
            VStack(spacing: 7) {
                Image(systemName: method == .text ? "textformat" : visual.icon)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(isSelected ? .white : visual.color)
                    .frame(width: 48, height: 48)
                    .background(
                        isSelected ? visual.color : visual.color.opacity(0.13),
                        in: Circle()
                    )

                Text(method.rawValue)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.lifeText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: visual.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(isSelected ? 0.92 : 0.68)
            )
            .shadow(color: visual.color.opacity(isSelected ? 0.14 : 0.05), radius: 12, y: 7)
            .scaleEffect(isSelected ? 1.015 : 0.98)
        }
        .buttonStyle(.plain)
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
            .frame(height: 158)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.82), Color.lifeSoftLavender.opacity(0.34)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 32, style: .continuous)
            )
            .shadow(color: Color.lifeAccent.opacity(0.07), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
    }

    private var expandedRecordPanel: some View {
        let method = viewModel?.selectedMethod ?? .text
        let visual = methodVisual(method)

        return VStack(spacing: 18) {
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

                    Button {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                            isRecordPanelExpanded = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.lifeTextSecondary)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.44), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }

            inputArea
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxHeight: .infinity, alignment: .top)
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
            .frame(minHeight: 170, maxHeight: .infinity)
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
        .frame(maxHeight: .infinity, alignment: .top)
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
        .animation(.easeInOut(duration: 0.2), value: viewModel?.canSave ?? false)
    }

    // MARK: - 明日预测

    @ViewBuilder
    private var forecastFlow: some View {
        ZStack(alignment: .topTrailing) {
            if isForecasting {
                PredictionProgressView(
                    title: "正在预测明天",
                    subtitle: "把今天的记录换算成明天的节奏",
                    isComplete: isForecastProgressComplete
                )
            } else if let forecast = aiService?.currentForecast {
                ForecastDetailView(forecast: forecast)
            } else if let message = forecastErrorMessage {
                forecastErrorView(message)
            } else {
                PredictionProgressView(
                    title: "正在预测明天",
                    isComplete: isForecastProgressComplete
                )
            }

            if isForecasting || forecastErrorMessage != nil {
                Button {
                    showForecastFlow = false
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
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func forecastErrorView(_ message: String) -> some View {
        VStack(spacing: 18) {
            Spacer()

            CrystalBallIcon(size: 54)

            Text("预测暂时中断")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.lifeText)

            Text(message)
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 26)

            Button("重新预测") {
                startTomorrowForecast(force: true)
            }
            .buttonStyle(.lifePill)

            Spacer()
        }
        .padding(24)
    }

    private func ensureAIService() {
        if aiService == nil {
            aiService = AIGenerationService(
                aiService: di.aiService,
                modelContext: modelContext
            )
        }
    }

    private func startTomorrowForecast(force: Bool = false) {
        ensureAIService()
        forecastErrorMessage = nil
        isForecastProgressComplete = false
        showForecastFlow = true

        if aiService?.currentForecast != nil, !force {
            isForecasting = false
            return
        }

        isForecasting = true
        Task {
            let startedAt = ContinuousClock.now
            await aiService?.generateForecast()

            let elapsed = startedAt.duration(to: .now)
            let minimumDuration = Duration.seconds(3)
            if elapsed < minimumDuration {
                try? await Task.sleep(for: minimumDuration - elapsed)
            }

            let hasForecast = aiService?.currentForecast != nil
            await MainActor.run {
                if hasForecast {
                    isForecastProgressComplete = true
                } else {
                    isForecasting = false
                    switch aiService?.loadingState {
                    case .error(let message):
                        forecastErrorMessage = message
                    default:
                        forecastErrorMessage = "预测没有完成，请稍后再试"
                    }
                }
            }

            if hasForecast {
                try? await Task.sleep(for: .milliseconds(420))
                await MainActor.run {
                    isForecasting = false
                }
            }
        }
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
