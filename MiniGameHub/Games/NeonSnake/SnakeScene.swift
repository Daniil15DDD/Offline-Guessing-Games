import SpriteKit

/// Neon Snake: swipe to steer, eat to grow, do not hit the walls or yourself.
/// The rules live in `SnakeEngine`. This scene draws them and reads swipes.
final class SnakeScene: SKScene, HubGameScene {

    weak var session: GameSession?

    private enum Tuning {
        static let columns = 16
        static let maxRows = 26
        static let pointsPerFood = 10
        static let slowestStep: TimeInterval = 0.17
        static let fastestStep: TimeInterval = 0.075
        static let speedUpPerFood: TimeInterval = 0.004
        /// How far a finger must travel before it counts as a swipe.
        static let swipeDistance: CGFloat = 16
    }

    // MARK: Layout

    private var builtSize: CGSize = .zero
    private var rows = 20
    private var cell: CGFloat = 20

    // MARK: State

    private var engine: SnakeEngine?
    private var lastTime: TimeInterval = 0
    private var accumulator: TimeInterval = 0
    private var isDying = false
    private var touchAnchor: CGPoint?

    // MARK: Nodes

    private var boardNode = SKNode()
    private var segmentNodes: [SKSpriteNode] = []
    private var segmentTexture: SKTexture?
    private var eyes = SKNode()
    private var foodNode = SKShapeNode()

