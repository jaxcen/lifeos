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

            // 雾紫玻璃托板
            shelfPlank
        }
    }

    // MARK: - 木板

    private var shelfPlank: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.72),
                            Color.lifeSoftLavender.opacity(0.58),
                            Color.lifeSoftSky.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(0.78), lineWidth: 1)
                )

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.lifeAccent.opacity(0.12),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 10)
                .blur(radius: 4)
        }
    }

    // MARK: - 书本微旋转

    private func rotation(for index: Int) -> Double {
        let angles: [Double] = [-1.5, 0.8, -0.5, 1.2, -0.8]
        return angles[index % angles.count]
    }
}
