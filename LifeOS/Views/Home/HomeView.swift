import SwiftUI
import SwiftData

/// 首页
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDI) private var di
    @State private var viewModel: HomeViewModel?
    @State private var showRecord = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.spacingL) {
                    // 日期头
                    DateHeaderView(
                        date: viewModel?.selectedDateString ?? "",
                        weekday: viewModel?.selectedWeekday ?? ""
                    )

                    // 老黄历
                    almanacSection

                    // 今日记录入口
                    recordEntryButton

                    // 观察日记
                    diarySection

                    // 明日推演
                    forecastSection
                }
                .padding(.horizontal, Layout.spacingL)
                .padding(.bottom, Layout.spacingXXL)
            }
            .background(Color.lifeBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $showRecord) {
                RecordView()
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showDiarySheet ?? false },
                set: { viewModel?.showDiarySheet = $0 }
            )) {
                if let diary = viewModel?.selectedDiary {
                    DiaryDetailView(diary: diary)
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showForecastSheet ?? false },
                set: { viewModel?.showForecastSheet = $0 }
            )) {
                if let forecast = viewModel?.currentForecast {
                    ForecastDetailView(forecast: forecast)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = HomeViewModel(
                        aiService: di.aiService,
                        modelContext: modelContext
                    )
                }
                viewModel?.loadTodayData()
            }
        }
    }

    // MARK: - 老黄历区域

    @ViewBuilder
    private var almanacSection: some View {
        if let vm = viewModel {
            switch vm.loadingState {
            case .loading(let msg):
                AIGeneratingView(message: msg)
            default:
                if let almanac = vm.currentAlmanac {
                    AlmanacCard(almanac: almanac)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    EmptyStateView(
                        icon: "sparkles",
                        title: "今日老黄历还未生成",
                        subtitle: "记录一点今天的想法，\nAI 就能为你生成专属的今日宜忌",
                        actionTitle: "生成今日老黄历"
                    ) {
                        Task {
                            await vm.generateAlmanac()
                        }
                    }
                }
            }
        }
    }

    // MARK: - 记录入口

    private var recordEntryButton: some View {
        Button {
            showRecord = true
        } label: {
            HStack(spacing: Layout.spacingM) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 18))
                Text("写下此刻的想法...")
                    .font(.lifeBody)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
            }
            .foregroundStyle(Color.lifeTextSecondary)
            .padding()
            .background(Color.lifeCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
            .shadow(color: .black.opacity(0.03), radius: 4, y: 1)
        }
    }

    // MARK: - 观察日记区域

    @ViewBuilder
    private var diarySection: some View {
        if let vm = viewModel, !vm.currentDiaries.isEmpty {
            ForEach(vm.currentDiaries, id: \.id) { diary in
                DiaryCard(diary: diary)
                    .onTapGesture {
                        vm.selectedDiary = diary
                        vm.showDiarySheet = true
                    }
            }
        } else if viewModel?.currentAlmanac != nil {
            Button {
                Task {
                    await viewModel?.generateDiary()
                }
            } label: {
                HStack(spacing: Layout.spacingS) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 14))
                    Text("生成今日观察日记")
                        .font(.lifeBodyEmphasis)
                }
                .foregroundStyle(Color.lifeAccent)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.lifeAccent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
            }
        }
    }

    // MARK: - 明日推演区域

    @ViewBuilder
    private var forecastSection: some View {
        if let forecast = viewModel?.currentForecast {
            ForecastCard(forecast: forecast)
        } else if viewModel?.currentAlmanac != nil {
            Button {
                Task {
                    await viewModel?.generateForecast()
                }
            } label: {
                HStack(spacing: Layout.spacingS) {
                    Image(systemName: "sunrise")
                        .font(.system(size: 14))
                    Text("推演明天")
                        .font(.lifeBodyEmphasis)
                }
                .foregroundStyle(Color.lifeJi)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.lifeJi.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [
            UserProfile.self,
            DailyEntry.self,
            DailyQuestionnaire.self,
            DailyAlmanac.self,
            AIDiary.self,
            TomorrowForecast.self,
            LongTermMemory.self,
            WeeklyAnalysis.self
        ], inMemory: true)
}
