import SwiftUI
import SwiftData

/// 成长轨迹页 - 展示历史预测与目标对比
struct GrowthTrajectoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: GrowthTrajectoryViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.spacingXL) {
                // 目标卡片
                if let profile = viewModel?.profile, profile.isProfileComplete {
                    goalCard(profile)
                }

                // 长期观察
                if let memory = viewModel?.longTermMemory, !memory.personalitySummary.isEmpty {
                    memoryCard(memory)
                }

                // 预测时间线
                timelineSection
            }
            .padding(Layout.spacingL)
        }
        .background(Color.lifeBackground)
        .navigationTitle("成长轨迹")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = GrowthTrajectoryViewModel(modelContext: modelContext)
            }
            viewModel?.loadData()
        }
    }

    // MARK: - 目标卡片

    private func goalCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(Color.lifeAccent)
                Text("想成为的自己")
                    .font(.lifeHeadline)
                    .foregroundStyle(Color.lifeText)
            }

            Text(profile.idealSelfDescription)
                .font(.lifeBody)
                .foregroundStyle(Color.lifeText)
                .lineSpacing(6)

            if !profile.currentGoals.isEmpty {
                VStack(alignment: .leading, spacing: Layout.spacingXS) {
                    Text("当前目标")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)
                    ForEach(profile.currentGoals, id: \.self) { goal in
                        Text(goal)
                            .font(.lifeCaption)
                            .foregroundStyle(Color.lifeText)
                    }
                }
            }
        }
        .lifeCard()
    }

    // MARK: - 长期观察

    private func memoryCard(_ memory: LongTermMemory) -> some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            HStack {
                Image(systemName: "brain")
                    .foregroundStyle(Color.lifeAccent)
                Text("AI 的长期观察")
                    .font(.lifeHeadline)
                    .foregroundStyle(Color.lifeText)
            }

            Text(memory.personalitySummary)
                .font(.lifeBody)
                .foregroundStyle(Color.lifeText)
                .lineSpacing(6)

            if !memory.strengthsObserved.isEmpty {
                VStack(alignment: .leading, spacing: Layout.spacingXS) {
                    Text("观察到的优势")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)
                    HStack(spacing: Layout.spacingS) {
                        ForEach(memory.strengthsObserved, id: \.self) { strength in
                            Text(strength)
                                .font(.lifeTag)
                                .foregroundStyle(Color.lifeYi)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.lifeYi.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            if !memory.growthAreas.isEmpty {
                VStack(alignment: .leading, spacing: Layout.spacingXS) {
                    Text("成长领域")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)
                    HStack(spacing: Layout.spacingS) {
                        ForEach(memory.growthAreas, id: \.self) { area in
                            Text(area)
                                .font(.lifeTag)
                                .foregroundStyle(Color.lifeJi)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.lifeJi.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .lifeCard()
    }

    // MARK: - 时间线

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(Color.lifeYi)
                Text("成长轨迹")
                    .font(.lifeHeadline)
                    .foregroundStyle(Color.lifeText)
            }

            if viewModel?.predictions.isEmpty ?? true {
                VStack(spacing: Layout.spacingL) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.lifeAccent.opacity(0.5))
                    Text("还没有成长轨迹数据")
                        .font(.lifeBody)
                        .foregroundStyle(Color.lifeTextSecondary)
                    Text("多记录几天，AI 会观察你朝目标前进的轨迹")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Layout.spacingXXL)
            } else {
                ForEach(viewModel?.predictions ?? []) { item in
                    predictionRow(item)
                }
            }
        }
        .lifeCard()
    }

    private func predictionRow(_ item: GrowthTrajectoryViewModel.PredictionItem) -> some View {
        HStack(alignment: .top, spacing: Layout.spacingL) {
            // 时间线标记
            VStack(spacing: Layout.spacingXS) {
                Circle()
                    .fill(Color.lifeYi)
                    .frame(width: 10, height: 10)

                Rectangle()
                    .fill(Color.lifeYi.opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 10)

            // 内容
            VStack(alignment: .leading, spacing: Layout.spacingXS) {
                Text(item.dateString)
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)

                Text(item.diaryTitle)
                    .font(.lifeBodyEmphasis)
                    .foregroundStyle(Color.lifeText)

                Text(item.prediction)
                    .font(.lifeBody)
                    .foregroundStyle(Color.lifeYi)
                    .lineSpacing(4)
            }
        }
    }
}
