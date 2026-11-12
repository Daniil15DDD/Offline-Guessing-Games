import SpriteKit

/// Moon Dash: a one-button endless runner.
///
/// Everything is drawn with shapes and simulated by hand (no physics engine),
/// which keeps the jump feel exact and the collisions forgiving. Distances
/// are measured in "units": one unit is one point on a 390 point wide
/// screen, so the game plays the same on every iPhone.
final class RunnerScene: SKScene, HubGameScene {

    weak var session: GameSession?

    // MARK: Tuning (units, seconds)

    private enum Tuning {
        static let gravity: CGFloat = -2100
        static let jumpVelocity: CGFloat = 760
        static let doubleJumpVelocity: CGFloat = 640
        /// Letting go early caps the upward speed, giving a short hop.
        static let jumpCutVelocity: CGFloat = 260
        static let startSpeed: CGFloat = 270
        static let maxSpeed: CGFloat = 760
        static let acceleration: CGFloat = 5.5
        static let idleScrollSpeed: CGFloat = 45
        static let unitsPerPoint: CGFloat = 14
        static let playerWidth: CGFloat = 36
        static let bodyHeight: CGFloat = 32
        static let legHeight: CGFloat = 9
    }

    private enum ObstacleKind {
        case rock, wideRock, crystal, highDrone, lowDrone
    }

    private struct Obstacle {
        let node: SKNode
        let width: CGFloat
        let height: CGFloat
        /// Height of the bottom edge above the ground.
        let lift: CGFloat
        let bobAmplitude: CGFloat
        let bobPhase: CGFloat
    }

    private struct Scenery {
        let node: SKNode
        let parallax: CGFloat
        let halfWidth: CGFloat
    }

    // MARK: Layout

    private var builtSize: CGSize = .zero
    private var unit: CGFloat = 1
    private var groundY: CGFloat = 0
    private var playerX: CGFloat = 0
    private var scenerySpan: CGFloat = 0

    // MARK: Run state

    private var lastTime: TimeInterval = 0
    private var runSpeed: CGFloat = 0
    private var distance: CGFloat = 0
    private var distanceToNextSpawn: CGFloat = 0
    private var playerLift: CGFloat = 0
    private var velocityY: CGFloat = 0
    private var jumpsUsed = 0
    private var isDead = false
    private var stride: CGFloat = 0
    private var clock: CGFloat = 0

    // MARK: Nodes

