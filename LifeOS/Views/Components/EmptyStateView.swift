import SwiftUI

/// 空状态视图
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Layout.spacingL) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(Color.lifeAccent.opacity(0.5))

            Text(title)
                .font(.lifeHeadline)
                .foregroundStyle(Color.lifeText)

            Text(subtitle)
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.lifePill)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.spacingXXL)
        .lifeCard()
    }
}

#Preview {
    EmptyStateView(
        icon: "sparkles",
        title: "今日老黄历还未生成",
        subtitle: "记录一点今天的想法，\nAI 就能为你生成专属的今日宜忌",
        actionTitle: "开始记录"
    ) {}
    .padding()
    .background(Color.lifeBackground)
}
