import SwiftUI

/// 书封面 - 立体书效果
struct BookCoverView: View {
    let book: DiaryBook
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .leading) {
                // 书脊（左侧）
                spine

                // 页边（右侧）
                pageEdges
                    .offset(x: 110)

                // 封面（主体）
                frontCover
                    .offset(x: 8)
            }
            .frame(width: 120, height: 168)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 书脊

    private var spine: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.lifeAccent.opacity(0.76))
            .frame(width: 10, height: 168)
            .overlay(
                Text(book.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .rotationEffect(.degrees(-90))
                    .fixedSize()
            )
            .shadow(color: .black.opacity(0.15), radius: 4, x: 2, y: 0)
    }

    // MARK: - 封面

    private var frontCover: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    colors: [
                        book.coverColor.opacity(0.78),
                        Color.lifeAccent.opacity(0.72),
                        Color.lifePhotoAccent.opacity(0.64)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 105, height: 168)
            .overlay(coverContent)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 4, y: 4)
    }

    private var coverContent: some View {
        VStack(spacing: Layout.spacingM) {
            Spacer()

            // 装饰图标
            Image(systemName: book.coverIcon)
                .font(.system(size: 28))
                .foregroundStyle(.white.opacity(0.25))

            // 书名
            Text(book.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            // 副标题
            Text(book.subtitle)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.7))

            Spacer()

            // 章节数
            Text("\(book.chapterCount)章")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.vertical, Layout.spacingL)
        .padding(.horizontal, Layout.spacingS)
    }

    // MARK: - 页边

    private var pageEdges: some View {
        VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.86))
                    .frame(width: 3, height: CGFloat(168 - i * 2))
                    .offset(x: CGFloat(i) * 0.5)
            }
        }
    }
}
