import Foundation
import SwiftData

/// 成长轨迹 ViewModel
@Observable
final class GrowthTrajectoryViewModel {
    var predictions: [PredictionItem] = []
    var profile: UserProfile?
    var longTermMemory: LongTermMemory?

    struct PredictionItem: Identifiable {
        let id = UUID()
        let date: Date
        let prediction: String
        let diaryTitle: String

        var dateString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            return formatter.string(from: date)
        }
    }

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadData() {
        // 加载画像
        let profileDesc = FetchDescriptor<UserProfile>()
        profile = try? modelContext.fetch(profileDesc).first

        // 加载长期记忆
        let memoryDesc = FetchDescriptor<LongTermMemory>(
            sortBy: [SortDescriptor(\.version, order: .reverse)]
        )
        longTermMemory = try? modelContext.fetch(memoryDesc).first

        // 加载有 goalPrediction 的日记
        let diaryDesc = FetchDescriptor<AIDiary>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        if let diaries = try? modelContext.fetch(diaryDesc) {
            predictions = diaries
                .filter { ($0.goalPrediction?.isEmpty == false) }
                .map { diary in
                    PredictionItem(
                        date: diary.date,
                        prediction: diary.goalPrediction!,
                        diaryTitle: diary.title
                    )
                }
        }
    }
}
