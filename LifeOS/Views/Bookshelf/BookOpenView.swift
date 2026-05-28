import SwiftUI

/// 打开的书 - 全屏展示目录和章节
struct BookOpenView: View {
    let book: DiaryBook
    @Environment(\.dismiss) private var dismiss
    @State private var selectedChapter: BookChapter?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.spacingXL) {
                    // 封面区域
                    bookHeader

                    // 目录
                    tableOfContents

                    // 分割线
                    Divider()
                        .padding(.horizontal, Layout.spacingXL)

                    // 章节内容
                    ForEach(Array(book.chapters.enumerated()), id: \.element.id) { index, chapter in
                        BookChapterPageView(chapter: chapter, pageNumber: index + 1)
                            .id(chapter.id)
                    }
                }
                .padding(.bottom, Layout.spacingXXL)
            }
            .background(Color.paperWarm)
            .navigationTitle(book.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundStyle(Color.lifeAccent)
                }
            }
        }
    }

    // MARK: - 封面区域

    private var bookHeader: some View {
        VStack(spacing: Layout.spacingL) {
            // 装饰图标
            Image(systemName: book.coverIcon)
                .font(.system(size: 32))
                .foregroundStyle(book.coverColor.opacity(0.4))

            // 书名
            Text(book.title)
                .font(.lifeDisplay)
                .foregroundStyle(Color.lifeText)

            // 副标题
            Text(book.subtitle)
                .font(.lifeBody)
                .foregroundStyle(Color.lifeTextSecondary)

            // 章节数
            Text("共\(book.chapterCount)章")
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary.opacity(0.6))
        }
        .padding(.top, Layout.spacingXXL)
        .padding(.bottom, Layout.spacingL)
    }

    // MARK: - 目录

    private var tableOfContents: some View {
        VStack(alignment: .leading, spacing: Layout.spacingM) {
            Text("目录")
                .font(.lifeHeadline)
                .foregroundStyle(Color.lifeText)
                .padding(.bottom, Layout.spacingS)

            ForEach(Array(book.chapters.enumerated()), id: \.element.id) { index, chapter in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedChapter = chapter
                    }
                } label: {
                    HStack(alignment: .top, spacing: Layout.spacingM) {
                        // 章节编号
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(book.coverColor)
                            .frame(width: 24, height: 24)
                            .background(book.coverColor.opacity(0.1))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(chapter.title)
                                .font(.lifeBodyEmphasis)
                                .foregroundStyle(Color.lifeText)

                            Text(dateString(for: chapter.date))
                                .font(.lifeCaption)
                                .foregroundStyle(Color.lifeTextSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.lifeTextSecondary.opacity(0.4))
                    }
                    .padding(.vertical, Layout.spacingS)
                }
            }
        }
        .padding(.horizontal, Layout.spacingXL)
    }

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}
