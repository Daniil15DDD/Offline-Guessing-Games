import SwiftUI
import SpriteKit

struct RunnerGameView: View {
    @StateObject private var host = SceneHost(
        scene: RunnerScene(size: CGSize(width: 390, height: 640))
    )

    var body: some View {
        GameScreen(
            kind: .runner,
            session: host.session,
            onRestart: { host.scene.restart() }
        ) {
            SpriteView(scene: host.scene, isPaused: host.session.phase == .paused)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}
