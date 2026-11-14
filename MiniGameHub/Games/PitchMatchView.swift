import SwiftUI

struct PitchMatchView: View {
    @StateObject private var game: PitchGame
    private let mode: PlayMode

    private let kind = GameKind.pitch

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: PitchGame(mode: mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
            status: "Note \(game.roundIndex + 1) of \(PitchGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                withAnimation(Motion.settle) {
                    game.restart()
                }
            }
        ) {
            GameColumn {
                VStack(spacing: 6) {
                    Image(systemName: "waveform")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(LinearGradient(colors: kind.colors, startPoint: .top, endPoint: .bottom))
                        .accessibilityHidden(true)
                    Text("Match the note by ear")
                        .bodyText(22, weight: .bold)
                    Text("Make sure your sound is on.")
                        .caption()
                }
                .padding(.vertical, 6)

                Button {
                    if game.useListen() {
                        TonePlayer.shared.play(frequency: game.targetHz, duration: 1.2)
                    }
                } label: {
                    Label("Hear the note (\(game.listensLeft) left)", systemImage: "speaker.wave.2.fill")
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(game.revealed || game.listensLeft == 0)

                VStack(spacing: 12) {
                    Text("YOUR NOTE").eyebrow()
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.down").foregroundColor(Theme.textSecondary)
                        Slider(value: $game.slider, in: 0...1)
                            .tint(kind.accent)
                            .disabled(game.revealed)
                            .accessibilityLabel("Pitch of your note")
                        Image(systemName: "arrow.up").foregroundColor(Theme.textSecondary)
                    }
                    Button {
                        TonePlayer.shared.play(frequency: game.guessHz, duration: 0.9)
                    } label: {
                        Label("Hear mine", systemImage: "play.fill")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .panel()

                if game.revealed {
                    reveal
                        .transition(Motion.rise)
                } else {
                    Button("Lock in") {
                        TonePlayer.shared.stop()
                        withAnimation(Motion.settle) {
                            game.lockIn()
                        }
                        if game.lastPoints >= 70 {
                            Feedback.success()
                        } else {
                            Feedback.bump()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(kind: kind))
                    Text("Slide lower or higher, listen to your note, and lock in when the two sound the same.")
                        .caption()
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onDisappear {
            TonePlayer.shared.stop()
        }
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            Text("The note was \(Int(game.targetHz.rounded())) Hz. Yours was \(Int(game.guessHz.rounded())) Hz.")
                .bodyText(15)
                .multilineTextAlignment(.center)
            Text("Off by \(NumberText.trimmed(game.semitonesOff, maxDecimals: 1)) semitones")
                .caption()
            Button {
                TonePlayer.shared.play(frequency: game.targetHz, duration: 0.9)
            } label: {
                Label("Hear the real note", systemImage: "speaker.wave.2.fill")
            }
            .buttonStyle(SecondaryButtonStyle())
            PointsBadge(points: game.lastPoints)
            Button(game.roundIndex + 1 >= PitchGame.rounds ? "See result" : "Next note") {
                TonePlayer.shared.stop()
                withAnimation(Motion.settle) {
                    game.next()
                }
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }
}
