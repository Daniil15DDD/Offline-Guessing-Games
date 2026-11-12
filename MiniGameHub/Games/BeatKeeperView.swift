import SwiftUI

struct BeatKeeperView: View {
    @StateObject private var game = BeatGame()
    @State private var pulse = false
    @State private var isPressed = false
    /// Changes whenever a scheduled run of beats should be abandoned.
    @State private var runToken = UUID()

    private let kind = GameKind.beat

    var body: some View {
        GameChrome(
            kind: kind,
            status: "Beat \(game.roundIndex + 1) of \(BeatGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                runToken = UUID()
                game.restart()
            }
        ) {
            GameColumn {
                Text(headline)
                    .bodyText(20, weight: .heavy)
                    .multilineTextAlignment(.center)

                pad

                HStack(spacing: 8) {
                    ForEach(0..<BeatGame.tapsNeeded, id: \.self) { index in
                        Circle()
                            .fill(index < progress ? kind.accent : Theme.surfaceRaised)
                            .frame(width: 12, height: 12)
                    }
                }
                .accessibilityHidden(true)

                switch game.phase {
                case .ready:
                    Button("Play the beat") {
                        playDemo()
                    }
                    .buttonStyle(PrimaryButtonStyle(kind: kind))
                    Text("You will hear and see \(BeatGame.demoBeats) beats. Then tap \(BeatGame.tapsNeeded) times at the same speed.")
                        .caption()
                        .multilineTextAlignment(.center)
                case .listening:
                    Text("Listen...").caption()
                case .tapping:
                    Text("Tap the pad \(BeatGame.tapsNeeded - game.taps.count) more times").caption()
                case .revealed:
                    reveal
                }
            }
        }
        .onDisappear {
            runToken = UUID()
            TonePlayer.shared.stop()
        }
    }

    private var headline: String {
        switch game.phase {
        case .ready: return "Ready?"
        case .listening: return "Feel the beat"
        case .tapping: return "Your turn. Keep it going."
        case .revealed: return "How close were you?"
        }
    }

    private var progress: Int {
        game.phase == .listening ? game.beatsPlayed : game.taps.count
    }

    private var pad: some View {
        Circle()
            .fill(game.phase == .tapping ? kind.gradient : LinearGradient(colors: [Theme.surfaceRaised, Theme.surface], startPoint: .top, endPoint: .bottom))
            .frame(width: 210, height: 210)
            .scaleEffect(pulse || isPressed ? 1.08 : 1)
            .overlay(
                Image(systemName: game.phase == .tapping ? "hand.tap.fill" : "metronome.fill")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            )
            .padding(.vertical, 10)
            .contentShape(Circle())
            .gesture(
                // Fires on touch down, which is when a tap is felt.
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        registerTap()
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
            .accessibilityLabel("Tap pad")
            .accessibilityAddTraits(.isButton)
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            Text("The beat was \(Int(game.targetBPM.rounded())) per minute. You tapped \(Int(game.tappedBPM.rounded())).")
                .bodyText(15)
                .multilineTextAlignment(.center)
            PointsBadge(points: game.lastPoints)
            Button(game.roundIndex + 1 >= BeatGame.rounds ? "See result" : "Next beat") {
                game.next()
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    private func playDemo() {
        let token = UUID()
        runToken = token
        let interval = game.interval
        game.startListening()
        for beat in 0..<BeatGame.demoBeats {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + interval * Double(beat)) {
                guard runToken == token else { return }
                game.beatPlayed()
                TonePlayer.shared.play(frequency: 880, duration: 0.06)
                Haptics.tap()
                flash()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + interval * Double(BeatGame.demoBeats)) {
            guard runToken == token else { return }
            game.finishListening()
        }
    }

    private func registerTap() {
        guard game.phase == .tapping else { return }
        game.tap(at: ProcessInfo.processInfo.systemUptime)
        TonePlayer.shared.play(frequency: 660, duration: 0.05)
        Haptics.tap()
        if game.phase == .revealed {
            if game.lastPoints >= 70 {
                Haptics.success()
            } else {
                Haptics.bump()
            }
        }
    }

    private func flash() {
        pulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            pulse = false
        }
    }
}
