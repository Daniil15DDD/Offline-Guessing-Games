// Plain command-line checks for the game rules. No Xcode needed:
//
//   swiftc -swift-version 5 MiniGameHub/Logic/*.swift Tests/LogicTests/main.swift -o logic-tests
//   ./logic-tests

import Foundation

var failures = 0
var checks = 0

func expect(_ condition: @autoclosure () -> Bool, _ message: String, line: UInt = #line) {
    checks += 1
    if !condition() {
        failures += 1
        print("FAIL (line \(line)): \(message)")
    }
}

// MARK: - Tile Fuse

do {
    var board = MergeBoard(rows: [
        [2, 2, 2, 2],
        [2, 2, 4, 0],
        [4, 2, 2, 0],
        [0, 0, 0, 8]
    ])
    let outcome = board.slide(.left)
    expect(outcome.changed, "slide left changes the board")
    expect(board.grid == [
        [4, 4, 0, 0],
        [4, 4, 0, 0],
        [4, 4, 0, 0],
        [8, 0, 0, 0]
    ], "slide left result, got \(board.grid)")
    expect(outcome.gained == 16, "slide left gains 16, got \(outcome.gained)")
    expect(board.score == 16, "score follows the gain")
    expect(outcome.fusions.count == 4, "four fusions, got \(outcome.fusions.count)")
    expect(board.tiles.count == 7, "seven tiles remain, got \(board.tiles.count)")
    expect(Set(board.tiles.map(\.id)).count == board.tiles.count, "tile ids stay unique")
}

do {
    var board = MergeBoard(rows: [
        [2, 2, 2, 0],
        [0, 4, 4, 4],
        [2, 0, 0, 2],
        [8, 4, 2, 0]
    ])
    _ = board.slide(.right)
    expect(board.grid == [
        [0, 0, 2, 4],
        [0, 0, 4, 8],
        [0, 0, 0, 4],
        [0, 8, 4, 2]
    ], "slide right result, got \(board.grid)")
}

do {
    var board = MergeBoard(rows: [
        [2, 0, 4, 2],
        [2, 0, 4, 2],
        [4, 0, 0, 2],
        [4, 8, 0, 2]
    ])
    var down = board
    _ = board.slide(.up)
    expect(board.grid == [
        [4, 8, 8, 4],
        [8, 0, 0, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0]
    ], "slide up result, got \(board.grid)")
    _ = down.slide(.down)
    expect(down.grid == [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [4, 0, 0, 4],
        [8, 8, 8, 4]
    ], "slide down result, got \(down.grid)")
}

do {
    var board = MergeBoard(rows: [
        [2, 4, 0, 0],
        [8, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0]
    ])
    let before = board
    let outcome = board.slide(.left)
    expect(!outcome.changed, "a blocked move reports no change")
    expect(board == before, "a blocked move leaves the board untouched")
}

do {
    let stuck = MergeBoard(rows: [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2]
    ])
    expect(!stuck.canMove, "a full board with no pairs cannot move")

    let pair = MergeBoard(rows: [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 4]
    ])
    expect(pair.canMove, "a full board with one pair can move")
    expect(stuck.isValid && pair.isValid, "test boards are valid")
}

do {
    var board = MergeBoard.fresh()
    expect(board.tiles.count == 2, "a fresh board has two tiles")
    for _ in 0..<14 { board.spawn() }
    expect(board.tiles.count == 16, "spawning fills the board")
    expect(board.spawn() == nil, "no spawn on a full board")
    expect(board.isValid, "a filled board is valid")

    let data = try JSONEncoder().encode(board)
    let restored = try JSONDecoder().decode(MergeBoard.self, from: data)
    expect(restored == board, "a board survives a save and load")
} catch {
    expect(false, "save and load threw \(error)")
}

