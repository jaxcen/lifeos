import SwiftUI

/// 书中的一页 - 渲染单篇日记
struct BookChapterPageView: View {
    let chapter: BookChapter
    let pageNumber: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            // 页码
            HStack {
                Spacer()
                Text("\(pageNumber)")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary.opacity(0.5))
            }

            // 章节标题
            Text(chapter.title)
                .font(.lifeHeadline)
                .foregroundStyle(Color.lifeText)

            // 日期
            Text(dateString)
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)

            // 正文
            Text(chapter.body)
                .font(.lifeDiary)
                .foregroundStyle(Color.lifeText)
                .lineSpacing(8)

            Spacer(minLength: Layout.spacingXL)

            // 洞察
            if !chapter.insight.isEmpty {
                HStack(alignment: .top, spacing: Layout.spacingS) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.lifeAccent)
                    Text(chapter.insight)
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeAccent)
                }
                .padding(Layout.spacingM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.lifeAccent.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusS))
            }

            // 旁观者笔记
            if !chapter.observerNote.isEmpty {
                Text(chapter.observerNote)
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // 朝理想自我
            if let prediction = chapter.goalPrediction, !prediction.isEmpty {
                HStack(alignment: .top, spacing: Layout.spacingS) {
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.lifeYi)
                    Text(prediction)
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeYi)
                }
            }
        }
        .padding(Layout.spacingXL)
        .background(Color.paperWarm)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusM)
                .stroke(Color.lifeAccent.opacity(0.1), lineWidth: 1)
        )
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: chapter.date)
    }
}
