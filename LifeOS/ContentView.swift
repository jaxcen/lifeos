import SwiftUI
import SwiftData

/// 根视图 - Tab 导航
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDI) private var appDI
    @State private var selectedTab: AppTab = .record
    @State private var homeResetSignal = 0

    var body: some View {
        TabView(selection: Binding(
            get: { selectedTab },
            set: { newValue in
                if selectedTab == .record && newValue == .record {
                    homeResetSignal += 1
                }
                selectedTab = newValue
            }
        )) {
            MainRecordView(resetSignal: homeResetSignal)
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(AppTab.record)

            InsightsView()
                .tabItem {
                    Image("TabCrystalBall")
                    Text("洞察")
                }
                .tag(AppTab.insights)

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(AppTab.profile)
        }
        .tint(Color.lifeAccent)
        .tabBarMinimizeBehavior(.automatic)
    }
}

private enum AppTab: Hashable {
    case record
    case insights
    case profile
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
