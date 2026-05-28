import SwiftUI

/// 日期气泡条 - 显示以选中日期为中心的 5 个日期气泡
struct DateBubbleStrip: View {
    let dates: [Date]
    @Binding var selectedIndex: Int
    let onTapDate: (Int) -> Void

    // 滑动窗口：显示 5 个气泡，以 selectedIndex 为中心
    private var visibleRange: Range<Int> {
        let windowSize = 5
        let half = windowSize / 2
        let start = max(0, selectedIndex - half)
        let end = min(dates.count, start + windowSize)
        return start..<end
    }

    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M/d"
        return f
    }

    var body: some View {
        HStack(spacing: Layout.spacingS) {
            ForEach(Array(visibleRange), id: \.self) { i in
                let isSelected = i == selectedIndex
                let isToday = Calendar.current.isDateInToday(dates[i])

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        onTapDate(i)
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(formatter.string(from: dates[i]))
                            .font(isSelected ? .lifeBodyEmphasis : .lifeCaption)
                            .foregroundStyle(isSelected ? .white : Color.lifeTextSecondary)

                        if isToday {
                            Circle()
                                .fill(isSelected ? .white : Color.lifeAccent)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.lifeAccent : Color.lifeCardBackground)
                    )
                    .shadow(
                        color: isSelected ? Color.lifeAccent.opacity(0.3) : .clear,
                        radius: isSelected ? 6 : 0,
                        y: isSelected ? 3 : 0
                    )
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedIndex)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var index = 3
        let dates = (-7...1).map { Calendar.current.date(byAdding: .day, value: $0, to: Date())! }

        var body: some View {
            VStack {
                DateBubbleStrip(dates: dates, selectedIndex: $index) { i in
                    index = i
                }
                .padding()
                .background(Color.lifeBackground)
            }
        }
    }

    return PreviewWrapper()
}
