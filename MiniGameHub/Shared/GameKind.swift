import SwiftUI

/// The games available in the hub. Add a case here (and a destination in
/// `HubView`) to add another game.
enum GameKind: String, CaseIterable, Identifiable, Hashable {
    case runner
    case merge
    case snake

    var id: String { rawValue }

    var title: String {
        switch self {
        case .runner: return "Moon Dash"
        case .merge: return "Tile Fuse"
        case .snake: return "Neon Snake"
        }
    }

    var tagline: String {
        switch self {
        case .runner: return "Endless runner. Jump the rocks, dodge the drones."
        case .merge: return "Slide the grid. Matching tiles fuse and double."
        case .snake: return "Eat, grow, and stay away from the walls."
        }
    }

    /// Shown over the game before the first input.
    var hint: String {
        switch self {
        case .runner: return "Tap to jump. Tap again in the air to double jump."
        case .merge: return "Swipe to slide the tiles."
        case .snake: return "Swipe to steer. Tap to start."
        }
    }

    /// SF Symbol used on the hub card.
    var symbol: String {
        switch self {
        case .runner: return "figure.run"
        case .merge: return "square.grid.2x2.fill"
        case .snake: return "scribble.variable"
        }
    }

    var colors: [Color] {
        switch self {
        case .runner: return [Color(hex: 0x6C7BFF), Color(hex: 0x38D6FF)]
        case .merge: return [Color(hex: 0xFF8A3D), Color(hex: 0xFF4F81)]
        case .snake: return [Color(hex: 0x37E38F), Color(hex: 0x1FA7A0)]
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Real-time games can be paused. The puzzle game has no clock.
    var supportsPause: Bool {
        switch self {
        case .runner, .snake: return true
        case .merge: return false
        }
    }

    /// UserDefaults key the high score is stored under.
    var scoreKey: String { "highscore.\(rawValue)" }
}
