import SwiftUI
import SwiftData

/// 引导页
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // 进度条
            progressBar

            // 内容
            TabView(selection: Binding(
                get: { viewModel.currentStep },
                set: { _ in }
            )) {
                welcomeStep.tag(OnboardingStep.welcome)
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
        CGFloat(viewModel.currentStep.rawValue + 1) / CGFloat(OnboardingStep.allCases.count)
    }

    // MARK: - 欢迎

    private var welcomeStep: some View {
        VStack(spacing: Layout.spacingXXL) {
            Spacer()

            // 图标
            Image(systemName: "book.closed")
                .font(.system(size: 64))
                .foregroundStyle(Color.lifeAccent)
                .padding(.bottom, Layout.spacingL)

            Text(viewModel.currentStep.title)
                .font(.lifeDisplay)
                .foregroundStyle(Color.lifeText)

            Text(viewModel.currentStep.subtitle)
                .font(.lifeBody)
                .foregroundStyle(Color.lifeTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, Layout.spacingXXL)
    }

    // MARK: - 名字

    private var nameStep: some View {
        stepContainer {
            VStack(spacing: Layout.spacingXL) {
                stepHeader

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
                stepHeader

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

                Text("不用完美，真实就好。这会帮助 AI 理解你想去的方向。")
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
                stepHeader

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
                stepHeader

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

            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Color.lifeAccent)
                .symbolEffect(.pulse)

            Text(viewModel.currentStep.title)
                .font(.lifeDisplay)
                .foregroundStyle(Color.lifeText)

            Text(viewModel.currentStep.subtitle)
                .font(.lifeBody)
                .foregroundStyle(Color.lifeTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, Layout.spacingXXL)
    }

    // MARK: - 通用步骤容器

    private func stepContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack {
            Spacer()
            content()
                .padding(.horizontal, Layout.spacingXXL)
            Spacer()
            Spacer()
        }
    }

    private var stepHeader: some View {
        VStack(spacing: Layout.spacingS) {
            Text(viewModel.currentStep.title)
                .font(.lifeTitle)
                .foregroundStyle(Color.lifeText)

            Text(viewModel.currentStep.subtitle)
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - 底部按钮

    private var bottomButtons: some View {
        HStack {
            if viewModel.currentStep.rawValue > 0 && viewModel.currentStep != .complete {
                Button("上一步") {
                    viewModel.previousStep()
                }
                .font(.lifeBody)
                .foregroundStyle(Color.lifeTextSecondary)
            }

            Spacer()

            if viewModel.currentStep == .complete {
                Button("开始使用") {
                    viewModel.saveProfile(modelContext: modelContext)
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
}

/// 价值观标签
struct ValueTag: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.lifeBodyEmphasis)
                .foregroundStyle(isSelected ? .white : Color.lifeText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.lifeAccent : Color.lifeCardBackground)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
        }
    }
}

/// 流式标签布局
struct TagCloudLayout: View {
    let tags: [String]
    let selectedTags: Set<String>
    let spacing: CGFloat
    let onTap: (String) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 70), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(tags, id: \.self) { tag in
                ValueTag(
                    title: tag,
                    isSelected: selectedTags.contains(tag)
                ) {
                    onTap(tag)
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
