import Foundation

struct MergeTile: Codable, Equatable, Identifiable {
    let id: Int
    var value: Int
    /// Row 0 is the top row.
    var row: Int
    var col: Int
}

/// Rules for the sliding puzzle, with no drawing code. Every move reports
/// exactly which tiles travelled where so the scene can animate them.
struct MergeBoard: Codable, Equatable {

    /// An existing tile travelling to a cell.
    struct Slide: Equatable {
        let id: Int
        let row: Int
        let col: Int
    }

    /// Two tiles (`consumed`) replaced by one new tile (`result`).
    struct Fusion: Equatable {
        let result: MergeTile
        let consumed: [Int]
    }

    struct Outcome: Equatable {
        var slides: [Slide] = []
        var fusions: [Fusion] = []
        var gained = 0
        var changed = false
    }

    let side: Int
    private(set) var tiles: [MergeTile] = []
    private(set) var score = 0
    private var nextID = 1

    init(side: Int = 4) {
        self.side = side
    }

    /// Builds a board from rows of values, top row first. 0 means empty.
    init(rows: [[Int]]) {
        self.side = rows.count
        for (r, line) in rows.enumerated() {
            for (c, value) in line.enumerated() where value > 0 {
                tiles.append(MergeTile(id: nextID, value: value, row: r, col: c))
                nextID += 1
            }
        }
    }

    /// A new game: an empty board with two starting tiles.
    static func fresh(side: Int = 4) -> MergeBoard {
        var board = MergeBoard(side: side)
        board.spawn()
        board.spawn()
        return board
    }

    /// Values as rows, top row first. 0 means empty.
    var grid: [[Int]] {
        var result = Array(repeating: Array(repeating: 0, count: side), count: side)
        for tile in tiles where isInside(tile) {
            result[tile.row][tile.col] = tile.value
        }
        return result
    }

    var highestValue: Int {
        tiles.map(\.value).max() ?? 0
    }

    /// False once the board is full and no neighbours match.
    var canMove: Bool {
        if tiles.count < side * side { return true }
        let values = grid
        for r in 0..<side {
            for c in 0..<side {
                if c + 1 < side, values[r][c] == values[r][c + 1] { return true }
                if r + 1 < side, values[r][c] == values[r + 1][c] { return true }
            }
        }
        return false
    }

    /// True when the saved data describes a board this code can play.
    var isValid: Bool {
        guard side >= 2, tiles.count <= side * side else { return false }
        var seen = Set<Int>()
        for tile in tiles {
            guard isInside(tile), tile.value > 0 else { return false }
            guard seen.insert(tile.row * side + tile.col).inserted else { return false }
        }
        return true
    }

    /// Drops a 2 (90%) or a 4 (10%) on a random empty cell.
    @discardableResult
    mutating func spawn() -> MergeTile? {
        let values = grid
        var empty: [(Int, Int)] = []
        for r in 0..<side {
            for c in 0..<side where values[r][c] == 0 {
                empty.append((r, c))
            }
        }
        guard let (row, col) = empty.randomElement() else { return nil }
        let tile = MergeTile(
            id: nextID,
            value: Int.random(in: 0..<10) == 0 ? 4 : 2,
            row: row,
            col: col
        )
        nextID += 1
        tiles.append(tile)
        return tile
    }

    /// Slides every tile as far as it goes. Equal neighbours fuse once per
    /// move. If nothing can move the board is left untouched.
    mutating func slide(_ direction: MoveDirection) -> Outcome {
        var outcome = Outcome()
        var placed: [MergeTile] = []
        var newID = nextID

        let horizontal = direction.isHorizontal
        // Tiles nearest the wall they are heading for are settled first.
        let towardStart = direction == .left || direction == .up

        for line in 0..<side {
            let lineTiles = tiles
                .filter { horizontal ? $0.row == line : $0.col == line }
                .sorted { a, b in
                    let pa = horizontal ? a.col : a.row
                    let pb = horizontal ? b.col : b.row
                    return towardStart ? pa < pb : pa > pb
                }

            var slot = 0
            var fusable: Int? = nil  // index in `placed` that may still fuse

            for tile in lineTiles {
                if let index = fusable, placed[index].value == tile.value {
                    let target = placed[index]
                    let fused = MergeTile(
                        id: newID,
                        value: tile.value * 2,
                        row: target.row,
                        col: target.col
                    )
                    newID += 1
                    outcome.slides.append(Slide(id: tile.id, row: target.row, col: target.col))
                    outcome.fusions.append(Fusion(result: fused, consumed: [target.id, tile.id]))
                    outcome.gained += fused.value
                    outcome.changed = true
                    placed[index] = fused
                    fusable = nil
                } else {
                    let along = towardStart ? slot : side - 1 - slot
                    let row = horizontal ? line : along
                    let col = horizontal ? along : line
                    if tile.row != row || tile.col != col {
                        outcome.changed = true
                    }
                    var moved = tile
                    moved.row = row
                    moved.col = col
                    outcome.slides.append(Slide(id: tile.id, row: row, col: col))
                    placed.append(moved)
                    fusable = placed.count - 1
                    slot += 1
                }
            }
        }

        guard outcome.changed else { return Outcome() }
        tiles = placed
        score += outcome.gained
        nextID = newID
        return outcome
    }

    private func isInside(_ tile: MergeTile) -> Bool {
        tile.row >= 0 && tile.row < side && tile.col >= 0 && tile.col < side
    }
}
