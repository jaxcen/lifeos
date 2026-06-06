import SwiftUI
import UIKit

/// Displays the mascot as transparent PNG frames extracted from the WebM asset.
struct MascotVideoView: View {
    init(resourceName: String = "lifeos-mascot") {}

    private static let frameRate: TimeInterval = 1.0 / 12.0
    private static let frames: [UIImage] = (1...36).compactMap { index in
        let name = "mascot_\(String(format: "%02d", index))"
        if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "MascotFrames") {
            return UIImage(contentsOfFile: url.path)
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "png") {
            return UIImage(contentsOfFile: url.path)
        }
        return UIImage(named: name)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: Self.frameRate)) { timeline in
            if let image = currentFrame(at: timeline.date) {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color.lifeAccent)
            }
        }
    }

    private func currentFrame(at date: Date) -> UIImage? {
        guard !Self.frames.isEmpty else { return nil }
        let index = Int(date.timeIntervalSinceReferenceDate / Self.frameRate) % Self.frames.count
        return Self.frames[index]
    }
}
