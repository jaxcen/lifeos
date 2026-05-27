import SwiftUI

/// 模板选择底部弹窗
struct TemplatePickerSheet: View {
    let selectedTemplate: EntryTemplate?
    let onSelect: (EntryTemplate) -> Void
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: Layout.spacingM),
        GridItem(.flexible(), spacing: Layout.spacingM)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: Layout.spacingM) {
                    ForEach(EntryTemplate.templates) { template in
                        TemplateCard(
                            template: template,
                            isSelected: selectedTemplate?.id == template.id
                        ) {
                            onSelect(template)
                            dismiss()
                        }
                    }
                }
                .padding(Layout.spacingL)
            }
            .background(Color.lifeBackground)
            .navigationTitle("选择模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(Color.lifeAccent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

/// 模板卡片
struct TemplateCard: View {
    let template: EntryTemplate
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Layout.spacingM) {
                Image(systemName: template.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .white : Color.lifeAccent)

                Text(template.name)
                    .font(.lifeBodyEmphasis)
                    .foregroundStyle(isSelected ? .white : Color.lifeText)

                Text(template.prompt)
                    .font(.lifeCaption)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : Color.lifeTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Layout.spacingL)
            .background(isSelected ? Color.lifeAccent : Color.lifeCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusL))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        }
    }
}

#Preview {
    TemplatePickerSheet(selectedTemplate: nil) { _ in }
}
