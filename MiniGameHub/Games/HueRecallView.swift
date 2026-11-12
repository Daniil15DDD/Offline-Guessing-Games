import SwiftUI

struct HueRecallView: View {
    @StateObject private var game = DemoMode.hue()
    /// The first colour only appears once the player has pressed Start.
    @State private var started = DemoMode.isOn

    private let kind = GameKind.hue
    private let clock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        GameChrome(
            kind: kind,
            status: "Colour \(game.roundIndex + 1) of \(HueGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: { game.restart() }
        ) {
            GameColumn {
                if started {
                    roundContent
                } else {
                    intro
                }
            }
        }
        .onReceive(clock) { now in
            if started {
                game.tick(now: now)
            }
        }
    }

    private var intro: some View {
        VStack(spacing: 12) {
            Text("\(HueGame.rounds) colours to remember")
                .bodyText(20, weight: .heavy)
            Text("Each colour shows for \(Int(HueGame.showSeconds)) seconds. Then you rebuild it from memory with three sliders.")
                .caption()
                .multilineTextAlignment(.center)
            Button("Start") {
                started = true
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    @ViewBuilder
    private var roundContent: some View {
        switch game.phase {
        case .memorize:
            Text("Remember this colour")
                .bodyText(19, weight: .heavy)
            swatch(game.target, height: 240)
            Text("Hiding in \(Int(game.timeLeft.rounded(.up)))")
                .caption()

        case .recreate:
            Text("Now rebuild it from memory")
                .bodyText(19, weight: .heavy)
            swatch(game.guess, height: 180)
            VStack(spacing: 10) {
                slider("Hue", value: $game.guess.hue)
                slider("Saturation", value: $game.guess.saturation)
                slider("Brightness", value: $game.guess.brightness)
            }
            .panel()
            Button("Lock in") {
                game.lockIn()
                if game.lastPoints >= 70 {
                    Haptics.success()
                } else {
                    Haptics.bump()
                }
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))

        case .revealed:
            HStack(spacing: 10) {
                VStack(spacing: 6) {
                    swatch(game.target, height: 150)
                    Text("The colour").caption()
                }
                VStack(spacing: 6) {
                    swatch(game.guess, height: 150)
                    Text("Yours").caption()
                }
            }
            PointsBadge(points: game.lastPoints)
            Button(game.roundIndex + 1 >= HueGame.rounds ? "See result" : "Next colour") {
                game.next()
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
    }

    private func swatch(_ colour: HSB, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color(hue: colour.hue, saturation: colour.saturation, brightness: colour.brightness))
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
    }

    private func slider(_ name: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name).caption()
            Slider(value: value, in: 0...1)
                .tint(.white)
                .accessibilityLabel(name)
        }
    }
}
