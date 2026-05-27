import SwiftUI
import SwiftData

/// 画像设置页 - 复用 OnboardingView 的步骤结构
struct ProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = OnboardingViewModel()

    let existingProfile: UserProfile?

    var body: some View {
        VStack(spacing: 0) {
            // 进度条
            progressBar

            // 内容
            TabView(selection: Binding(
                get: { viewModel.currentStep },
                set: { _ in }
            )) {
                nameStep.tag(OnboardingStep.name)
                idealSelfStep.tag(OnboardingStep.idealSelf)
                valuesStep.tag(OnboardingStep.values)
                goalsStep.tag(OnboardingStep.goals)
                completeStep.tag(OnboardingStep.complete)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentStep)

            // 底部按钮
            bottomButtons
        }
        .background(Color.lifeBackground)
        .navigationTitle("设置画像")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            prefillFromProfile()
            // 跳过 welcome 步骤
            if viewModel.currentStep == .welcome {
                viewModel.currentStep = .name
            }
        }
    }

    // MARK: - 预填充

    private func prefillFromProfile() {
        guard let profile = existingProfile else { return }
        viewModel.name = profile.name
        viewModel.idealSelf = profile.idealSelfDescription
        viewModel.selectedValues = Set(profile.coreValues)
        viewModel.currentGoal = profile.currentGoals.first ?? ""
    }

    // MARK: - 进度条

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.lifeAccent.opacity(0.15))

                Rectangle()
                    .fill(Color.lifeAccent)
                    .frame(width: geo.size.width * progress)
                    .animation(.easeInOut, value: viewModel.currentStep)
            }
        }
        .frame(height: 3)
    }

    private var progress: CGFloat {
        let steps = OnboardingStep.allCases.count - 1 // exclude welcome
        let current = max(0, viewModel.currentStep.rawValue - 1)
        return CGFloat(current + 1) / CGFloat(steps)
    }

    // MARK: - 名字

    private var nameStep: some View {
        stepContainer {
            VStack(spacing: Layout.spacingXL) {
                stepHeader(title: "你是谁", subtitle: "让我认识你")

                TextField("你的名字", text: $viewModel.name)
                    .font(.lifeTitle)
                    .foregroundStyle(Color.lifeText)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, Layout.spacingL)
                    .background(Color.lifeCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))

                Text("这会是 AI 认识你的第一步")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
            }
        }
    }

    // MARK: - 理想自我

    private var idealSelfStep: some View {
        stepContainer {
            VStack(spacing: Layout.spacingXL) {
                stepHeader(title: "你想成为谁", subtitle: "描述一下你理想中的自己\n不用完美，真实就好")

                TextEditor(text: $viewModel.idealSelf)
                    .font(.lifeBody)
                    .foregroundStyle(Color.lifeText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(Layout.spacingM)
                    .background(Color.lifeCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
                    .overlay(alignment: .topLeading) {
                        if viewModel.idealSelf.isEmpty {
                            Text("比如：一个更勇敢的人，一个能坚持写完一本书的人...")
                                .font(.lifeBody)
                                .foregroundStyle(Color.lifeTextSecondary.opacity(0.5))
                                .padding(.top, 10)
                                .padding(.leading, 10)
                                .allowsHitTesting(false)
                        }
                    }

                Text("这会帮助 AI 理解你想去的方向。")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - 价值观

    private var valuesStep: some View {
        stepContainer {
            VStack(spacing: Layout.spacingXL) {
                stepHeader(title: "什么对你重要", subtitle: "选 2-3 个你最在意的词")

                TagCloudLayout(
                    tags: viewModel.valueOptions,
                    selectedTags: viewModel.selectedValues,
                    spacing: Layout.spacingM
                ) { value in
                    viewModel.toggleValue(value)
                }

                Text("已选 \(viewModel.selectedValues.count)/3")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
            }
        }
    }

    // MARK: - 目标

    private var goalsStep: some View {
        stepContainer {
            VStack(spacing: Layout.spacingXL) {
                stepHeader(title: "你现在想要什么", subtitle: "最近你最想实现的事")

                TextEditor(text: $viewModel.currentGoal)
                    .font(.lifeBody)
                    .foregroundStyle(Color.lifeText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100)
                    .padding(Layout.spacingM)
                    .background(Color.lifeCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
                    .overlay(alignment: .topLeading) {
                        if viewModel.currentGoal.isEmpty {
                            Text("比如：完成毕业设计、找到新方向、养成运动习惯...")
                                .font(.lifeBody)
                                .foregroundStyle(Color.lifeTextSecondary.opacity(0.5))
                                .padding(.top, 10)
                                .padding(.leading, 10)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
    }

    // MARK: - 完成

    private var completeStep: some View {
        VStack(spacing: Layout.spacingXXL) {
            Spacer()

            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color.lifeAccent)
                .symbolEffect(.pulse)

            Text("画像已更新")
                .font(.lifeDisplay)
                .foregroundStyle(Color.lifeText)

            Text("AI 会基于你的画像\n为你生成更贴合的日记和预测")
                .font(.lifeBody)
                .foregroundStyle(Color.lifeTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, Layout.spacingXXL)
    }

    // MARK: - 通用

    private func stepContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack {
            Spacer()
            content()
                .padding(.horizontal, Layout.spacingXXL)
            Spacer()
            Spacer()
        }
    }

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(spacing: Layout.spacingS) {
            Text(title)
                .font(.lifeTitle)
                .foregroundStyle(Color.lifeText)

            Text(subtitle)
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - 底部按钮

    private var bottomButtons: some View {
        HStack {
            if viewModel.currentStep.rawValue > 1 && viewModel.currentStep != .complete {
                Button("上一步") {
                    viewModel.previousStep()
                }
                .font(.lifeBody)
                .foregroundStyle(Color.lifeTextSecondary)
            }

            Spacer()

            if viewModel.currentStep == .complete {
                Button("保存") {
                    saveProfile()
                    dismiss()
                }
                .buttonStyle(.lifePill)
            } else {
                Button("下一步") {
                    viewModel.nextStep()
                }
                .buttonStyle(.lifePill)
                .disabled(!viewModel.canProceed)
                .opacity(viewModel.canProceed ? 1 : 0.5)
            }
        }
        .padding(.horizontal, Layout.spacingXXL)
        .padding(.vertical, Layout.spacingL)
    }

    // MARK: - 保存

    private func saveProfile() {
        if let profile = existingProfile {
            // 更新已有画像
            profile.name = viewModel.name
            profile.idealSelfDescription = viewModel.idealSelf
            profile.coreValues = Array(viewModel.selectedValues)
            profile.currentGoals = [viewModel.currentGoal]
            profile.updatedAt = Date()
        } else {
            // 创建新画像
            let profile = UserProfile(
                name: viewModel.name,
                idealSelfDescription: viewModel.idealSelf,
                coreValues: Array(viewModel.selectedValues),
                currentGoals: [viewModel.currentGoal]
            )
            modelContext.insert(profile)
        }
    }
}