    private var player = SKNode()
    private var playerShell = SKShapeNode()
    private var frontLeg = SKSpriteNode()
    private var backLeg = SKSpriteNode()
    private var shadow = SKShapeNode()
    private var obstacles: [Obstacle] = []
    private var scenery: [Scenery] = []

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        rebuildIfNeeded()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        rebuildIfNeeded()
    }

    private func rebuildIfNeeded() {
        guard size.width > 100, size.height > 240 else { return }
        let changed = abs(size.width - builtSize.width) > 0.5
            || abs(size.height - builtSize.height) > 0.5
        guard changed else { return }
        buildWorld()
        resetRun()
    }

    func restart() {
        guard builtSize != .zero else { return }
        resetRun()
    }

    private func resetRun() {
        removeAllActions()
        for obstacle in obstacles {
            obstacle.node.removeFromParent()
        }
        obstacles.removeAll()

        runSpeed = Tuning.startSpeed * unit
        distance = 0
        distanceToNextSpawn = size.width * 0.9
        playerLift = 0
        velocityY = 0
        jumpsUsed = 0
        isDead = false
        stride = 0

        player.removeAllActions()
        player.zRotation = 0
        player.alpha = 1
        playerShell.fillColor = SKColor(hex: 0xF2F4FF)
        placePlayer()

        session?.startFresh(as: .ready)
    }

    // MARK: - World building

    private func buildWorld() {
        removeAllChildren()
        removeAllActions()
        obstacles.removeAll()
        scenery.removeAll()

        builtSize = size
        unit = size.width / 390
        groundY = max(size.height * 0.27, 96 * unit)
        playerX = size.width * 0.2
        scenerySpan = size.width + 360 * unit
        backgroundColor = SKColor(hex: 0x070A1A)

        let skyTop = max(size.height, groundY + 1)

        let sky = SKSpriteNode(texture: TextureFactory.verticalGradient(
            height: size.height,
            top: SKColor(hex: 0x05071A),
            bottom: SKColor(hex: 0x2A2F6B)
        ))
        sky.anchorPoint = .zero
        sky.size = size
        sky.zPosition = -100
        addChild(sky)

        for _ in 0..<46 {
            let side = CGFloat.random(in: 1.2...2.6) * unit
            let star = SKSpriteNode(color: .white, size: CGSize(width: side, height: side))
            star.alpha = CGFloat.random(in: 0.25...0.9)
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: groundY...skyTop)
            )
            star.zPosition = -95
            addChild(star)
        }

        let planet = SKShapeNode(circleOfRadius: 28 * unit)
        planet.fillColor = SKColor(hex: 0x7FB8FF)
        planet.strokeColor = .clear
        planet.position = CGPoint(x: size.width * 0.78, y: groundY + (skyTop - groundY) * 0.74)
        planet.zPosition = -90
        addChild(planet)

        let ring = SKShapeNode(ellipseOf: CGSize(width: 92 * unit, height: 20 * unit))
        ring.fillColor = .clear
        ring.strokeColor = SKColor(hex: 0xD6E6FF, alpha: 0.75)
        ring.lineWidth = 2.5 * unit
        ring.zRotation = -0.35
        planet.addChild(ring)

        addHills(count: 4, color: SKColor(hex: 0x1B2150), width: 250...320, height: 110...170,
                 parallax: 0.12, z: -80)
        addHills(count: 5, color: SKColor(hex: 0x262D63), width: 180...260, height: 55...95,
                 parallax: 0.3, z: -70)

        let ground = SKSpriteNode(
            color: SKColor(hex: 0x2B3157),
            size: CGSize(width: size.width, height: groundY)
        )
        ground.anchorPoint = .zero
        ground.zPosition = -20
        addChild(ground)

        let edge = SKSpriteNode(
            color: SKColor(hex: 0x9AA3D9),
            size: CGSize(width: size.width, height: 3 * unit)
        )
        edge.anchorPoint = CGPoint(x: 0, y: 1)
        edge.position = CGPoint(x: 0, y: groundY)
        edge.zPosition = -19
        addChild(edge)

        // Craters scroll at full speed, which is what sells the motion.
        let craterCount = 7
        for index in 0..<craterCount {
            let width = CGFloat.random(in: 30...72) * unit
            let crater = SKShapeNode(ellipseOf: CGSize(width: width, height: width * 0.22))
            crater.fillColor = SKColor(hex: 0x1F2446)
            crater.strokeColor = .clear
            crater.position = CGPoint(
                x: scenerySpan * (CGFloat(index) + CGFloat.random(in: 0.1...0.9)) / CGFloat(craterCount),
                y: CGFloat.random(in: (groundY * 0.15)...(groundY - 16 * unit))
            )
            crater.zPosition = -18
            addChild(crater)
            scenery.append(Scenery(node: crater, parallax: 1, halfWidth: width / 2))
        }

        shadow = SKShapeNode(ellipseOf: CGSize(width: 34 * unit, height: 7 * unit))
        shadow.fillColor = SKColor(white: 0, alpha: 0.35)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: playerX, y: groundY - 3 * unit)
        shadow.zPosition = 5
        addChild(shadow)

        buildPlayer()
    }

    private func addHills(
        count: Int,
        color: SKColor,
        width: ClosedRange<CGFloat>,
        height: ClosedRange<CGFloat>,
        parallax: CGFloat,
        z: CGFloat
    ) {
        for index in 0..<count {
            let hillWidth = CGFloat.random(in: width) * unit
            let hillHeight = CGFloat.random(in: height) * unit
            // An ellipse centred on the horizon: the ground hides its lower half.
            let hill = SKShapeNode(ellipseOf: CGSize(width: hillWidth, height: hillHeight * 2))
            hill.fillColor = color
            hill.strokeColor = .clear
            hill.position = CGPoint(
                x: scenerySpan * (CGFloat(index) + CGFloat.random(in: 0.1...0.6)) / CGFloat(count),
                y: groundY
            )
            hill.zPosition = z
            addChild(hill)
            scenery.append(Scenery(node: hill, parallax: parallax, halfWidth: hillWidth / 2))
        }
    }

    private func buildPlayer() {
        let width = Tuning.playerWidth * unit
        let bodyHeight = Tuning.bodyHeight * unit
        let legHeight = Tuning.legHeight * unit

        // The node's origin sits between the feet.
        player = SKNode()
        player.zPosition = 10

        let legSize = CGSize(width: 8 * unit, height: legHeight + 3 * unit)
        backLeg = SKSpriteNode(color: SKColor(hex: 0x9AA3D9), size: legSize)
        backLeg.anchorPoint = CGPoint(x: 0.5, y: 0)
        backLeg.position = CGPoint(x: -width * 0.2, y: 0)
        player.addChild(backLeg)

        frontLeg = SKSpriteNode(color: SKColor(hex: 0xC3CAF0), size: legSize)
        frontLeg.anchorPoint = CGPoint(x: 0.5, y: 0)
        frontLeg.position = CGPoint(x: width * 0.2, y: 0)
        player.addChild(frontLeg)

        let pack = SKShapeNode(
            rect: CGRect(x: -width / 2 - 5 * unit, y: legHeight + bodyHeight * 0.2,
                         width: 8 * unit, height: bodyHeight * 0.5),
            cornerRadius: 3 * unit
        )
        pack.fillColor = SKColor(hex: 0x9AA3D9)
        pack.strokeColor = .clear
        player.addChild(pack)

        playerShell = SKShapeNode(
            rect: CGRect(x: -width / 2, y: legHeight, width: width, height: bodyHeight),
            cornerRadius: 10 * unit
        )
        playerShell.fillColor = SKColor(hex: 0xF2F4FF)
        playerShell.strokeColor = .clear
        player.addChild(playerShell)

        let visor = SKShapeNode(
            rect: CGRect(x: -width * 0.06, y: legHeight + bodyHeight * 0.42,
                         width: width * 0.5, height: bodyHeight * 0.36),
            cornerRadius: 5 * unit
        )
        visor.fillColor = SKColor(hex: 0x141A38)
        visor.strokeColor = .clear
        player.addChild(visor)

        let eye = SKShapeNode(circleOfRadius: 2.6 * unit)
        eye.fillColor = SKColor(hex: 0x5CF2E3)
        eye.strokeColor = .clear
        eye.position = CGPoint(x: width * 0.3, y: legHeight + bodyHeight * 0.6)
        player.addChild(eye)

        let antenna = SKSpriteNode(
            color: SKColor(hex: 0xF2F4FF),
            size: CGSize(width: 2 * unit, height: 9 * unit)
        )
        antenna.anchorPoint = CGPoint(x: 0.5, y: 0)
        antenna.position = CGPoint(x: -width * 0.2, y: legHeight + bodyHeight - unit)
        player.addChild(antenna)

        let beacon = SKShapeNode(circleOfRadius: 3 * unit)
        beacon.fillColor = SKColor(hex: 0xFF5D73)
        beacon.strokeColor = .clear
        beacon.position = CGPoint(x: -width * 0.2, y: legHeight + bodyHeight + 10 * unit)
        player.addChild(beacon)

        addChild(player)
        placePlayer()
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let session = session, builtSize != .zero else { return }
        switch session.phase {
        case .ready:
            session.begin()
            jump()
        case .playing:
            jump()
        case .paused, .gameOver:
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        cutJump()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cutJump()
    }

    private func jump() {
        guard !isDead, jumpsUsed < 2 else { return }
        let isDoubleJump = jumpsUsed == 1 || playerLift > 0
        if isDoubleJump {
            // Falling off nothing is impossible here, so any mid-air jump is
            // the second one.
            jumpsUsed = 2
            velocityY = Tuning.doubleJumpVelocity * unit
            emitPuff()
        } else {
            jumpsUsed = 1
            velocityY = Tuning.jumpVelocity * unit
        }
        Haptics.tap()
    }

    private func cutJump() {
        let cap = Tuning.jumpCutVelocity * unit
        if velocityY > cap {
            velocityY = cap
        }
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        let delta: CGFloat
        if lastTime == 0 {
            delta = 0
        } else {
            // Clamp so a hitch or a resume never teleports the world.
            delta = CGFloat(min(max(currentTime - lastTime, 0), 1.0 / 30.0))
        }
        lastTime = currentTime

        guard let session = session, builtSize != .zero else { return }
        clock += delta

        switch session.phase {
        case .ready:
            scrollScenery(by: Tuning.idleScrollSpeed * unit * delta)
            stride += delta * 0.5
            placePlayer()
        case .playing:
            if !isDead {
                step(delta, session: session)
            }
        case .paused, .gameOver:
            break
        }
    }

    private func step(_ delta: CGFloat, session: GameSession) {
        runSpeed = min(Tuning.maxSpeed * unit, runSpeed + Tuning.acceleration * unit * delta)
        let travel = runSpeed * delta
        distance += travel
        stride += delta * (runSpeed / (Tuning.startSpeed * unit))

        // Player
        if playerLift > 0 || velocityY > 0 {
            velocityY += Tuning.gravity * unit * delta
            playerLift += velocityY * delta
            if playerLift <= 0 {
                playerLift = 0
                velocityY = 0
                jumpsUsed = 0
            }
        }
        placePlayer()

        // World
        scrollScenery(by: travel)
        moveObstacles(by: travel)

        distanceToNextSpawn -= travel
        if distanceToNextSpawn <= 0 {
            spawnObstacle(score: session.score)
        }

        session.setScore(Int(distance / (Tuning.unitsPerPoint * unit)))

        if collides() {
            die()
        }
    }

    private func placePlayer() {
        player.position = CGPoint(x: playerX, y: groundY + playerLift)

        let airborne = playerLift > 0
        if airborne {
            let tilt = max(-1, min(1, velocityY / (Tuning.jumpVelocity * unit)))
            player.zRotation = tilt * 0.16
            frontLeg.position.y = 3 * unit
            backLeg.position.y = 3 * unit
        } else {
            player.zRotation = 0
            // Two-frame run cycle.
            let frontUp = Int(stride * 11) % 2 == 0
            frontLeg.position.y = frontUp ? 4 * unit : 0
            backLeg.position.y = frontUp ? 0 : 4 * unit
        }

        let shrink = max(0.45, 1 - playerLift / (220 * unit))
        shadow.xScale = shrink
        shadow.alpha = shrink
    }

    private func scrollScenery(by travel: CGFloat) {
        for item in scenery {
            item.node.position.x -= travel * item.parallax
            if item.node.position.x < -item.halfWidth {
                item.node.position.x += scenerySpan
            }
        }
    }

    private func moveObstacles(by travel: CGFloat) {
        var index = 0
        while index < obstacles.count {
            let obstacle = obstacles[index]
            obstacle.node.position.x -= travel
            if obstacle.bobAmplitude > 0 {
                obstacle.node.position.y = groundY + obstacle.lift
                    + sin(clock * 4 + obstacle.bobPhase) * obstacle.bobAmplitude
            }
            if obstacle.node.position.x < -obstacle.width {
                obstacle.node.removeFromParent()
                obstacles.remove(at: index)
            } else {
                index += 1
            }
        }
    }

    // MARK: - Obstacles

    private func spawnObstacle(score: Int) {
        var choices: [ObstacleKind] = [.rock, .rock, .rock]
        if score > 120 {
            choices += [.wideRock, .highDrone]
        }
        if score > 350 {
            choices += [.crystal, .lowDrone, .highDrone]
        }
        let kind = choices.randomElement() ?? .rock

        let obstacle: Obstacle
        switch kind {
        case .rock:
            let width = CGFloat.random(in: 28...44) * unit
            let height = CGFloat.random(in: 26...48) * unit
            obstacle = Obstacle(node: makeRock(width: width, height: height),
                                width: width, height: height, lift: 0,
                                bobAmplitude: 0, bobPhase: 0)
        case .wideRock:
            let width = CGFloat.random(in: 62...84) * unit
            let height = CGFloat.random(in: 28...38) * unit
            obstacle = Obstacle(node: makeRock(width: width, height: height),
                                width: width, height: height, lift: 0,
                                bobAmplitude: 0, bobPhase: 0)
        case .crystal:
            let width = CGFloat.random(in: 24...30) * unit
            let height = CGFloat.random(in: 70...88) * unit
            obstacle = Obstacle(node: makeCrystal(width: width, height: height),
                                width: width, height: height, lift: 0,
                                bobAmplitude: 0, bobPhase: 0)
        case .highDrone:
            // High enough to run under. Jumping into it is the mistake.
            let width = 44 * unit
            let height = 20 * unit
            obstacle = Obstacle(node: makeDrone(width: width, height: height),
                                width: width, height: height, lift: 62 * unit,
                                bobAmplitude: 5 * unit,
                                bobPhase: CGFloat.random(in: 0...6))
        case .lowDrone:
            // Too low to run under. Jump over it.
            let width = 44 * unit
            let height = 20 * unit
            obstacle = Obstacle(node: makeDrone(width: width, height: height),
                                width: width, height: height, lift: 16 * unit,
                                bobAmplitude: 5 * unit,
                                bobPhase: CGFloat.random(in: 0...6))
        }

        obstacle.node.position = CGPoint(
            x: size.width + obstacle.width / 2 + 20 * unit,
            y: groundY + obstacle.lift
        )
        obstacle.node.zPosition = 0
        addChild(obstacle.node)
        obstacles.append(obstacle)

        // The gap is measured in seconds so it stays fair as speed rises.
        // A full jump lasts about 0.72 s, so 0.9 s always leaves room to land.
        let longest = max(1.25, 1.75 - CGFloat(score) / 1200)
        let gapTime = CGFloat.random(in: 0.9...longest)
        distanceToNextSpawn = runSpeed * gapTime + obstacle.width
    }

    private func makeRock(width: CGFloat, height: CGFloat) -> SKNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: 0))
        path.addLine(to: CGPoint(x: -width * 0.38, y: height * 0.62))
        path.addLine(to: CGPoint(x: -width * 0.08, y: height))
        path.addLine(to: CGPoint(x: width * 0.26, y: height * 0.82))
        path.addLine(to: CGPoint(x: width / 2, y: height * 0.3))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.closeSubpath()

        let rock = SKShapeNode(path: path)
        rock.fillColor = SKColor(hex: 0x6B739F)
        rock.strokeColor = SKColor(hex: 0xA9B1DE)
        rock.lineWidth = 1.5 * unit
        rock.lineJoin = .round
        return rock
    }

    private func makeCrystal(width: CGFloat, height: CGFloat) -> SKNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: 0))
        path.addLine(to: CGPoint(x: -width * 0.3, y: height * 0.72))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.72))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.closeSubpath()

        let crystal = SKShapeNode(path: path)
        crystal.fillColor = SKColor(hex: 0x3FD9CE)
        crystal.strokeColor = SKColor(hex: 0xB8FFF8)
        crystal.lineWidth = 1.5 * unit
        crystal.lineJoin = .round

        let facet = SKShapeNode(rect: CGRect(x: -unit, y: 0, width: 2 * unit, height: height * 0.9))
        facet.fillColor = SKColor(hex: 0xB8FFF8, alpha: 0.6)
        facet.strokeColor = .clear
        crystal.addChild(facet)
        return crystal
    }

    private func makeDrone(width: CGFloat, height: CGFloat) -> SKNode {
        // Origin at the bottom centre, like the ground obstacles.
        let drone = SKNode()

        let hull = SKShapeNode(ellipseOf: CGSize(width: width, height: height * 0.7))
        hull.fillColor = SKColor(hex: 0xFF5D73)
        hull.strokeColor = SKColor(hex: 0xFFB3BE)
        hull.lineWidth = 1.5 * unit
        hull.position = CGPoint(x: 0, y: height * 0.35)
        drone.addChild(hull)

        let dome = SKShapeNode(ellipseOf: CGSize(width: width * 0.42, height: height * 0.7))
        dome.fillColor = SKColor(hex: 0xFFD9DE)
        dome.strokeColor = .clear
        dome.position = CGPoint(x: 0, y: height * 0.65)
        dome.zPosition = -1
        drone.addChild(dome)

        let light = SKShapeNode(circleOfRadius: 2.5 * unit)
        light.fillColor = SKColor(hex: 0xFFF3A6)
        light.strokeColor = .clear
        light.position = CGPoint(x: -width * 0.28, y: height * 0.35)
        light.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.2, duration: 0.25),
            .fadeAlpha(to: 1, duration: 0.25)
        ])))
        drone.addChild(light)
        return drone
    }

    // MARK: - Collision

    private func collides() -> Bool {
        let width = Tuning.playerWidth * unit
        let playerTop = (Tuning.legHeight + Tuning.bodyHeight) * unit
        // Hit boxes are smaller than the art so near misses feel fair.
        let playerBox = CGRect(
            x: playerX - width / 2 + 5 * unit,
            y: groundY + playerLift + 4 * unit,
            width: width - 10 * unit,
            height: playerTop - 9 * unit
        )
        let inset = 4 * unit
        for obstacle in obstacles {
            let box = CGRect(
                x: obstacle.node.position.x - obstacle.width / 2 + inset,
                y: obstacle.node.position.y,
                width: obstacle.width - inset * 2,
                height: obstacle.height - inset
            )
            if playerBox.intersects(box) {
                return true
            }
        }
        return false
    }

    private func die() {
        isDead = true
        Haptics.failure()
        playerShell.fillColor = SKColor(hex: 0xFF5D73)

        let flash = SKSpriteNode(color: .white, size: size)
        flash.anchorPoint = .zero
        flash.alpha = 0.55
        flash.zPosition = 50
        addChild(flash)
        flash.run(.sequence([.fadeOut(withDuration: 0.25), .removeFromParent()]))

        player.run(.group([
            .rotate(byAngle: 0.9, duration: 0.3),
            .moveBy(x: -14 * unit, y: 18 * unit, duration: 0.3)
        ]))

        run(.sequence([
            .wait(forDuration: 0.55),
            .run { [weak self] in
                self?.session?.finish()
            }
        ]))
    }

    private func emitPuff() {
        let puff = SKShapeNode(circleOfRadius: 9 * unit)
        puff.fillColor = SKColor(hex: 0x5CF2E3, alpha: 0.7)
        puff.strokeColor = .clear
        puff.position = CGPoint(x: playerX - 6 * unit, y: groundY + playerLift)
        puff.zPosition = 9
        addChild(puff)
        puff.run(.sequence([
            .group([
                .scale(to: 1.9, duration: 0.25),
                .fadeOut(withDuration: 0.25),
                .moveBy(x: -18 * unit, y: -10 * unit, duration: 0.25)
            ]),
            .removeFromParent()
        ]))
    }
}
