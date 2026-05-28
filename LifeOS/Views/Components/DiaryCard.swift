import SwiftUI

/// 侧写日记卡片 (和紙手帳風 - 笔记本横线纸风)
struct DiaryCard: View {
    let diary: AIDiary

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            // 标题区
            HStack {
                Image(systemName: "pencil.line")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.lifeAccent)
                Text("侧写日记")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
                Spacer()
            }

            Text(diary.title)
                .font(.lifeHeadline)
                .foregroundStyle(Color.lifeText)

            // 正文 - 横线纸风
            Text(diary.body)
                .font(.lifeDiary)
                .foregroundStyle(Color.lifeText)
                .lineSpacing(6)
                .padding(.horizontal, Layout.spacingM)
                .padding(.vertical, Layout.spacingL)
                .background(
                    linedPaperBackground
                )

            // 洞察 - 墨迹高亮风
            if !diary.insight.isEmpty {
                HStack(alignment: .top, spacing: Layout.spacingS) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.lifeAccent)
                    Text(diary.insight)
                        .font(.lifeBodyEmphasis)
                        .foregroundStyle(Color.lifeAccent)
                }
                .padding(Layout.spacingM)
                .background(
                    RoundedRectangle(cornerRadius: Layout.radiusS)
                        .fill(Color.lifeAccent.opacity(0.06))
                )
            }

            // 旁观者笔记
            if !diary.observerNote.isEmpty {
                Text("「\(diary.observerNote)」")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, Layout.spacingS)
            }

            // 目标预测
            if let prediction = diary.goalPrediction, !prediction.isEmpty {
                HStack(alignment: .top, spacing: Layout.spacingS) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.lifeYi)
                        .padding(.top, 2)
                    Text(prediction)
                        .font(.lifeBodyEmphasis)
                        .foregroundStyle(Color.lifeYi)
                }
                .padding(Layout.spacingM)
                .background(
                    RoundedRectangle(cornerRadius: Layout.radiusS)
                        .fill(Color.lifeYi.opacity(0.06))
                )
            }
        }
        .paperCard(tint: .paperWarm)
        .washiTape(.washiBlue, position: .topTrailing)
    }

    // MARK: - 横线纸背景

    private var linedPaperBackground: some View {
        GeometryReader { geo in
            let lineSpacing: CGFloat = 24
            let lineCount = Int(geo.size.height / lineSpacing)

            VStack(spacing: 0) {
                ForEach(0..<lineCount, id: \.self) { _ in
                    Spacer()
                        .frame(height: lineSpacing - 1)
                    Rectangle()
                        .fill(Color.lifeAccent.opacity(0.06))
                        .frame(height: 1)
                }
            }
            .padding(.top, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: Layout.radiusS)
                .fill(Color.paperWarm)
        )
    }
}

#Preview {
    let diary = AIDiary()
    diary.title = "安静的一天"
    diary.body = "他今天花了一些时间和自己待在一起。没有什么惊天动地的事发生，但他写下了一些文字。这些文字不长，也不华丽，但它们是真实的。"
    diary.insight = "今天的选择比昨天更清晰"
    diary.observerNote = "他今天比自己以为的更勇敢"

    return ScrollView {
        DiaryCard(diary: diary)
            .padding()
    }
    .background(Color.lifeBackground)
}
