import SwiftUI

/// 明日推演详情
struct ForecastDetailView: View {
    let forecast: TomorrowForecast
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Layout.spacingXL) {
                    // 标题
                    VStack(alignment: .leading, spacing: Layout.spacingS) {
                        Text("明日推演")
                            .font(.lifeDisplay)
                            .foregroundStyle(Color.lifeText)

                        Text(forecastDate)
                            .font(.lifeCaption)
                            .foregroundStyle(Color.lifeTextSecondary)
                    }

                    // 能量预测
                    VStack(alignment: .leading, spacing: Layout.spacingS) {
                        Label("能量状态", systemImage: "bolt")
                            .font(.lifeCaption)
                            .foregroundStyle(Color.lifeTextSecondary)

                        MarkdownText(forecast.predictedEnergy, font: .lifeBody, color: .lifeText)
                    }

                    // 最佳时间段
                    if let slot = forecast.bestTimeSlot, !slot.isEmpty {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(Color.lifeAccent)
                            Text("最佳时间：\(slot)")
                                .font(.lifeBodyEmphasis)
                                .foregroundStyle(Color.lifeAccent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.lifeAccent.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
                    }

                    // 风险提示
                    if let risk = forecast.riskAlert, !risk.isEmpty {
                        VStack(alignment: .leading, spacing: Layout.spacingS) {
                            Label("注意", systemImage: "exclamationmark.triangle")
                                .font(.lifeCaption)
                                .foregroundStyle(Color.lifeJi)

                            MarkdownText(risk, font: .lifeBody, color: .lifeJi)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.lifeJi.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
                    }

                    // 建议行动
                    VStack(alignment: .leading, spacing: Layout.spacingM) {
                        Text("建议行动")
                            .font(.lifeHeadline)
                            .foregroundStyle(Color.lifeText)

                        ForEach(Array(forecast.suggestedActions.enumerated()), id: \.element) { index, action in
                            HStack(alignment: .top, spacing: Layout.spacingM) {
                                Text("\(index + 1)")
                                    .font(.lifeCaption)
                                    .foregroundStyle(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.lifeAccent)
                                    .clipShape(Circle())

                                MarkdownText(action, font: .lifeBody, color: .lifeText)
                            }
                        }
                    }

                    // 焦点建议
                    VStack(alignment: .leading, spacing: Layout.spacingS) {
                        Text("焦点建议")
                            .font(.lifeCaption)
                            .foregroundStyle(Color.lifeTextSecondary)

                        MarkdownText(forecast.focusSuggestion, font: .lifeBody, color: .lifeText)
                    }

                    Divider()

                    // 一句话
                    MarkdownText(forecast.oneLineAdvice, font: .lifeEncouragement, color: .lifeAccent)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(Layout.spacingXL)
            }
            .background(Color.lifeBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(Color.lifeAccent)
                }
            }
        }
    }

    private var forecastDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: forecast.forDate)
    }
}
