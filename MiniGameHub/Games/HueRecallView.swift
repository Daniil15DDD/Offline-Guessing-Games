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
            Image("hub_hue")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .accessibilityHidden(true)
            Text("\(HueGame.rounds) colours to remember")
                .bodyText(20, weight: .heavy)
            Text("You are shown a colour for \(Int(HueGame.showSeconds)) seconds. Then it disappears and you pick the same colour from memory.")
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
            ZStack {
                swatch(game.target, height: 300)
                // Countdown ring.
                Circle()
                    .stroke(Color.black.opacity(0.25), lineWidth: 8)
                    .frame(width: 74, height: 74)
                Circle()
                    .trim(from: 0, to: CGFloat(game.timeLeft / HueGame.showSeconds))
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 74, height: 74)
                Text("\(Int(game.timeLeft.rounded(.up)))")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 3)
            }

        case .recreate:
            Text("Now match it from memory")
                .bodyText(19, weight: .heavy)
            swatch(game.guess, height: 96)
            ColourPad(colour: $game.guess)
                .frame(height: 220)
            HueStrip(hue: $game.guess.hue)
                .frame(height: 34)
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
            HStack(spacing: 0) {
                compare("The colour", game.target)
                compare("Yours", game.guess)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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

    private func compare(_ label: String, _ colour: HSB) -> some View {
        ZStack(alignment: .bottom) {
            Color(hue: colour.hue, saturation: colour.saturation, brightness: colour.brightness)
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.black.opacity(0.4)))
                .padding(.bottom, 12)
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
    }
}

/// A square to pick how strong (left to right) and how bright (bottom to
/// top) the colour is. Drag anywhere inside it.
private struct ColourPad: View {
    @Binding var colour: HSB

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack(alignment: .topLeading) {
                Color(hue: colour.hue, saturation: 1, brightness: 1)
                LinearGradient(colors: [.white, .white.opacity(0)], startPoint: .leading, endPoint: .trailing)
                LinearGradient(colors: [.black.opacity(0), .black], startPoint: .top, endPoint: .bottom)

                Circle()
                    .fill(Color(hue: colour.hue, saturation: colour.saturation, brightness: colour.brightness))
                    .frame(width: 30, height: 30)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .shadow(color: .black.opacity(0.4), radius: 3)
                    .position(
                        x: size.width * CGFloat(colour.saturation),
                        y: size.height * CGFloat(1 - colour.brightness)
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        guard size.width > 0, size.height > 0 else { return }
                        colour.saturation = Double(min(max(drag.location.x / size.width, 0), 1))
                        colour.brightness = Double(1 - min(max(drag.location.y / size.height, 0), 1))
                    }
            )
        }
        .accessibilityLabel("Colour strength and brightness")
    }
}

/// A rainbow bar to pick the hue. Drag along it.
private struct HueStrip: View {
    @Binding var hue: Double

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: stride(from: 0.0, through: 1.0, by: 1.0 / 12).map {
                        Color(hue: min($0, 1), saturation: 1, brightness: 1)
                    },
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(Capsule())

                Circle()
                    .fill(Color(hue: hue, saturation: 1, brightness: 1))
                    .frame(width: size.height + 4, height: size.height + 4)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .shadow(color: .black.opacity(0.4), radius: 3)
                    .position(x: size.width * CGFloat(hue), y: size.height / 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        guard size.width > 0 else { return }
                        // Stop just short of 1, which is the same red as 0.
                        hue = Double(min(max(drag.location.x / size.width, 0), 0.999))
                    }
            )
        }
        .accessibilityLabel("Hue")
    }
}
