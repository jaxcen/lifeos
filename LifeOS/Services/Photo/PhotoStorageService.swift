import UIKit

/// 照片存储服务
final class PhotoStorageService {
    private let photosDirectory: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        photosDirectory = documents.appendingPathComponent("photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
    }

    /// 保存照片到 Documents/photos/{entryId}.jpg，返回相对路径
    func savePhoto(_ imageData: Data, entryId: UUID) -> String? {
        let fileName = "\(entryId.uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        do {
            try imageData.write(to: fileURL)
            return "photos/\(fileName)"
        } catch {
            print("照片保存失败: \(error)")
            return nil
        }
    }

    /// 从相对路径加载照片
    func loadPhoto(path: String) -> UIImage? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documents.appendingPathComponent(path)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    /// 删除照片文件
    func deletePhoto(path: String) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documents.appendingPathComponent(path)
        try? FileManager.default.removeItem(at: fileURL)
    }

    /// 压缩图片为 JPEG 数据
    static func compressImage(_ image: UIImage, quality: CGFloat = 0.7) -> Data? {
        image.jpegData(compressionQuality: quality)
    }
}
