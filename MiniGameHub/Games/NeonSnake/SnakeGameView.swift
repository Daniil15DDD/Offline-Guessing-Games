import SwiftUI
import SpriteKit

struct SnakeGameView: View {
    @StateObject private var host = SceneHost(
        scene: SnakeScene(size: CGSize(width: 390, height: 640))
    )

    var body: some View {
        GameScreen(
            kind: .snake,
            session: host.session,
            onRestart: { host.scene.restart() }
        ) {
            SpriteView(scene: host.scene, isPaused: host.session.phase == .paused)
        }
    }
}
