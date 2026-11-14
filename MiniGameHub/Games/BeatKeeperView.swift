import SwiftUI
import UIKit

struct BeatKeeperView: View {
    @StateObject private var game: BeatGame
    private let mode: PlayMode
    @State private var pulse = false
    @State private var isPressed = false
    /// Changes whenever a scheduled run of beats should be abandoned.
    @State private var runToken = UUID()

    private let kind = GameKind.beat

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: BeatGame(mode: mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
            status: "Beat \(game.roundIndex + 1) of \(BeatGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                runToken = UUID()
                withAnimation(Motion.settle) {
                    game.restart()
                }
            }
        ) {
            GameColumn {
                Text(headline)
                    .bodyText(22, weight: .bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)

                pad

                HStack(spacing: 8) {
                    ForEach(0..<BeatGame.tapsNeeded, id: \.self) { index in
                        Circle()
                            .fill(index < progress ? Color.white : Theme.fillStrong)
                            .frame(width: 10, height: 10)
                    }
                }
                .accessibilityHidden(true)

                switch game.phase {
                case .ready:
                    Button("Play the beat") {
                        withAnimation(Motion.settle) {
                            playDemo()
                        }
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
                        .transition(Motion.rise)
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
        ZStack {
            // A ring that jumps outward on every beat that is played.
            Circle()
                .stroke(kind.accent.opacity(pulse ? 0.55 : 0), lineWidth: 3)
                .frame(width: 216, height: 216)
                .scaleEffect(pulse ? 1.1 : 1)
                .animation(pulse ? Motion.press : .easeOut(duration: 0.35), value: pulse)

            Circle()
                .fill(game.phase == .tapping
                      ? LinearGradient(colors: kind.colors, startPoint: .top, endPoint: .bottom)
                      : LinearGradient(colors: [Theme.fillStrong, Theme.fill], startPoint: .top, endPoint: .bottom))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 0.5))
                .frame(width: 216, height: 216)
                // The pad sinks under the finger the instant it lands, and
                // swells a touch on each demo beat.
                .scaleEffect(isPressed ? 0.94 : (pulse ? 1.03 : 1))
                .animation(isPressed || pulse ? Motion.press : Motion.quick, value: isPressed)
                .animation(pulse ? Motion.press : Motion.quick, value: pulse)
                .overlay(
                    Image(systemName: game.phase == .tapping ? "hand.tap.fill" : "metronome.fill")
                        .font(.system(size: 64, weight: .medium))
                        .foregroundColor(.white.opacity(game.phase == .tapping ? 1 : 0.7))
                        .scaleEffect(isPressed ? 0.94 : 1)
                        .animation(isPressed ? Motion.press : Motion.quick, value: isPressed)
                )
        }
            .padding(.vertical, 14)
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
                withAnimation(Motion.settle) {
                    game.next()
                }
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
                Feedback.tap()
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
        Feedback.tap()
        if game.phase == .revealed {
            if game.lastPoints >= 70 {
                Feedback.success()
            } else {
                Feedback.bump()
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
