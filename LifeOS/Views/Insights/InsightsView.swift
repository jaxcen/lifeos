import SwiftUI
import SwiftData

/// 显示模式
enum DisplayMode: String, CaseIterable {
    case card
    case bookshelf

    var icon: String {
        switch self {
        case .card: return "square.grid.2x2"
        case .bookshelf: return "books.vertical"
        }
    }
}

/// 洞察页 - 和紙手帳風
struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDI) private var di
    @State private var viewModel: HomeViewModel?
    @State private var showDatePicker = false
    @State private var pickerDate = Date()
    @State private var displayMode: DisplayMode = .card

    var body: some View {
        NavigationStack {
            ZStack {
                if displayMode == .card {
                    PaperBackground()
                }

                if let vm = viewModel {
                    VStack(spacing: 0) {
                        // 顶部标题
                        headerSection(vm)

                        // 日期气泡条（仅卡片模式）
                        if displayMode == .card {
                            DateBubbleStrip(
                                dates: vm.visibleDates,
                                selectedIndex: Binding(
                                    get: { vm.selectedIndex },
                                    set: { vm.navigateToIndex($0) }
                                )
                            ) { index in
                                vm.navigateToIndex(index)
                            }
                            .padding(.horizontal, Layout.spacingL)
                            .padding(.vertical, Layout.spacingS)
                            .onLongPressGesture {
                                pickerDate = vm.selectedDate
                                showDatePicker = true
                            }
                        }

                        // 内容区
                        if displayMode == .card {
                            ScrollView {
                                InsightsDayPage(
                                    date: vm.selectedDate,
                                    viewModel: vm
                                )
                                .padding(.horizontal, Layout.spacingL)
                                .padding(.bottom, Layout.spacingXL)
                            }
                        } else {
                            BookshelfView(modelContext: modelContext)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
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
            .sheet(isPresented: $showDatePicker) {
                NavigationStack {
                    DatePicker("选择日期", selection: $pickerDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                        .navigationTitle("跳转到日期")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("确定") {
                                    viewModel?.navigateToDate(pickerDate)
                                    showDatePicker = false
                                }
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("取消") {
                                    showDatePicker = false
                                }
                            }
                        }
                }
                .presentationDetents([.medium])
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

    // MARK: - 顶部标题

    @ViewBuilder
    private func headerSection(_ vm: HomeViewModel) -> some View {
        VStack(spacing: Layout.spacingS) {
            // 模式切换
            HStack(spacing: Layout.spacingS) {
                ForEach(DisplayMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            displayMode = mode
                        }
                    } label: {
                        Image(systemName: mode.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(displayMode == mode ? Color.lifeAccent : Color.lifeTextSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                displayMode == mode
                                    ? Color.lifeAccent.opacity(0.1)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusS))
                    }
                }
            }

            // 标题
            Text(displayMode == .card ? "今日手账" : "人生书架")
                .font(.lifeTitle)
                .foregroundStyle(Color.lifeText)
        }
        .padding(.top, Layout.spacingL)
        .padding(.bottom, Layout.spacingM)
    }
}

// MARK: - 单日页面

struct InsightsDayPage: View {
    let date: Date
    let viewModel: HomeViewModel

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var isFuture: Bool {
        date > Date()
    }

    var body: some View {
        VStack(spacing: Layout.spacingL) {
            // 锦囊卡片
            tipsSection

            // 和纸条分隔
            WashiTapeDivider(color: .washiBlue)

            // 观察日记
            diarySection

            // 和纸条分隔
            WashiTapeDivider(color: .washiRose)

            // 明日推演
            forecastSection
        }
        .padding(.horizontal, Layout.spacingS)
        .padding(.vertical, Layout.spacingL)
        .onAppear {
            viewModel.loadData(for: date)
        }
    }

    // MARK: - 锦囊

    @ViewBuilder
    private var tipsSection: some View {
        if isFuture {
            futurePlaceholder(
                icon: "sunrise",
                message: "明天还没有到来"
            )
        } else if let almanac = viewModel.currentAlmanac {
            AlmanacCard(almanac: almanac)
        } else if viewModel.hasEntriesForSelectedDate {
            generateButton(
                icon: "sparkles",
                text: isToday ? "生成今日锦囊" : "为这天生成锦囊",
                color: .lifeAccent
            ) {
                Task { await viewModel.generateAlmanac() }
            }
        } else if isToday {
            emptyTodayPlaceholder
        } else {
            emptyPastPlaceholder
        }
    }

    // MARK: - 观察日记

    @ViewBuilder
    private var diarySection: some View {
        if !isFuture {
            if !viewModel.currentDiaries.isEmpty {
                ForEach(viewModel.currentDiaries, id: \.id) { diary in
                    DiaryCard(diary: diary)
                        .onTapGesture {
                            viewModel.selectedDiary = diary
                            viewModel.showDiarySheet = true
                        }
                }
            } else if viewModel.currentAlmanac != nil && viewModel.hasEntriesForSelectedDate {
                generateButton(
                    icon: "doc.text",
                    text: isToday ? "生成观察日记" : "为这天生成日记",
                    color: .lifeAccent
                ) {
                    Task { await viewModel.generateDiary() }
                }
            }
        }
    }

    // MARK: - 明日推演

    @ViewBuilder
    private var forecastSection: some View {
        if !isFuture {
            if let forecast = viewModel.currentForecast {
                ForecastCard(forecast: forecast)
            } else if viewModel.currentAlmanac != nil {
                generateButton(
                    icon: "sunrise",
                    text: "推演明天",
                    color: .lifeJi
                ) {
                    Task { await viewModel.generateForecast() }
                }
            }
        }
    }

    // MARK: - 空状态

    private var emptyTodayPlaceholder: some View {
        VStack(spacing: Layout.spacingL) {
            ZStack {
                Circle()
                    .fill(Color.lifeAccent.opacity(0.1))
                    .frame(width: 64, height: 64)
                Image(systemName: "book.closed")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.lifeAccent)
            }

            Text("今天的页面还是空白的")
                .font(.lifeBody)
                .foregroundStyle(Color.lifeTextSecondary)

            Text("去记录页写下今天的想法")
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.spacingXXL)
        .paperCard()
    }

    private var emptyPastPlaceholder: some View {
        VStack(spacing: Layout.spacingL) {
            ZStack {
                Circle()
                    .fill(Color.lifeTextSecondary.opacity(0.1))
                    .frame(width: 64, height: 64)
                Image(systemName: "calendar")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.lifeTextSecondary)
            }

            Text("这一天没有留下记录")
                .font(.lifeBody)
                .foregroundStyle(Color.lifeTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.spacingXXL)
        .paperCard()
    }

    private func futurePlaceholder(icon: String, message: String) -> some View {
        VStack(spacing: Layout.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(Color.lifeAccent.opacity(0.5))
            Text(message)
                .font(.lifeBody)
                .foregroundStyle(Color.lifeTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.spacingXXL)
        .paperCard()
    }

    // MARK: - 生成按钮

    private func generateButton(
        icon: String,
        text: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Layout.spacingS) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(text)
                    .font(.lifeBodyEmphasis)
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
        }
        .paperCard(padding: 0)
    }
}

#Preview {
    InsightsView()
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
