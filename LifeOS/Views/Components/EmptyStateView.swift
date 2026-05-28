import SwiftUI

/// 空状态视图 (和紙手帳風)
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Layout.spacingL) {
            ZStack {
                Circle()
                    .fill(Color.lifeAccent.opacity(0.1))
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color.lifeAccent)
            }

            Text(title)
                .font(.lifeBodyEmphasis)
                .foregroundStyle(Color.lifeText)

            Text(subtitle)
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.lifeBodyEmphasis)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.lifeAccent)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.spacingXXL)
        .paperCard()
    }
}

#Preview {
    VStack(spacing: 16) {
        EmptyStateView(
            icon: "doc.text",
            title: "还没有今日记录",
            subtitle: "去记录页写下今天的想法，\nAI 就能为你生成侧写日记"
        )

        EmptyStateView(
            icon: "book.closed",
            title: "今天的页面还是空白的",
            subtitle: "去记录页写下今天的想法",
            actionTitle: "去记录",
            action: {}
        )
    }
    .padding()
    .background(Color.lifeBackground)
}
