import SwiftUI

/// 老黄历卡片 - 展示今日宜忌
struct AlmanacCard: View {
    let almanac: DailyAlmanac

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            // 关键词
            HStack {
                Text("今日关键词")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
                Spacer()
            }

            Text(almanac.keyword)
                .font(.lifeDisplay)
                .foregroundStyle(Color.lifeText)

            Divider()
                .padding(.vertical, Layout.spacingXS)

            // 宜忌
            HStack(alignment: .top, spacing: Layout.spacingXL) {
                // 宜
                VStack(alignment: .leading, spacing: Layout.spacingS) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.lifeYi)
                            .frame(width: 8, height: 8)
                        Text("宜")
                            .font(.lifeHeadline)
                            .foregroundStyle(Color.lifeYi)
                    }

                    ForEach(almanac.yiList, id: \.self) { item in
                        Text(item)
                            .font(.lifeAlmanacItem)
                            .foregroundStyle(Color.lifeText)
                            .padding(.vertical, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 忌
                VStack(alignment: .leading, spacing: Layout.spacingS) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.lifeJi)
                            .frame(width: 8, height: 8)
                        Text("忌")
                            .font(.lifeHeadline)
                            .foregroundStyle(Color.lifeJi)
                    }

                    ForEach(almanac.jiList, id: \.self) { item in
                        Text(item)
                            .font(.lifeAlmanacItem)
                            .foregroundStyle(Color.lifeTextSecondary)
                            .padding(.vertical, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 提醒
            if !almanac.reminder.isEmpty {
                Divider()

                HStack(alignment: .top, spacing: Layout.spacingS) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.lifeReminder)
                        .padding(.top, 2)

                    Text(almanac.reminder)
                        .font(.lifeReminder)
                        .foregroundStyle(Color.lifeText)
                }
            }

            // 鼓励
            if !almanac.encouragement.isEmpty {
                Text(almanac.encouragement)
                    .font(.lifeEncouragement)
                    .foregroundStyle(Color.lifeAccent)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, Layout.spacingXS)
            }
        }
        .lifeCard()
    }
}

#Preview {
    let almanac = DailyAlmanac()
    almanac.keyword = "破局"
    almanac.yiList = ["主动推进一个小决定", "和信任的人说真心话", "给自己一个不被打扰的小时"]
    almanac.jiList = ["反复等待完美状态", "同时开始太多事情", "用忙碌代替思考"]
    almanac.reminder = "你今天需要的不是更多计划，而是一个可完成的动作"
    almanac.encouragement = "你已经在路上了"

    return AlmanacCard(almanac: almanac)
        .padding()
        .background(Color.lifeBackground)
}
