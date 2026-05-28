import SwiftUI

/// 纸堆翻页视图 - 当前页在上，露出下方纸张边缘，左右滑动翻页
struct PaperStackView<Content: View, T: Hashable>: View {
    let items: [T]
    @Binding var selectedIndex: Int
    @ViewBuilder let content: (T, Int) -> Content

    @State private var dragOffset: CGFloat = 0
    @State private var isAnimating = false

    private let stackDepth = 2 // 下方显示几层纸边

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 底层纸边 (从下往上)
                ForEach(Array(stackLayers.enumerated()), id: \.offset) { layerIndex, layerOffset in
                    paperEdge(
                        width: geo.size.width - CGFloat(stackDepth - layerIndex) * 12,
                        offset: layerOffset,
                        depth: layerIndex
                    )
                }

                // 当前页
                if selectedIndex < items.count {
                    content(items[selectedIndex], selectedIndex)
                        .frame(width: geo.size.width)
                        .offset(x: dragOffset)
                        .shadow(
                            color: .black.opacity(dragOffset == 0 ? 0.06 : 0.1),
                            radius: dragOffset == 0 ? 12 : 20,
                            y: dragOffset == 0 ? 3 : 8
                        )
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onChanged { value in
                                    guard !isAnimating else { return }
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    let threshold = geo.size.width * 0.25
                                    let velocity = value.predictedEndTranslation.width

                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        if (dragOffset < -threshold || velocity < -200) && selectedIndex < items.count - 1 {
                                            // 向左翻 - 下一页
                                            selectedIndex += 1
                                        } else if (dragOffset > threshold || velocity > 200) && selectedIndex > 0 {
                                            // 向右翻 - 上一页
                                            selectedIndex -= 1
                                        }
                                        dragOffset = 0
                                    }
                                }
                        )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }

    /// 底层纸边
    private func paperEdge(width: CGFloat, offset: CGFloat, depth: Int) -> some View {
        RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
            .fill(Color.lifeCardBackground.opacity(0.6 - Double(depth) * 0.15))
            .frame(width: width, height: 40)
            .offset(y: offset)
            .shadow(color: .black.opacity(0.02), radius: 4, y: 2)
    }

    /// 纸堆层次偏移
    private var stackLayers: [CGFloat] {
        (0..<stackDepth).map { i in
            CGFloat(stackDepth - i) * Layout.pageStackOffset + 8
        }
    }
}

// MARK: - 便捷初始化：用 Date 数组

extension PaperStackView where T == Date {
    init(
        dates: [Date],
        selectedIndex: Binding<Int>,
        @ViewBuilder content: @escaping (Date, Int) -> Content
    ) {
        self.items = dates
        self._selectedIndex = selectedIndex
        self.content = content
    }
}

// MARK: - 页面指示器

struct PageDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color.lifeAccent : Color.lifeTextSecondary.opacity(0.3))
                    .frame(width: i == current ? 8 : 5, height: i == current ? 8 : 5)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
        .frame(height: Layout.pageIndicatorHeight)
    }
}

// MARK: - 日期指示标签

struct DateIndicatorLabel: View {
    let date: Date
    let isToday: Bool

    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M月d日 EEEE"
        return f
    }

    var body: some View {
        HStack(spacing: Layout.spacingS) {
            if isToday {
                Text("今日")
                    .font(.lifeTag)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.lifeAccent))
            }

            Text(formatter.string(from: date))
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var index = 3
        let dates = (-3...3).map { Calendar.current.date(byAdding: .day, value: $0, to: Date())! }

        var body: some View {
            VStack {
                PaperStackView(dates: dates, selectedIndex: $index) { date, i in
                    VStack {
                        Text("Page \(i)")
                            .font(.lifeTitle)
                        Text(date, style: .date)
                            .font(.lifeCaption)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .paperCard()
                }
                .frame(height: 400)

                PageDots(count: dates.count, current: index)

                DateIndicatorLabel(date: dates[index], isToday: index == 3)
            }
            .padding()
            .background(Color.lifeBackground)
        }
    }

    return PreviewWrapper()
}