do {
    // Play random moves and check the bookkeeping never drifts.
    var board = MergeBoard.fresh()
    var moves = 0
    while board.canMove && moves < 5000 {
        let direction = MoveDirection.allCases.randomElement() ?? .left
        let sumBefore = board.tiles.reduce(0) { $0 + $1.value }
        let outcome = board.slide(direction)
        if outcome.changed {
            let sumAfter = board.tiles.reduce(0) { $0 + $1.value }
            expect(sumBefore == sumAfter, "sliding keeps the tile total")
            expect(board.isValid, "board stays valid after a slide")
            board.spawn()
            moves += 1
        }
    }
    expect(moves > 10, "a random game lasts more than ten moves")
    expect(!board.canMove || moves == 5000, "the random game ends when stuck")
}

// MARK: - Neon Snake

do {
    // 10 x 10 board: head starts at (5, 5) heading right.
    var snake = SnakeEngine(cols: 10, rows: 10, food: GridPoint(x: 0, y: 0))
    expect(snake.body.count == 3, "the snake starts three cells long")
    expect(snake.body[0] == GridPoint(x: 5, y: 5), "the head starts in the middle")

    snake.turn(.left)
    expect(snake.step() == .moved, "a reverse turn is ignored")
    expect(snake.body[0] == GridPoint(x: 6, y: 5), "still heading right")

    for _ in 0..<3 { expect(snake.step() == .moved, "moves toward the wall") }
    expect(snake.body[0] == GridPoint(x: 9, y: 5), "reaches the last column")
    expect(snake.step() == .died, "dies on the wall")
    expect(snake.isDead, "stays dead")
    expect(snake.step() == .died, "a dead snake does not move")
}

do {
    var snake = SnakeEngine(cols: 10, rows: 10, food: GridPoint(x: 6, y: 5))
    expect(snake.step() == .ate, "eats the food in front of it")
    expect(snake.body.count == 4, "grows by one")
    expect(snake.eaten == 1, "counts the food")
    if let food = snake.food {
        expect(!snake.body.contains(food), "new food is not under the snake")
    } else {
        expect(false, "new food is placed")
    }
}

do {
    // Two quick turns are buffered and applied one step at a time.
    var snake = SnakeEngine(cols: 10, rows: 10, food: GridPoint(x: 0, y: 0))
    snake.turn(.up)
    snake.turn(.left)
    snake.turn(.down)  // third turn does not fit in the buffer
    expect(snake.step() == .moved, "first buffered turn")
    expect(snake.body[0] == GridPoint(x: 5, y: 6), "turned up")
    expect(snake.step() == .moved, "second buffered turn")
    expect(snake.body[0] == GridPoint(x: 4, y: 6), "turned left")
    expect(snake.step() == .moved, "keeps going left")
    expect(snake.body[0] == GridPoint(x: 3, y: 6), "third turn was dropped")
}

do {
    // A straight five-cell snake that curls back dies on its own body.
    var snake = SnakeEngine(
        cols: 12,
        rows: 12,
        body: [
            GridPoint(x: 5, y: 5), GridPoint(x: 4, y: 5), GridPoint(x: 3, y: 5),
            GridPoint(x: 2, y: 5), GridPoint(x: 1, y: 5)
        ],
        heading: .right,
        food: GridPoint(x: 0, y: 0)
    )
    snake.turn(.up)
    expect(snake.step() == .moved, "curl step one")
    snake.turn(.left)
    expect(snake.step() == .moved, "curl step two")
    snake.turn(.down)
    expect(snake.step() == .died, "curling into the body is fatal")
}

do {
    // A four-cell snake in a 2 x 2 loop can follow its own tail forever.
    var snake = SnakeEngine(
        cols: 12,
        rows: 12,
        body: [
            GridPoint(x: 5, y: 5), GridPoint(x: 4, y: 5),
            GridPoint(x: 4, y: 6), GridPoint(x: 5, y: 6)
        ],
        heading: .right,
        food: GridPoint(x: 0, y: 0)
    )
    let loop: [MoveDirection] = [.up, .left, .down, .right, .up, .left, .down, .right]
    var alive = true
    for direction in loop {
        snake.turn(direction)
        if snake.step() != .moved { alive = false; break }
    }
    expect(alive, "moving into the cell the tail just left is safe")
    expect(snake.body.count == 4, "the looping snake keeps its length")
}

print("\(checks) checks, \(failures) failed")
exit(failures == 0 ? 0 : 1)
