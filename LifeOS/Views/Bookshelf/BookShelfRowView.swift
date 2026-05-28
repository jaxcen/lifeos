import SwiftUI

/// 书架的一行 - 包含书和木板
struct BookShelfRowView: View {
    let books: [DiaryBook]
    let onBookTap: (DiaryBook) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 书本区域
            HStack(alignment: .bottom, spacing: Layout.spacingL) {
                ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                    BookCoverView(book: book) {
                        onBookTap(book)
                    }
                    .rotationEffect(.degrees(rotation(for: index)), anchor: .bottom)
                }
            }
            .padding(.horizontal, Layout.spacingL)
            .padding(.bottom, -4) // 让书和木板贴合

            // 木板
            shelfPlank
        }
    }

    // MARK: - 木板

    private var shelfPlank: some View {
        VStack(spacing: 0) {
            // 木板主体
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "A0926B"),
                            Color(hex: "8B7355"),
                            Color(hex: "7A6548")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 12)

            // 木板底部阴影
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 8)
        }
    }

    // MARK: - 书本微旋转

    private func rotation(for index: Int) -> Double {
        let angles: [Double] = [-1.5, 0.8, -0.5, 1.2, -0.8]
        return angles[index % angles.count]
    }
}
