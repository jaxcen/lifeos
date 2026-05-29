import SwiftUI

/// 明日推演卡片 (和紙手帳風 - 略冷纸色暗示"未来")
struct ForecastCard: View {
    let forecast: TomorrowForecast

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            // 标题
            HStack {
                Image(systemName: "sunrise")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.lifeJi)
                Text("明日推演")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
                Spacer()
            }

            // 预测能量
            HStack(alignment: .top, spacing: Layout.spacingS) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.lifeAccent)
                    .padding(.top, 2)
                MarkdownText(forecast.predictedEnergy, font: .lifeBody, color: .lifeText)
            }

            // 风险提示 - 和纸条横幅风
            if let risk = forecast.riskAlert, !risk.isEmpty {
                HStack(alignment: .top, spacing: Layout.spacingS) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.lifeJi)
                        .padding(.top, 2)
                    MarkdownText(risk, font: .lifeCaption, color: .lifeJi)
                }
                .padding(Layout.spacingM)
                .background(
                    RoundedRectangle(cornerRadius: Layout.radiusS)
                        .fill(Color.lifeJi.opacity(0.06))
                )
            }

            // 建议行动 - 印章编号风
            if !forecast.suggestedActions.isEmpty {
                VStack(alignment: .leading, spacing: Layout.spacingM) {
                    Text("建议行动")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)

                    ForEach(Array(forecast.suggestedActions.enumerated()), id: \.offset) { index, action in
                        HStack(spacing: Layout.spacingM) {
                            // 编号印章
                            Text("\(index + 1)")
                                .font(.lifeTag)
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(
                                    Circle()
                                        .fill(Color.lifeAccent.opacity(0.7))
                                )

                            MarkdownText(action, font: .lifeCaption, color: .lifeText)
                        }
                    }
                }
            }

            // 一句话建议
            if !forecast.oneLineAdvice.isEmpty {
                WashiTapeDivider(color: .washiRose, width: 60)

                MarkdownText(forecast.oneLineAdvice, font: .lifeEncouragement, color: .lifeAccent)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .paperCard(tint: .paperCool)
        .washiTape(.washiRose, position: .topLeading)
    }
}

#Preview {
    let forecast = TomorrowForecast()
    forecast.predictedEnergy = "明天上午精力较好，适合处理需要专注的事"
    forecast.riskAlert = "下午容易被琐事打断"
    forecast.suggestedActions = [
        "上午先完成一件最重要的小事",
        "午后给自己10分钟独处时间"
    ]
    forecast.oneLineAdvice = "少想多做"

    return ScrollView {
        ForecastCard(forecast: forecast)
            .padding()
    }
    .background(Color.lifeBackground)
}
