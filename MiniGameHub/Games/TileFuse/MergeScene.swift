import SpriteKit

/// Tile Fuse: swipe to slide every tile. Two equal tiles that meet fuse into
/// one worth double. The rules live in `MergeBoard`. This scene animates the
/// moves it reports, reads swipes, and saves the board after every move so a
/// game in progress survives leaving the screen or closing the app.
final class MergeScene: SKScene, HubGameScene {

    weak var session: GameSession? {
        didSet { syncSession() }
    }

    private enum Tuning {
        static let slideDuration: TimeInterval = 0.11
        static let swipeDistance: CGFloat = 22
        static let saveKey = "tilefuse.savedBoard"
    }

    // MARK: State

    private var board: MergeBoard = MergeScene.loadSavedBoard() ?? MergeBoard.fresh()
    private var previousBoard: MergeBoard?
    private var isFinishing = false
    private var touchStart: CGPoint?
    private var swipeHandled = false

    // MARK: Layout

    private var builtSize: CGSize = .zero
    private var boardSide: CGFloat = 0
    private var boardOrigin: CGPoint = .zero
    private var cell: CGFloat = 0
    private var gap: CGFloat = 0

    // MARK: Nodes

    private var boardNode = SKNode()
    /// Holds every tile, including ones still sliding away after a fusion.
    private var tileLayer = SKNode()
    private var tileNodes: [Int: SKNode] = [:]

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        rebuildIfNeeded()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        rebuildIfNeeded()
    }

    private func rebuildIfNeeded() {
        guard size.width > 150, size.height > 300 else { return }
        let changed = abs(size.width - builtSize.width) > 0.5
            || abs(size.height - builtSize.height) > 0.5
        guard changed else { return }
        buildBoard()
    }

    /// This game has no "ready" phase: the board is live as soon as it shows.
    private func syncSession() {
        session?.startFresh(as: .playing, score: board.score)
    }

    func restart() {
        removeAllActions()
        board = MergeBoard.fresh()
        previousBoard = nil
        isFinishing = false
        save()
        syncSession()
        if builtSize != .zero {
            rebuildTiles(animated: true)
        }
    }

    /// Takes back the last move (one level).
    func undo() {
        guard let previous = previousBoard,
              !isFinishing,
              session?.phase == .playing else { return }
        board = previous
        previousBoard = nil
        session?.setCanUndo(false)
        session?.setScore(board.score)
        save()
        rebuildTiles(animated: false)
        Haptics.tap()
    }

    // MARK: - Board

    private func buildBoard() {
        removeAllChildren()
        builtSize = size
        backgroundColor = Theme.skBackground

        let count = CGFloat(board.side)
        // Leave room at the bottom for the Undo and New game buttons.
        boardSide = min(size.width - 32, size.height - 150, 440)
        gap = boardSide * 0.03
        cell = (boardSide - gap * (count + 1)) / count
        let centred = (size.height - boardSide) / 2 + 24
        boardOrigin = CGPoint(
            x: (size.width - boardSide) / 2,
            y: min(max(100, centred), size.height - boardSide - 12)
        )

        boardNode = SKNode()
        addChild(boardNode)

        let backdrop = SKShapeNode(
            rect: CGRect(x: boardOrigin.x, y: boardOrigin.y, width: boardSide, height: boardSide),
            cornerRadius: boardSide * 0.04
        )
        backdrop.fillColor = SKColor(hex: 0x1A1D2B)
        backdrop.strokeColor = .clear
        backdrop.zPosition = 0
        boardNode.addChild(backdrop)

        for row in 0..<board.side {
            for col in 0..<board.side {
                let slot = SKShapeNode(
                    rectOf: CGSize(width: cell, height: cell),
                    cornerRadius: cell * 0.16
                )
                slot.fillColor = SKColor(hex: 0x242838)
                slot.strokeColor = .clear
                slot.position = center(row: row, col: col)
                slot.zPosition = 1
                boardNode.addChild(slot)
            }
        }

        tileLayer = SKNode()
        tileLayer.zPosition = 2
        boardNode.addChild(tileLayer)
        rebuildTiles(animated: false)
    }

    private func center(row: Int, col: Int) -> CGPoint {
        CGPoint(
            x: boardOrigin.x + gap + CGFloat(col) * (cell + gap) + cell / 2,
            y: boardOrigin.y + boardSide - gap - CGFloat(row) * (cell + gap) - cell / 2
        )
    }

    private func rebuildTiles(animated: Bool) {
        // Clearing the layer also drops tiles that were mid-animation.
        tileLayer.removeAllChildren()
        tileNodes.removeAll()
        for tile in board.tiles {
            let node = makeTileNode(tile)
            tileLayer.addChild(node)
            tileNodes[tile.id] = node
            if animated {
                appear(node, after: 0)
            }
        }
    }

    private func makeTileNode(_ tile: MergeTile) -> SKNode {
        let node = SKShapeNode(
            rectOf: CGSize(width: cell, height: cell),
            cornerRadius: cell * 0.16
        )
        node.fillColor = MergeScene.color(for: tile.value)
        node.strokeColor = .clear
        node.position = center(row: tile.row, col: tile.col)
        node.zPosition = 2

        let text = "\(tile.value)"
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        switch text.count {
        case 1, 2: label.fontSize = cell * 0.44
        case 3: label.fontSize = cell * 0.36
        case 4: label.fontSize = cell * 0.29
        default: label.fontSize = cell * 0.23
        }
        label.zPosition = 1
        node.addChild(label)
        return node
    }

    /// One colour per tile value, cool for small tiles and hot for big ones.
    private static func color(for value: Int) -> SKColor {
        switch value {
        case 2: return SKColor(hex: 0x39415F)
        case 4: return SKColor(hex: 0x4A5488)
        case 8: return SKColor(hex: 0x2F6FDB)
        case 16: return SKColor(hex: 0x2B9FD9)
        case 32: return SKColor(hex: 0x1FB8A6)
        case 64: return SKColor(hex: 0x2FB866)
        case 128: return SKColor(hex: 0xD9A72B)
        case 256: return SKColor(hex: 0xE88A2E)
        case 512: return SKColor(hex: 0xEB6238)
        case 1024: return SKColor(hex: 0xE8457A)
        case 2048: return SKColor(hex: 0xB14DE8)
        default: return SKColor(hex: 0x7B4DFF)
        }
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStart = touches.first?.location(in: self)
        swipeHandled = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = touchStart, !swipeHandled else { return }
        let location = touch.location(in: self)
        let dx = location.x - start.x
        let dy = location.y - start.y
        guard max(abs(dx), abs(dy)) >= Tuning.swipeDistance else { return }
        swipeHandled = true  // one move per swipe
        move(MoveDirection.from(dx: dx, dy: dy))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStart = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStart = nil
    }

    // MARK: - Moves

    private func move(_ direction: MoveDirection) {
        guard let session = session,
              session.phase == .playing,
              !isFinishing,
              builtSize != .zero else { return }

        let before = board
        let outcome = board.slide(direction)
        guard outcome.changed else { return }

        previousBoard = before
        session.setCanUndo(true)

        let consumed = Set(outcome.fusions.flatMap { $0.consumed })
        for slide in outcome.slides {
            guard let node = tileNodes[slide.id] else { continue }
            let glide = SKAction.move(
                to: center(row: slide.row, col: slide.col),
                duration: Tuning.slideDuration
            )
            glide.timingMode = .easeOut
            if consumed.contains(slide.id) {
                // Slides under its partner, then is replaced by the fused tile.
                tileNodes[slide.id] = nil
                node.run(.sequence([glide, .removeFromParent()]), withKey: "slide")
            } else {
                node.run(glide, withKey: "slide")
            }
        }

        for fusion in outcome.fusions {
            let node = makeTileNode(fusion.result)
            node.zPosition = 3
            node.alpha = 0
            tileLayer.addChild(node)
            tileNodes[fusion.result.id] = node
            node.run(.sequence([
                .wait(forDuration: Tuning.slideDuration),
                .fadeIn(withDuration: 0.01),
                .scale(to: 1.14, duration: 0.07),
                .scale(to: 1, duration: 0.08)
            ]))
        }

        if let spawned = board.spawn() {
            let node = makeTileNode(spawned)
            tileLayer.addChild(node)
            tileNodes[spawned.id] = node
            appear(node, after: Tuning.slideDuration)
        }

        session.setScore(board.score)
        if outcome.fusions.isEmpty {
            Haptics.tap()
        } else {
            Haptics.bump()
        }

        if board.canMove {
            save()
        } else {
            finish()
        }
    }

    private func appear(_ node: SKNode, after delay: TimeInterval) {
        node.setScale(0.2)
        node.alpha = 0
        node.run(.sequence([
            .wait(forDuration: delay),
            .group([
                .fadeIn(withDuration: 0.08),
                .scale(to: 1, duration: 0.12)
            ])
        ]))
    }

    private func finish() {
        isFinishing = true
        previousBoard = nil
        session?.setCanUndo(false)
        // A finished board is not worth resuming.
        UserDefaults.standard.removeObject(forKey: Tuning.saveKey)
        Haptics.failure()
        run(.sequence([
            .wait(forDuration: 0.7),
            .run { [weak self] in
                self?.session?.finish()
            }
        ]))
    }

    // MARK: - Saving

    private func save() {
        guard let data = try? JSONEncoder().encode(board) else { return }
        UserDefaults.standard.set(data, forKey: Tuning.saveKey)
    }

    private static func loadSavedBoard() -> MergeBoard? {
        guard let data = UserDefaults.standard.data(forKey: Tuning.saveKey),
              let saved = try? JSONDecoder().decode(MergeBoard.self, from: data),
              saved.side == 4,
              saved.isValid,
              saved.canMove,
              !saved.tiles.isEmpty else { return nil }
        return saved
    }
}
