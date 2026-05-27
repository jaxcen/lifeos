import SwiftUI

/// 明日推演卡片
struct ForecastCard: View {
    let forecast: TomorrowForecast

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
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
            Text(forecast.predictedEnergy)
                .font(.lifeBody)
                .foregroundStyle(Color.lifeText)

            // 风险提示
            if let risk = forecast.riskAlert, !risk.isEmpty {
                HStack(alignment: .top, spacing: Layout.spacingS) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.lifeJi)
                        .padding(.top, 2)
                    Text(risk)
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeJi)
                }
            }

            // 建议行动
            if !forecast.suggestedActions.isEmpty {
                VStack(alignment: .leading, spacing: Layout.spacingXS) {
                    Text("建议行动")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)

                    ForEach(forecast.suggestedActions, id: \.self) { action in
                        HStack(spacing: Layout.spacingS) {
                            Circle()
                                .fill(Color.lifeAccent.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text(action)
                                .font(.lifeCaption)
                                .foregroundStyle(Color.lifeText)
                        }
                    }
                }
            }

            Divider()

            // 一句话建议
            Text(forecast.oneLineAdvice)
                .font(.lifeEncouragement)
                .foregroundStyle(Color.lifeAccent)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .lifeCard()
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

    return ForecastCard(forecast: forecast)
        .padding()
        .background(Color.lifeBackground)
}
