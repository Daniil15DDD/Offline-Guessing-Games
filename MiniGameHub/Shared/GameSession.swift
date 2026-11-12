import SpriteKit
import Combine

/// State shared between a SpriteKit scene (which runs the game) and the
/// SwiftUI screen around it (which draws the score bar and the overlays).
final class GameSession: ObservableObject {
    enum Phase {
        case ready      // waiting for the first input
        case playing
        case paused
        case gameOver
    }

    @Published var score: Int = 0
    @Published var phase: Phase = .ready
    @Published var isNewBest: Bool = false
    @Published var canUndo: Bool = false

    // Each setter only publishes when the value really changes. Scenes call
    // these every frame, and SwiftUI should not redraw for nothing.

    func setScore(_ value: Int) {
        if score != value { score = value }
    }

    func setPhase(_ value: Phase) {
        if phase != value { phase = value }
    }

    func setCanUndo(_ value: Bool) {
        if canUndo != value { canUndo = value }
    }

    /// Clears the round and moves to `phase` (`.ready` or `.playing`).
    func startFresh(as phase: Phase, score: Int = 0) {
        setScore(score)
        setCanUndo(false)
        if isNewBest { isNewBest = false }
        setPhase(phase)
    }

    func begin() {
        setPhase(.playing)
    }

    func finish() {
        setPhase(.gameOver)
    }
}

/// What the SwiftUI layer needs from every game scene.
protocol HubGameScene: AnyObject {
    var session: GameSession? { get set }
    /// Throw away the current round and set up a new one.
    func restart()
}

/// Owns one scene and its session for the lifetime of a game screen.
final class SceneHost<S: SKScene & HubGameScene>: ObservableObject {
    let session = GameSession()
    let scene: S

    init(scene: S) {
        self.scene = scene
        scene.scaleMode = .resizeFill
        scene.session = session
    }
}
