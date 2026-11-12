import Foundation

struct GridPoint: Hashable {
    var x: Int
    var y: Int
}

/// Rules for the snake game, with no drawing code. y grows upward.
struct SnakeEngine {
    enum StepResult: Equatable {
        case moved
        case ate
        case died
        /// The snake covers the whole board. There is nowhere left to go.
        case filled
    }

    let cols: Int
    let rows: Int
    /// Head first.
    private(set) var body: [GridPoint]
    private(set) var heading: MoveDirection = .right
    private(set) var food: GridPoint?
    private(set) var isDead = false
    private(set) var eaten = 0

    private var pendingTurns: [MoveDirection] = []
    private var occupied: Set<GridPoint>

    /// Starts with a three-cell snake in the middle, heading right.
    /// Pass `food` to place the first food by hand (used by the tests).
    init(cols: Int, rows: Int, food: GridPoint? = nil) {
        let cx = max(cols, 5) / 2
        let cy = max(rows, 5) / 2
        self.init(
            cols: cols,
            rows: rows,
            body: [
                GridPoint(x: cx, y: cy),
                GridPoint(x: cx - 1, y: cy),
                GridPoint(x: cx - 2, y: cy)
            ],
            heading: .right,
            food: food
        )
    }

    /// Starts from an explicit position. `body` is head first.
    init(cols: Int, rows: Int, body: [GridPoint], heading: MoveDirection, food: GridPoint? = nil) {
        self.cols = max(cols, 5)
        self.rows = max(rows, 5)
        self.body = body
        self.heading = heading
        occupied = Set(body)
        if let food = food, !occupied.contains(food) {
            self.food = food
        } else {
            placeFood()
        }
    }

    /// Queues a turn for the next step. Reversing straight back into the
    /// body is ignored. Two turns can be buffered for quick corner moves.
    mutating func turn(_ direction: MoveDirection) {
        let reference = pendingTurns.last ?? heading
        guard direction != reference,
              direction != reference.opposite,
              pendingTurns.count < 2 else { return }
        pendingTurns.append(direction)
    }

    mutating func step() -> StepResult {
        guard !isDead else { return .died }
        if !pendingTurns.isEmpty {
            heading = pendingTurns.removeFirst()
        }

        let head = body[0]
        let next = GridPoint(x: head.x + heading.dx, y: head.y + heading.dy)

        guard next.x >= 0, next.x < cols, next.y >= 0, next.y < rows else {
            isDead = true
            return .died
        }

        let willEat = next == food
        let tail = body[body.count - 1]
        // Moving into the cell the tail is about to leave is allowed.
        let hitsBody = occupied.contains(next) && (willEat || next != tail)
        if hitsBody {
            isDead = true
            return .died
        }

        body.insert(next, at: 0)
        if willEat {
            occupied.insert(next)
            eaten += 1
            placeFood()
            return food == nil ? .filled : .ate
        }

        body.removeLast()
        occupied.remove(tail)
        occupied.insert(next)
        return .moved
    }

    private mutating func placeFood() {
        var free: [GridPoint] = []
        free.reserveCapacity(cols * rows - occupied.count)
        for x in 0..<cols {
            for y in 0..<rows {
                let point = GridPoint(x: x, y: y)
                if !occupied.contains(point) {
                    free.append(point)
                }
            }
        }
        food = free.randomElement()
    }
}
