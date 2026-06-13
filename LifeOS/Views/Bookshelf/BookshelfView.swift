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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if viewModel.books.isEmpty {
                    emptyState
                } else {
                    bookshelfContent
                }
            }
            .padding(.horizontal, Layout.spacingL)
        }
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

            // 书架行（两本一排，适配 iPhone 宽度）
            ForEach(Array(chunkedBooks.enumerated()), id: \.offset) { _, rowBooks in
                BookShelfRowView(books: rowBooks) { book in
                    selectedBook = book
                }
                .padding(.bottom, Layout.spacingXL)
            }

            // 底部留白
            Spacer(minLength: Layout.spacingXXL)
        }
    }

    // MARK: - 顶部装饰

    private var topDecoration: some View {
        Text("轻点打开一本书")
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(Color.lifeTextSecondary.opacity(0.8))
            .padding(.top, Layout.spacingS)
            .padding(.bottom, Layout.spacingXL)
    }

    // MARK: - 空状态

    private var emptyState: some View {
        VStack(spacing: Layout.spacingXL) {
            Spacer()
                .frame(height: 80)

            Image(systemName: "books.vertical")
                .font(.system(size: 48))
                .foregroundStyle(Color.lifeAccent.opacity(0.45))
                .breathing(minScale: 0.96, maxScale: 1.04, duration: 4.6)

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
        stride(from: 0, to: viewModel.books.count, by: 2).map { start in
            Array(viewModel.books[start..<min(start + 2, viewModel.books.count)])
        }
    }
}
