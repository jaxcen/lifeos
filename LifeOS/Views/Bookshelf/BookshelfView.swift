import SwiftUI
import SwiftData

/// 书架视图 - 展示所有书
struct BookshelfView: View {
    @State private var viewModel: BookshelfViewModel
    @State private var selectedBook: DiaryBook?

    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: BookshelfViewModel(modelContext: modelContext))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.books.isEmpty {
                    emptyState
                } else {
                    bookshelfContent
                }
            }
        }
        .background(Color(hex: "F5F0E8"))
        .sheet(item: $selectedBook) { book in
            BookOpenView(book: book)
        }
        .onAppear {
            viewModel.loadBooks()
        }
    }

    // MARK: - 书架内容

    private var bookshelfContent: some View {
        VStack(spacing: 0) {
            // 顶部装饰
            topDecoration

            // 书架行（每行最多 3 本）
            ForEach(Array(chunkedBooks.enumerated()), id: \.offset) { _, rowBooks in
                BookShelfRowView(books: rowBooks) { book in
                    selectedBook = book
                }
                .padding(.vertical, Layout.spacingS)
            }

            // 底部留白
            Spacer(minLength: Layout.spacingXXL)
        }
    }

    // MARK: - 顶部装饰

    private var topDecoration: some View {
        VStack(spacing: Layout.spacingS) {
            // 书架顶部木板
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "A0926B"),
                            Color(hex: "8B7355")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 6)

            // 提示文字
            Text("轻点打开一本书")
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary.opacity(0.5))
                .padding(.top, Layout.spacingS)
                .padding(.bottom, Layout.spacingM)
        }
    }

    // MARK: - 空状态

    private var emptyState: some View {
        VStack(spacing: Layout.spacingXL) {
            Spacer()
                .frame(height: 80)

            Image(systemName: "books.vertical")
                .font(.system(size: 48))
                .foregroundStyle(Color.lifeTextSecondary.opacity(0.3))

            Text("书架还是空的")
                .font(.lifeHeadline)
                .foregroundStyle(Color.lifeTextSecondary)

            Text("去记录页写下你的想法，\nAI 会帮你整理成书")
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary.opacity(0.7))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 分组

    private var chunkedBooks: [[DiaryBook]] {
        stride(from: 0, to: viewModel.books.count, by: 3).map { start in
            Array(viewModel.books[start..<min(start + 3, viewModel.books.count)])
        }
    }
}
