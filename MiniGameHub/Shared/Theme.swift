import SwiftUI
import SpriteKit

enum Theme {
    static let background = Color(hex: 0x0E1018)
    static let surface = Color(hex: 0x1A1D2B)
    static let surfaceRaised = Color(hex: 0x262A3D)
    static let textSecondary = Color(hex: 0x9AA3BD)

    static let skBackground = SKColor(hex: 0x0E1018)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

extension SKColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    /// Linear blend between two colors. `t` is clamped to 0...1.
    static func blend(_ from: SKColor, _ to: SKColor, _ t: CGFloat) -> SKColor {
        let k = min(max(t, 0), 1)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        from.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        to.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return SKColor(
            red: r1 + (r2 - r1) * k,
            green: g1 + (g2 - g1) * k,
            blue: b1 + (b2 - b1) * k,
            alpha: a1 + (a2 - a1) * k
        )
    }
}

/// Small textures drawn in code so the app ships without image assets.
enum TextureFactory {
    static func verticalGradient(height: CGFloat, top: SKColor, bottom: SKColor) -> SKTexture {
        let size = CGSize(width: 4, height: max(height, 4))
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let colors = [top.cgColor, bottom.cgColor] as CFArray
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 1]
            ) else { return }
            context.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
        }
        return SKTexture(image: image)
    }

    static func roundedSquare(side: CGFloat, cornerRadius: CGFloat) -> SKTexture {
        let length = max(side, 2)
        let size = CGSize(width: length, height: length)
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            SKColor.white.setFill()
            UIBezierPath(
                roundedRect: CGRect(origin: .zero, size: size),
                cornerRadius: min(cornerRadius, length / 2)
            ).fill()
        }
        return SKTexture(image: image)
    }
}
