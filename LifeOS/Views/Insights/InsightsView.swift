import SwiftUI
import SwiftData

/// 洞察页 - 日记/老黄历/预测
struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDI) private var di
    @State private var viewModel: HomeViewModel?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.spacingL) {
                    // 日期头
                    DateHeaderView(
                        date: viewModel?.todayDateString ?? "",
                        weekday: viewModel?.todayWeekday ?? ""
                    )

                    // 侧写日记（优先展示）
                    diarySection

                    // 老黄历
                    almanacSection

                    // 明日推演
                    forecastSection
                }
                .padding(.horizontal, Layout.spacingL)
                .padding(.bottom, Layout.spacingXXL)
            }
            .background(Color.lifeBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: Binding(
                get: { viewModel?.showDiarySheet ?? false },
                set: { viewModel?.showDiarySheet = $0 }
            )) {
                if let diary = viewModel?.todayDiary {
                    DiaryDetailView(diary: diary)
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showForecastSheet ?? false },
                set: { viewModel?.showForecastSheet = $0 }
            )) {
                if let forecast = viewModel?.tomorrowForecast {
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

    // MARK: - 侧写日记

    @ViewBuilder
    private var diarySection: some View {
        if let diary = viewModel?.todayDiary {
            DiaryCard(diary: diary)
        } else if hasEntriesToday {
            Button {
                Task { await viewModel?.generateDiary() }
            } label: {
                HStack(spacing: Layout.spacingS) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 14))
                    Text("生成今日侧写日记")
                        .font(.lifeBodyEmphasis)
                }
                .foregroundStyle(Color.lifeAccent)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.lifeAccent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
            }
        } else {
            EmptyStateView(
                icon: "doc.text",
                title: "还没有今日记录",
                subtitle: "去记录页写下今天的想法，\nAI 就能为你生成侧写日记"
            )
        }
    }

    // MARK: - 老黄历

    @ViewBuilder
    private var almanacSection: some View {
        if let vm = viewModel {
            switch vm.loadingState {
            case .loading(let msg):
                AIGeneratingView(message: msg)
            default:
                if let almanac = vm.todayAlmanac {
                    AlmanacCard(almanac: almanac)
                } else if hasEntriesToday {
                    Button {
                        Task { await vm.generateAlmanac() }
                    } label: {
                        HStack(spacing: Layout.spacingS) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                            Text("生成今日老黄历")
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
        }
    }

    // MARK: - 明日推演

    @ViewBuilder
    private var forecastSection: some View {
        if let forecast = viewModel?.tomorrowForecast {
            ForecastCard(forecast: forecast)
        } else if viewModel?.todayAlmanac != nil {
            Button {
                Task { await viewModel?.generateForecast() }
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

    // MARK: - 辅助

    private var hasEntriesToday: Bool {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return (try? modelContext.fetch(descriptor).first) != nil
    }
}
