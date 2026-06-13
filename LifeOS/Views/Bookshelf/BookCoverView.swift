import SwiftUI

/// 书封面 - 简约暖色封面
struct BookCoverView: View {
    static let coverWidth: CGFloat = 128
    static let coverHeight: CGFloat = 176

    let book: DiaryBook
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            cover
        }
        .buttonStyle(BookPressStyle())
    }

    private var cover: some View {
        ZStack {
            // 封面底色
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            book.coverColor.opacity(0.95),
                            book.coverColor.opacity(0.68)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // 顶部柔光
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.22), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )

            // 书脊折痕
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 1.5)
                Rectangle()
                    .fill(Color.white.opacity(0.32))
                    .frame(width: 1.5)
                Spacer()
            }
            .padding(.leading, 10)

            coverContent
        }
        .frame(width: Self.coverWidth, height: Self.coverHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: book.coverColor.opacity(0.34), radius: 12, y: 9)
    }

    private var coverContent: some View {
        VStack(spacing: 10) {
            Spacer()

            Image(systemName: book.coverIcon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 52, height: 52)
                .background(.white.opacity(0.16), in: Circle())

            Text(book.title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(book.subtitle)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(1)

            Spacer()

            Text("\(book.chapterCount) 章")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.18), in: Capsule())
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 14)
        .padding(.leading, 6)
    }
}

/// 按压回弹 - 轻盈的拿书手感
private struct BookPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
