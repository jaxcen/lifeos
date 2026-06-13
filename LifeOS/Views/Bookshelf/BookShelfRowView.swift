import SwiftUI

/// 书架的一行 - 两本书 + 暖木托板
struct BookShelfRowView: View {
    let books: [DiaryBook]
    let onBookTap: (DiaryBook) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: Layout.spacingXL) {
                ForEach(books) { book in
                    BookCoverView(book: book) {
                        onBookTap(book)
                    }
                }

                // 单本时占位，保持左右两列对齐
                if books.count == 1 {
                    Color.clear
                        .frame(width: BookCoverView.coverWidth, height: 1)
                }
            }

            shelfPlank
        }
    }

    // MARK: - 暖木托板

    private var shelfPlank: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "FFF4E3"),
                        Color.lifeShelfWood
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 13)
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(Color.white.opacity(0.85), lineWidth: 1)
            }
            .shadow(color: Color(hex: "C8A878").opacity(0.32), radius: 9, y: 7)
    }
}
