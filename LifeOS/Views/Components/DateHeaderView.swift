import SwiftUI

/// 日期头部 - 今日日期展示
struct DateHeaderView: View {
    let date: String
    let weekday: String

    var body: some View {
        VStack(spacing: Layout.spacingXS) {
            Text(date)
                .font(.lifeDisplay)
                .foregroundStyle(Color.lifeText)

            Text(weekday)
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.spacingL)
    }
}

#Preview {
    DateHeaderView(date: "5月23日", weekday: "星期五")
        .background(Color.lifeBackground)
}
