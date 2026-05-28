import SwiftUI

/// 垂直纸堆翻页视图 - 当前页在上，露出下方纸张边缘，上下滑动翻页
struct VerticalPaperStackView<Content: View, T: Hashable>: View {
    let items: [T]
    @Binding var selectedIndex: Int
    @ViewBuilder let content: (T, Int) -> Content

    @State private var dragOffset: CGFloat = 0
    @State private var isAnimating = false

    private let stackDepth = Layout.verticalStackDepth

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 底层纸边 (从下往上) - 文件夹层叠效果
                ForEach(Array(stackLayers.enumerated()), id: \.offset) { layerIndex, layerOffset in
                    paperEdge(
                        width: geo.size.width - CGFloat(layerIndex) * 8,
                        height: geo.size.height - CGFloat(stackDepth - layerIndex) * 20,
                        offset: layerOffset,
                        depth: layerIndex
                    )
                }

                // 当前页
                if selectedIndex < items.count {
                    content(items[selectedIndex], selectedIndex)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .offset(y: dragOffset)
                        .scaleEffect(1.0 - abs(dragOffset) * 0.0003)
                        .shadow(
                            color: .black.opacity(dragOffset == 0 ? 0.1 : 0.2),
                            radius: dragOffset == 0 ? 16 : 32,
                            y: dragOffset == 0 ? 4 : 12
                        )
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onChanged { value in
                                    guard !isAnimating else { return }
                                    dragOffset = value.translation.height
                                }
                                .onEnded { value in
                                    let threshold = geo.size.height * 0.20
                                    let velocity = value.predictedEndTranslation.height

                                    withAnimation(.spring(response: Layout.springResponse, dampingFraction: Layout.springDamping)) {
                                        if (dragOffset < -threshold || velocity < -200) && selectedIndex < items.count - 1 {
                                            // 向上翻 - 下一天
                                            selectedIndex += 1
                                        } else if (dragOffset > threshold || velocity > 200) && selectedIndex > 0 {
                                            // 向下翻 - 前一天
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

    /// 底层纸边 - 文件夹层叠效果
    private func paperEdge(width: CGFloat, height: CGFloat, offset: CGFloat, depth: Int) -> some View {
        RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
            .fill(Color.lifeCardBackground)
            .frame(width: width, height: height)
            .offset(y: offset)
            .shadow(
                color: .black.opacity(0.08 + Double(depth) * 0.04),
                radius: 8 + Double(depth) * 4,
                y: 2 + Double(depth) * 2
            )
    }

    /// 纸堆层次偏移 - 更明显的层叠效果
    private var stackLayers: [CGFloat] {
        (0..<stackDepth).map { i in
            CGFloat(i + 1) * Layout.verticalStackOffset + 15
        }
    }
}

// MARK: - 便捷初始化：用 Date 数组

extension VerticalPaperStackView where T == Date {
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

#Preview {
    struct PreviewWrapper: View {
        @State private var index = 3
        let dates = (-3...3).map { Calendar.current.date(byAdding: .day, value: $0, to: Date())! }

        var body: some View {
            VStack {
                VerticalPaperStackView(dates: dates, selectedIndex: $index) { date, i in
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
            }
            .padding()
            .background(Color.lifeBackground)
        }
    }

    return PreviewWrapper()
}
