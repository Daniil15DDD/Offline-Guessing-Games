import SwiftUI

enum Theme {
    static let background = Color(hex: 0x0E1018)
    static let surface = Color(hex: 0x1A1D2B)
    static let surfaceRaised = Color(hex: 0x262A3D)
    static let textSecondary = Color(hex: 0x9AA3BD)
    static let good = Color(hex: 0x37C98A)
    static let near = Color(hex: 0xE2A83B)
    static let bad = Color(hex: 0xE85D75)
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
