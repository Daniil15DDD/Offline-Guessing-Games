import Foundation

/// A swipe direction, shared by the puzzle and the snake.
enum MoveDirection: String, Codable, CaseIterable {
    case up, down, left, right

    var opposite: MoveDirection {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }

    var isHorizontal: Bool {
        self == .left || self == .right
    }

    /// Grid step with y growing upward (SpriteKit orientation).
    var dx: Int {
        switch self {
        case .left: return -1
        case .right: return 1
        case .up, .down: return 0
        }
    }

    var dy: Int {
        switch self {
        case .up: return 1
        case .down: return -1
        case .left, .right: return 0
        }
    }

    /// Picks the dominant axis of a drag. `dy` is positive when the finger
    /// moved up the screen.
    static func from(dx: CGFloat, dy: CGFloat) -> MoveDirection {
        if abs(dx) > abs(dy) {
            return dx > 0 ? .right : .left
        }
        return dy > 0 ? .up : .down
    }
}
