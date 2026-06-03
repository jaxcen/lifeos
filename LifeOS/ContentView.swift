import SwiftUI
import SwiftData

/// 根视图 - Tab 导航
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDI) private var appDI

    var body: some View {
        TabView {
            MainRecordView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }

            InsightsView()
                .tabItem {
                    Label("洞察", systemImage: "chart.line.uptrend.xyaxis")
                }

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
        .tint(Color.lifeAccent)
        .tabBarMinimizeBehavior(.automatic)
    }
}

#Preview {
    ContentView()
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
