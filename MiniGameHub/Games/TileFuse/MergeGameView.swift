import SwiftUI
import SpriteKit

struct MergeGameView: View {
    @StateObject private var host = SceneHost(
        scene: MergeScene(size: CGSize(width: 390, height: 640))
    )
    @State private var confirmNewGame = false

    var body: some View {
        GameScreen(
            kind: .merge,
            session: host.session,
            onRestart: { host.scene.restart() }
        ) {
            ZStack(alignment: .bottom) {
                SpriteView(scene: host.scene)

                HStack(spacing: 12) {
                    Button {
                        host.scene.undo()
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(!host.session.canUndo)
                    .opacity(host.session.canUndo ? 1 : 0.4)

                    Button {
                        confirmNewGame = true
                    } label: {
                        Label("New game", systemImage: "plus")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .confirmationDialog(
            "Start a new game?",
            isPresented: $confirmNewGame,
            titleVisibility: .visible
        ) {
            Button("New game", role: .destructive) {
                host.scene.restart()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current board will be cleared.")
        }
    }
}