    private let headColor = SKColor(hex: 0xC8FF6B)
    private let neckColor = SKColor(hex: 0x4BE38A)
    private let tailColor = SKColor(hex: 0x1F8F8B)

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        rebuildIfNeeded()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        rebuildIfNeeded()
    }

    private func rebuildIfNeeded() {
        guard size.width > 150, size.height > 260 else { return }
        let changed = abs(size.width - builtSize.width) > 0.5
            || abs(size.height - builtSize.height) > 0.5
        guard changed else { return }
        buildBoard()
        resetRound()
    }

    func restart() {
        guard builtSize != .zero else { return }
        resetRound()
    }

    private func resetRound() {
        removeAllActions()
        boardNode.removeAllActions()
        boardNode.position = boardOrigin
        engine = SnakeEngine(cols: Tuning.columns, rows: rows)
        accumulator = 0
        isDying = false
        touchAnchor = nil
        render()
        session?.startFresh(as: .ready)
    }

    // MARK: - Board

    private var boardSize: CGSize {
        CGSize(width: cell * CGFloat(Tuning.columns), height: cell * CGFloat(rows))
    }

    private var boardOrigin: CGPoint {
        CGPoint(
            x: ((size.width - boardSize.width) / 2).rounded(),
            y: ((size.height - boardSize.height) / 2).rounded()
        )
    }

    private func buildBoard() {
        removeAllChildren()
        removeAllActions()
        segmentNodes.removeAll()

        builtSize = size
        backgroundColor = Theme.skBackground

        let margin: CGFloat = 12
        cell = floor((size.width - margin * 2) / CGFloat(Tuning.columns))
        rows = max(8, min(Tuning.maxRows, Int((size.height - margin * 2) / cell)))

        boardNode = SKNode()
        boardNode.position = boardOrigin
        addChild(boardNode)

        let boardSize = self.boardSize
        let columns = Tuning.columns
        let rowCount = rows
        let cellSide = cell
        let image = UIGraphicsImageRenderer(size: boardSize).image { context in
            SKColor(hex: 0x141829).setFill()
            context.fill(CGRect(origin: .zero, size: boardSize))
            SKColor(hex: 0x191E33).setFill()
            for x in 0..<columns {
                for y in 0..<rowCount where (x + y) % 2 == 0 {
                    context.fill(CGRect(
                        x: CGFloat(x) * cellSide,
                        y: CGFloat(y) * cellSide,
                        width: cellSide,
                        height: cellSide
                    ))
                }
            }
        }
        let floorNode = SKSpriteNode(texture: SKTexture(image: image))
        floorNode.anchorPoint = .zero
        floorNode.size = boardSize
        floorNode.zPosition = 0
        boardNode.addChild(floorNode)

        let border = SKShapeNode(
            rect: CGRect(origin: .zero, size: boardSize).insetBy(dx: -3, dy: -3),
            cornerRadius: 6
        )
        border.fillColor = .clear
        border.strokeColor = SKColor(hex: 0x37E38F, alpha: 0.55)
        border.lineWidth = 2
        border.zPosition = 1
        boardNode.addChild(border)

        segmentTexture = TextureFactory.roundedSquare(side: cell - 2, cornerRadius: cell * 0.28)

        foodNode = SKShapeNode(circleOfRadius: cell * 0.34)
        foodNode.fillColor = SKColor(hex: 0xFF5D73)
        foodNode.strokeColor = SKColor(hex: 0xFFC2CA)
        foodNode.lineWidth = 1.5
        foodNode.zPosition = 2
        foodNode.run(.repeatForever(.sequence([
            .scale(to: 1.15, duration: 0.45),
            .scale(to: 0.9, duration: 0.45)
        ])))
        boardNode.addChild(foodNode)

        // Eyes ride on the head and turn with it. They face +x by default.
        eyes = SKNode()
        eyes.zPosition = 1
        for side in [CGFloat(-1), CGFloat(1)] {
            let eye = SKShapeNode(circleOfRadius: max(1.5, cell * 0.1))
            eye.fillColor = SKColor(hex: 0x10231B)
            eye.strokeColor = .clear
            eye.position = CGPoint(x: cell * 0.16, y: side * cell * 0.19)
            eyes.addChild(eye)
        }
    }

    private func point(for gridPoint: GridPoint) -> CGPoint {
        CGPoint(
            x: (CGFloat(gridPoint.x) + 0.5) * cell,
            y: (CGFloat(gridPoint.y) + 0.5) * cell
        )
    }

    private func makeSegment() -> SKSpriteNode {
        let node = SKSpriteNode(
            texture: segmentTexture,
            color: neckColor,
            size: CGSize(width: cell - 2, height: cell - 2)
        )
        node.colorBlendFactor = 1
        node.zPosition = 3
        boardNode.addChild(node)
        return node
    }

    private func render() {
        guard let engine = engine else { return }
        let body = engine.body

        while segmentNodes.count < body.count {
            segmentNodes.append(makeSegment())
        }

        for (index, node) in segmentNodes.enumerated() {
            guard index < body.count else {
                node.isHidden = true
                continue
            }
            node.isHidden = false
            node.position = point(for: body[index])
            if index == 0 {
                node.color = headColor
                node.zPosition = 4
            } else {
                let progress = CGFloat(index) / CGFloat(max(body.count - 1, 1))
                node.color = SKColor.blend(neckColor, tailColor, progress)
                node.zPosition = 3
            }
        }

        if let head = segmentNodes.first {
            if eyes.parent !== head {
                eyes.removeFromParent()
                head.addChild(eyes)
            }
            switch engine.heading {
            case .right: eyes.zRotation = 0
            case .up: eyes.zRotation = .pi / 2
            case .left: eyes.zRotation = .pi
            case .down: eyes.zRotation = -.pi / 2
            }
        }

        if let food = engine.food {
            foodNode.isHidden = false
            foodNode.position = point(for: food)
        } else {
            foodNode.isHidden = true
        }
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let session = session, engine != nil else { return }
        touchAnchor = touch.location(in: self)
        if session.phase == .ready {
            session.begin()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let anchor = touchAnchor,
              session?.phase == .playing,
              !isDying else { return }
        let location = touch.location(in: self)
        let dx = location.x - anchor.x
        let dy = location.y - anchor.y
        guard max(abs(dx), abs(dy)) >= Tuning.swipeDistance else { return }
        engine?.turn(MoveDirection.from(dx: dx, dy: dy))
        // Re-anchor so one long drag can make several turns.
        touchAnchor = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchAnchor = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchAnchor = nil
    }

    // MARK: - Game loop

    private var stepInterval: TimeInterval {
        let eaten = Double(engine?.eaten ?? 0)
        return max(Tuning.fastestStep, Tuning.slowestStep - eaten * Tuning.speedUpPerFood)
    }

    override func update(_ currentTime: TimeInterval) {
        let delta = lastTime == 0 ? 0 : min(max(currentTime - lastTime, 0), 0.1)
        lastTime = currentTime

        guard let session = session, session.phase == .playing, !isDying else { return }

        accumulator += delta
        let interval = stepInterval
        if accumulator >= interval {
            // One move per frame at most, so a hitch never skips cells.
            accumulator = min(accumulator - interval, interval)
            tick(session: session)
        }
    }

    private func tick(session: GameSession) {
        guard let result = engine?.step() else { return }
        switch result {
        case .moved:
            render()
        case .ate:
            render()
            session.setScore((engine?.eaten ?? 0) * Tuning.pointsPerFood)
            Haptics.tap()
            if let head = segmentNodes.first {
                emitRing(at: head.position)
            }
        case .filled:
            render()
            session.setScore((engine?.eaten ?? 0) * Tuning.pointsPerFood)
            Haptics.success()
            session.finish()
        case .died:
            die()
        }
    }

    private func die() {
        isDying = true
        Haptics.failure()

        for node in segmentNodes where !node.isHidden {
            node.color = SKColor(hex: 0xFF5D73)
        }

        let origin = boardOrigin
        boardNode.run(.sequence([
            .moveBy(x: 7, y: 0, duration: 0.04),
            .moveBy(x: -14, y: 0, duration: 0.08),
            .moveBy(x: 10, y: 0, duration: 0.07),
            .move(to: origin, duration: 0.05)
        ]))

        run(.sequence([
            .wait(forDuration: 0.65),
            .run { [weak self] in
                self?.session?.finish()
            }
        ]))
    }

    private func emitRing(at position: CGPoint) {
        let ring = SKShapeNode(circleOfRadius: cell * 0.4)
        ring.fillColor = .clear
        ring.strokeColor = SKColor(hex: 0xC8FF6B)
        ring.lineWidth = 2
        ring.position = position
        ring.zPosition = 5
        boardNode.addChild(ring)
        ring.run(.sequence([
            .group([
                .scale(to: 2.2, duration: 0.28),
                .fadeOut(withDuration: 0.28)
            ]),
            .removeFromParent()
        ]))
    }
}
