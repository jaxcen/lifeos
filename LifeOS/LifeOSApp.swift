import SwiftUI
import SwiftData

@main
struct LifeOSApp: App {
    @State private var appDI = AppDI.mimo(
        baseURL: "https://token-plan-cn.xiaomimimo.com/v1",
        apiKey: "tp-cyptg888u3npqv27z6aec3cw421ydf0rd8l863xi8ff01o6f"
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appDI, appDI)
                .modelContainer(for: [
                    UserProfile.self,
                    DailyEntry.self,
                    DailyQuestionnaire.self,
                    DailyAlmanac.self,
                    AIDiary.self,
                    TomorrowForecast.self,
                    LongTermMemory.self,
                    WeeklyAnalysis.self,
                    CalendarEventSnapshot.self
                ])
                .tint(Color.lifeAccent)
        }
    }
}
