import SwiftUI
import PhotosUI

/// 照片记录视图
struct PhotoEntryView: View {
    @Binding var photoImage: UIImage?
    @Binding var photoDescription: String
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var showPhotoPicker: Bool

    var body: some View {
        VStack(spacing: Layout.spacingL) {
            if let image = photoImage {
                // 照片预览
                photoPreview(image)

                // 说明输入
                descriptionInput
            } else {
                // 选择照片提示
                photoPlaceholder
            }
        }
    }

    // MARK: - 照片预览

    private func photoPreview(_ image: UIImage) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))

            // 更换按钮
            Button {
                showPhotoPicker = true
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding(Layout.spacingS)
        }
        .lifeCard(padding: 0)
    }

    // MARK: - 说明输入

    private var descriptionInput: some View {
        VStack(alignment: .leading, spacing: Layout.spacingS) {
            TextEditor(text: $photoDescription)
                .font(.lifeBody)
                .foregroundStyle(Color.lifeText)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80)
                .overlay(alignment: .topLeading) {
                    if photoDescription.isEmpty {
                        Text("记录这张照片背后的故事...")
                            .font(.lifeBody)
                            .foregroundStyle(Color.lifeTextSecondary.opacity(0.5))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
        }
        .lifeCard()
    }

    // MARK: - 占位

    private var photoPlaceholder: some View {
        Button {
            showPhotoPicker = true
        } label: {
            VStack(spacing: Layout.spacingL) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.lifeAccent)

                Text("选择一张照片")
                    .font(.lifeBodyEmphasis)
                    .foregroundStyle(Color.lifeAccent)

                Text("用照片记录此刻")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .background(Color.lifeAccent.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
        }
        .lifeCard()
    }
}
