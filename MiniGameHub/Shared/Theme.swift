import SwiftUI
import UIKit

/// Colours. The app is dark only, and uses the same greys and accent
/// colours as iOS itself so it sits naturally next to the system.
enum Theme {
    static let background = Color.black
    /// Solid card colours, for places where a material would not work.
    static let surface = Color(hex: 0x1C1C1E)
    static let surfaceRaised = Color(hex: 0x2C2C2E)
    /// A light wash for controls sitting on a material.
    static let fill = Color.white.opacity(0.1)
    /// A slightly stronger wash, for buttons and unselected tiles.
    static let fillStrong = Color.white.opacity(0.16)
    static let hairline = Color.white.opacity(0.1)
    static let textSecondary = Color(hex: 0xEBEBF5, opacity: 0.6)
    static let textTertiary = Color(hex: 0xEBEBF5, opacity: 0.3)

    static let good = Color(hex: 0x30D158)
    static let near = Color(hex: 0xFF9F0A)
    static let bad = Color(hex: 0xFF453A)
    static let star = Color(hex: 0xFFD60A)

    /// One corner radius per kind of thing, always with continuous curves.
    static let cardRadius: CGFloat = 22
    static let controlRadius: CGFloat = 14
    static let chipRadius: CGFloat = 10
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

/// How things move. Everything uses springs, because a spring starts from
/// wherever the view currently is and can be redirected part-way.
///
/// The default has no bounce. Bounce is kept for things that were thrown or
/// dropped, where overshoot feels earned. When the system's Reduce Motion
/// setting is on, movement is replaced by short fades.
enum Motion {
    private static var reduced: Bool { UIAccessibility.isReduceMotionEnabled }

    /// The house spring: settles smoothly with no overshoot.
    static var settle: Animation {
        reduced ? .easeInOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 1)
    }

    /// A faster version for small changes such as a selection.
    static var quick: Animation {
        reduced ? .easeInOut(duration: 0.15) : .spring(response: 0.28, dampingFraction: 1)
    }

    /// A little overshoot, for things with momentum behind them.
    static var bounce: Animation {
        reduced ? .easeInOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 0.8)
    }

    /// Feedback for a finger going down: immediate, never springy.
    static let press = Animation.easeOut(duration: 0.1)

    /// A line drawing itself across a chart.
    static var draw: Animation {
        reduced ? .easeInOut(duration: 0.2) : .easeInOut(duration: 0.9)
    }

    /// New content arrives from just below and leaves the same way.
    static var rise: AnyTransition {
        reduced ? .opacity : .opacity.combined(with: .offset(y: 14))
    }

    /// A panel that comes up from the bottom edge and goes back down to it.
    static var sheet: AnyTransition {
        reduced ? .opacity : .move(edge: .bottom).combined(with: .opacity)
    }

    /// Something that grows out of where it was triggered.
    static var pop: AnyTransition {
        reduced ? .opacity : .scale(scale: 0.9).combined(with: .opacity)
    }
}

/// The scene behind every screen: black, with two soft pools of colour high
/// up. It gives the translucent cards above something to pick up.
struct Backdrop: View {
    let colors: [Color]

    var body: some View {
        ZStack {
            Color.black
            Circle()
                .fill(colors.first ?? .blue)
                .frame(width: 360, height: 360)
                .blur(radius: 130)
                .opacity(0.55)
                .offset(x: -130, y: -300)
            Circle()
                .fill(colors.last ?? .purple)
                .frame(width: 320, height: 320)
                .blur(radius: 140)
                .opacity(0.42)
                .offset(x: 160, y: -170)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

/// A game's icon: a rounded square in the game's colours with a white
/// symbol, drawn the way iOS draws app icons.
struct GameIcon: View {
    let kind: GameKind
    var size: CGFloat = 56

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.225, style: .continuous)
        shape
            .fill(LinearGradient(colors: kind.colors, startPoint: .top, endPoint: .bottom))
            .overlay(
                // Light catching the top half.
                LinearGradient(colors: [.white.opacity(0.26), .white.opacity(0)], startPoint: .top, endPoint: .center)
                    .clipShape(shape)
            )
            .overlay(
                Image(systemName: kind.symbol)
                    .font(.system(size: size * 0.46, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.18), radius: 1.5, x: 0, y: 1)
            )
            .overlay(shape.strokeBorder(Color.white.opacity(0.16), lineWidth: 0.5))
            .frame(width: size, height: size)
            .shadow(color: (kind.colors.last ?? .black).opacity(0.35), radius: size * 0.14, x: 0, y: size * 0.07)
            .accessibilityHidden(true)
    }
}

/// A ring that fills as a share of something gets done.
struct ProgressRing: View {
    /// From 0 to 1.
    let fraction: Double
    var lineWidth: CGFloat = 7
    var tint: Color = Theme.good

    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.12), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(fraction, 0), 1)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(Motion.settle, value: fraction)
        }
    }
}
