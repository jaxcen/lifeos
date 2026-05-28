import SwiftUI
import SwiftData

@main
struct LifeOSApp: App {
    @State private var appDI = AppDI.mimo(
        baseURL: "https://api.xiaomimimo.com/v1",
        apiKey: "sk-cyu8ku2bgaw2sycg9sdo88ta82arjgzqy153heubb17pqtil"
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
