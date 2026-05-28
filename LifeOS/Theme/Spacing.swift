import SwiftUI

/// 设计系统 - 间距和圆角
enum Layout {
    // MARK: - 间距
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32

    // MARK: - 圆角
    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
    static let radiusXL: CGFloat = 24
    static let radiusPill: CGFloat = 100

    // MARK: - 卡片
    static let cardPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 16
    static let cardShadowRadius: CGFloat = 12
    static let cardShadowY: CGFloat = 3

    // MARK: - 纸堆翻页
    static let pageStackOffset: CGFloat = 6
    static let pageStackScale: CGFloat = 0.97
    static let pageIndicatorHeight: CGFloat = 32

    // MARK: - 和纸条
    static let washiStripHeight: CGFloat = 20
    static let washiStripRotation: Double = 1.5

    // MARK: - 垂直纸堆
    static let verticalStackOffset: CGFloat = 8
    static let verticalStackDepth: Int = 3
}
