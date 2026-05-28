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
                    Label("记录", systemImage: "mic.fill")
                }

            InsightsView()
                .tabItem {
                    Label("洞察", systemImage: "book.closed")
                }

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.circle")
                }
        }
        .tint(Color.lifeAccent)
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
