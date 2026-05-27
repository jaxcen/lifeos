import Foundation
import SwiftData

/// 引导页步骤
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case name
    case idealSelf
    case values
    case goals
    case complete

    var title: String {
        switch self {
        case .welcome: return "人生答案之书"
        case .name: return "你是谁"
        case .idealSelf: return "你想成为谁"
        case .values: return "什么对你重要"
        case .goals: return "你现在想要什么"
        case .complete: return "准备好了"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome: return "一个根据「你是谁」和「你想成为谁」\n生成的个人成长老黄历"
        case .name: return "先让我认识你"
        case .idealSelf: return "描述一下你理想中的自己\n不用完美，真实就好"
        case .values: return "选 2-3 个你最在意的词"
        case .goals: return "最近你最想实现的事"
        case .complete: return "从明天开始\n我会每天为你生成专属的\n人生老黄历"
        }
    }
}

/// 引导页 ViewModel
@Observable
final class OnboardingViewModel {
    var currentStep: OnboardingStep = .welcome
    var name = ""
    var idealSelf = ""
    var selectedValues: Set<String> = []
    var currentGoal = ""

    let valueOptions = [
        "自由", "创造", "连接", "成长", "安全",
        "真实", "平衡", "影响力", "独立", "爱",
        "探索", "稳定", "意义", "快乐", "智慧"
    ]

    var canProceed: Bool {
        switch currentStep {
        case .welcome: return true
        case .name: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case .idealSelf: return !idealSelf.trimmingCharacters(in: .whitespaces).isEmpty
        case .values: return selectedValues.count >= 2
        case .goals: return !currentGoal.trimmingCharacters(in: .whitespaces).isEmpty
        case .complete: return true
        }
    }

    func nextStep() {
        guard canProceed,
              let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = next
    }

    func previousStep() {
        guard let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prev
    }

    func toggleValue(_ value: String) {
        if selectedValues.contains(value) {
            selectedValues.remove(value)
        } else if selectedValues.count < 3 {
            selectedValues.insert(value)
        }
    }

    func saveProfile(modelContext: ModelContext) {
        let profile = UserProfile(
            name: name,
            idealSelfDescription: idealSelf,
            coreValues: Array(selectedValues),
            currentGoals: [currentGoal]
        )
        modelContext.insert(profile)
    }
}
