import SwiftUI

/// 锦囊卡片 - 今日宜忌 (和紙手帳風)
struct AlmanacCard: View {
    let almanac: DailyAlmanac

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            // 关键词 - 毛笔墨迹风
            VStack(alignment: .leading, spacing: Layout.spacingS) {
                Text("今日关键词")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)

                BrushStrokeText(text: almanac.keyword)
            }

            // 和纸条分隔
            WashiTapeDivider(color: .washiTan, width: 80)
                .padding(.vertical, Layout.spacingXS)

            // 宜忌
            HStack(alignment: .top, spacing: Layout.spacingXL) {
                // 宜
                VStack(alignment: .leading, spacing: Layout.spacingS) {
                    yiJiHeader(label: "宜", color: .lifeYi)

                    ForEach(almanac.yiList, id: \.self) { item in
                        yiJiItem(text: item, color: .lifeYi, icon: "checkmark.circle.fill")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 忌
                VStack(alignment: .leading, spacing: Layout.spacingS) {
                    yiJiHeader(label: "忌", color: .lifeJi)

                    ForEach(almanac.jiList, id: \.self) { item in
                        yiJiItem(text: item, color: .lifeJi, icon: "xmark.circle.fill")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 提醒
            if !almanac.reminder.isEmpty {
                HStack(alignment: .top, spacing: Layout.spacingS) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.lifeReminder)
                        .padding(.top, 2)

                    Text(almanac.reminder)
                        .font(.lifeReminder)
                        .foregroundStyle(Color.lifeText)
                }
                .padding(Layout.spacingM)
                .background(
                    RoundedRectangle(cornerRadius: Layout.radiusS)
                        .fill(Color.lifeReminder.opacity(0.08))
                )
            }

            // 鼓励 - 和纸条横幅风
            if !almanac.encouragement.isEmpty {
                Text(almanac.encouragement)
                    .font(.lifeEncouragement)
                    .foregroundStyle(Color.lifeAccent)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Layout.spacingS)
                    .padding(.horizontal, Layout.spacingM)
                    .background(
                        RoundedRectangle(cornerRadius: Layout.radiusS)
                            .fill(Color.lifeAccent.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: Layout.radiusS)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.1), .clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                    )
            }
        }
        .paperCard()
        .washiTape(.washiTan, position: .topTrailing)
    }

    // MARK: - 宜忌标题

    private func yiJiHeader(label: String, color: Color) -> some View {
        HStack(spacing: Layout.spacingXS) {
            Text(label)
                .font(.lifeHeadline)
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }

    // MARK: - 宜忌条目

    private func yiJiItem(text: String, color: Color, icon: String) -> some View {
        HStack(spacing: Layout.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
                .frame(width: 14, height: 14)

            Text(text)
                .font(.lifeAlmanacItem)
                .foregroundStyle(Color.lifeText)
        }
    }
}

#Preview {
    let almanac = DailyAlmanac()
    almanac.keyword = "破局"
    almanac.yiList = ["主动推进一个小决定", "和信任的人说真心话", "给自己一个不被打扰的小时"]
    almanac.jiList = ["反复等待完美状态", "同时开始太多事情", "用忙碌代替思考"]
    almanac.reminder = "你今天需要的不是更多计划，而是一个可完成的动作"
    almanac.encouragement = "你已经在路上了"

    return ScrollView {
        AlmanacCard(almanac: almanac)
            .padding()
    }
    .background(Color.lifeBackground)
}
