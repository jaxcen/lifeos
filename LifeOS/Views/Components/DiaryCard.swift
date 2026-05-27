import SwiftUI

/// 侧写日记卡片
struct DiaryCard: View {
    let diary: AIDiary

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            HStack {
                Image(systemName: "doc.text")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.lifeAccent)
                Text("今日侧写")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
                Spacer()
            }

            Text(diary.title)
                .font(.lifeHeadline)
                .foregroundStyle(Color.lifeText)

            Text(diary.body)
                .font(.lifeDiary)
                .foregroundStyle(Color.lifeText)
                .lineSpacing(6)

            if !diary.insight.isEmpty {
                Divider()

                HStack(alignment: .top, spacing: Layout.spacingS) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.lifeAccent)
                    Text(diary.insight)
                        .font(.lifeBodyEmphasis)
                        .foregroundStyle(Color.lifeAccent)
                }
            }

            if !diary.observerNote.isEmpty {
                Text("「\(diary.observerNote)」")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            if let prediction = diary.goalPrediction, !prediction.isEmpty {
                Divider()

                HStack(alignment: .top, spacing: Layout.spacingS) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.lifeYi)
                        .padding(.top, 2)
                    Text(prediction)
                        .font(.lifeBodyEmphasis)
                        .foregroundStyle(Color.lifeYi)
                }
            }
        }
        .lifeCard()
    }
}

#Preview {
    let diary = AIDiary()
    diary.title = "安静的一天"
    diary.body = "他今天花了一些时间和自己待在一起。没有什么惊天动地的事发生，但他写下了一些文字。这些文字不长，也不华丽，但它们是真实的。"
    diary.insight = "今天的选择比昨天更清晰"
    diary.observerNote = "他今天比自己以为的更勇敢"

    return DiaryCard(diary: diary)
        .padding()
        .background(Color.lifeBackground)
}
