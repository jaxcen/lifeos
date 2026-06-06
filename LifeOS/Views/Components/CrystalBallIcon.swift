import SwiftUI

struct CrystalBallIcon: View {
    var size: CGFloat = 28
    var isActive = true

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isActive ? 0.95 : 0.72),
                            Color.lifeSoftSky.opacity(isActive ? 0.95 : 0.62),
                            Color.lifeAccent.opacity(isActive ? 0.78 : 0.45)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.92), lineWidth: size * 0.045)
                )
                .shadow(color: Color.lifeAccent.opacity(isActive ? 0.22 : 0.08), radius: size * 0.18, y: size * 0.08)

            Circle()
                .fill(Color.white.opacity(0.82))
                .frame(width: size * 0.24, height: size * 0.24)
                .offset(x: -size * 0.17, y: -size * 0.19)

            Image(systemName: "sparkle")
                .font(.system(size: size * 0.25, weight: .bold))
                .foregroundStyle(Color.lifeAccent.opacity(0.86))
                .offset(x: size * 0.14, y: -size * 0.04)

            VStack(spacing: 0) {
                Spacer()
                RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                    .fill(Color.lifeAccent.opacity(isActive ? 0.72 : 0.5))
                    .frame(width: size * 0.5, height: size * 0.13)
                    .offset(y: size * 0.17)
                RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                    .fill(Color.lifeAccent.opacity(isActive ? 0.5 : 0.34))
                    .frame(width: size * 0.66, height: size * 0.11)
                    .offset(y: size * 0.18)
            }
        }
        .frame(width: size, height: size)
    }
}
