import SwiftUI

/// 渲染 Markdown 文本的辅助视图
struct MarkdownText: View {
    let markdown: String
    let font: Font
    let color: Color

    init(_ markdown: String, font: Font = .lifeBody, color: Color = .lifeText) {
        self.markdown = markdown
        self.font = font
        self.color = color
    }

    var body: some View {
        if let attributed = try? AttributedString(markdown: markdown, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            Text(attributed)
                .font(font)
                .foregroundStyle(color)
        } else {
            Text(markdown)
                .font(font)
                .foregroundStyle(color)
        }
    }
}
