import SwiftUI

struct GettingWarmerView: View {
    @StateObject private var game: GlobeGame
    private let mode: PlayMode
    @State private var text = ""
    @State private var latitude = 20.0
    @State private var longitude = 10.0
    /// Where the globe was pointing when the current drag began.
    @State private var dragStart: (latitude: Double, longitude: Double)?
    @State private var zoom = 1.0

    private let kind = GameKind.globe

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: GlobeGame(mode: mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
            status: game.guesses.isEmpty ? "Find the mystery country" : "\(game.guesses.count) guessed",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                text = ""
                game.restart()
            }
        ) {
            GameColumn {
                globe

                HeatLegend()

                if game.isOver {
                    reveal
                } else {
                    entry
                }

                ForEach(game.ranked) { guess in
                    GuessRow(guess: guess)
                }
            }
        }
    }

    // MARK: - Globe

    private var fills: [Int: Color] {
        var result: [Int: Color] = [:]
        for guess in game.guesses {
            result[guess.id] = guess.isCorrect ? Heat.found : Heat.color(guess.heat)
        }
        if game.isOver && !game.solved {
            result[game.target.id] = Heat.found
        }
        return result
    }

    private var globe: some View {
        GlobeCanvas(latitude: latitude, longitude: longitude, zoom: zoom, fills: fills)
            .frame(height: 310)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .contentShape(Rectangle())
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 6) {
                    zoomButton("plus", enabled: zoom < 3.9) {
                        zoom = min(4, zoom * 1.6)
                    }
                    zoomButton("minus", enabled: zoom > 1.01) {
                        zoom = max(1, zoom / 1.6)
                    }
                }
                .padding(8)
            }
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { drag in
                        let start = dragStart ?? (latitude, longitude)
                        dragStart = start
                        // Zoomed in, the same drag turns the globe less.
                        let sensitivity = 0.45 / zoom
                        longitude = start.longitude - Double(drag.translation.width) * sensitivity
                        latitude = min(80, max(-80, start.latitude + Double(drag.translation.height) * sensitivity))
                    }
                    .onEnded { _ in
                        dragStart = nil
                    }
            )
            .accessibilityLabel("Globe. Guessed countries are coloured by how close they are.")
    }

    private func zoomButton(_ symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                action()
            }
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .heavy))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.black.opacity(0.5)))
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
        .accessibilityLabel(symbol == "plus" ? "Zoom in" : "Zoom out")
    }

    /// Spins the globe so a country faces the viewer, the short way round.
    private func face(_ country: Country) {
        var target = country.longitude
        while target - longitude > 180 { target -= 360 }
        while target - longitude < -180 { target += 360 }
        withAnimation(.easeInOut(duration: 0.7)) {
            longitude = target
            latitude = min(70, max(-70, country.latitude))
        }
    }

    // MARK: - Panels

    private var entry: some View {
        VStack(spacing: 8) {
            AnswerField(placeholder: "Name a country", text: $text) {
                if let first = game.suggestions(for: text).first {
                    choose(first)
                }
            }

            ForEach(game.suggestions(for: text)) { country in
                Button {
                    choose(country)
                } label: {
                    HStack {
                        Text(country.name).bodyText()
                        Spacer()
                        Image(systemName: "arrow.up.left").foregroundColor(Theme.textSecondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.surface))
                }
            }

            HStack {
                Text(hint).caption()
                Spacer()
                Button("Give up") {
                    game.giveUp()
                    face(game.target)
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.bad)
            }
        }
    }

    private var hint: String {
        guard let best = game.ranked.first else {
            return "Any country is a good first guess."
        }
        return "Warmest so far: \(best.name)"
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            Text(game.solved ? "Found it in \(game.guesses.count)" : "It was").caption()
            Text(game.target.name)
                .bodyText(26, weight: .heavy)
                .multilineTextAlignment(.center)
            PointsBadge(points: game.score)
            Button("See result") {
                game.finish()
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    private func choose(_ country: Country) {
        game.guess(country)
        text = ""
        face(country)
        if game.solved {
            Feedback.success()
        } else {
            Feedback.tap()
        }
    }
}

/// The colour scale: icy blue when far away, through yellow, to hot pink.
/// Colour is the only clue the game gives. It never shows a distance.
enum Heat {
    static let found = Color(hex: 0x3BE38B)

    private static let stops: [(Double, Double, Double)] = [
        (0.72, 0.84, 0.98),  // far: pale ice blue
        (0.31, 0.80, 0.76),  // teal
        (0.97, 0.84, 0.36),  // yellow
        (0.96, 0.55, 0.22),  // orange
        (0.93, 0.16, 0.42)   // touching: hot pink
    ]

    static func color(_ heat: Double) -> Color {
        let t = min(1, max(0, heat)) * Double(stops.count - 1)
        let index = min(Int(t), stops.count - 2)
        let share = t - Double(index)
        let a = stops[index]
        let b = stops[index + 1]
        return Color(
            red: a.0 + (b.0 - a.0) * share,
            green: a.1 + (b.1 - a.1) * share,
            blue: a.2 + (b.2 - a.2) * share
        )
    }
}

private struct HeatLegend: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("Far").caption()
            LinearGradient(
                colors: stride(from: 0.0, through: 1.0, by: 0.1).map { Heat.color($0) },
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 8)
            .clipShape(Capsule())
            Text("Close").caption()
        }
        .accessibilityHidden(true)
    }
}

private struct GuessRow: View {
    let guess: GlobeGame.Guess

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(guess.isCorrect ? Heat.found : Heat.color(guess.heat))
                .frame(width: 44, height: 24)
            Text(guess.name)
                .bodyText(15)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 4)
            if guess.isCorrect {
                Image(systemName: "checkmark.circle.fill").foregroundColor(Heat.found)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.surface))
    }
}

/// Draws the world as a globe. It can be turned to face any place, and the
/// turning animates because the two angles are the view's animatable data.
struct GlobeCanvas: View, Animatable {
    var latitude: Double
    var longitude: Double
    /// 1 shows the whole globe. Bigger numbers move in closer.
    var zoom: Double = 1
    /// Country id to fill colour, for the countries that have been guessed.
    let fills: [Int: Color]

    var animatableData: AnimatablePair<AnimatablePair<Double, Double>, Double> {
        get { AnimatablePair(AnimatablePair(latitude, longitude), zoom) }
        set {
            latitude = newValue.first.first
            longitude = newValue.first.second
            zoom = newValue.second
        }
    }

    private static let land = Color(hex: 0x5A6CA8)
    private static let border = Color(hex: 0x1B2658)

    var body: some View {
        Canvas { context, size in
            let radius = max(min(size.width, size.height) / 2 - 10, 10) * zoom
            let centre = CGPoint(x: size.width / 2, y: size.height / 2)
            let disc = CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2)

            // Soft glow behind the planet, then the ocean.
            context.fill(
                Path(ellipseIn: disc.insetBy(dx: -8, dy: -8)),
                with: .color(Color(hex: 0x4F7CFF, opacity: 0.18))
            )
            context.fill(
                Path(ellipseIn: disc),
                with: .radialGradient(
                    Gradient(colors: [Color(hex: 0x3563D6), Color(hex: 0x14235F)]),
                    center: CGPoint(x: centre.x - radius * 0.35, y: centre.y - radius * 0.4),
                    startRadius: 0,
                    endRadius: radius * 1.6
                )
            )

            let orientation = GlobeOrientation(latitude: latitude, longitude: longitude)
            var plain = Path()
            var coloured: [(Path, Color)] = []

            for (index, rings) in Atlas.outlines.enumerated() {
                var shape = Path()
                for ring in rings {
                    var points: [CGPoint] = []
                    points.reserveCapacity(ring.count)
                    var anyVisible = false
                    for vector in ring {
                        let turned = orientation.rotate(vector)
                        if turned.z >= 0 {
                            anyVisible = true
                            points.append(CGPoint(x: centre.x + turned.x * radius, y: centre.y - turned.y * radius))
                        } else {
                            // Behind the horizon: pin the point to the rim.
                            let length = max((turned.x * turned.x + turned.y * turned.y).squareRoot(), 1e-9)
                            points.append(CGPoint(
                                x: centre.x + turned.x / length * radius,
                                y: centre.y - turned.y / length * radius
                            ))
                        }
                    }
                    guard anyVisible else { continue }
                    shape.addLines(points)
                    shape.closeSubpath()
                }
                guard !shape.isEmpty else { continue }
                if let colour = fills[index] {
                    coloured.append((shape, colour))
                } else {
                    plain.addPath(shape)
                }
            }

            context.fill(plain, with: .color(Self.land))
            context.stroke(plain, with: .color(Self.border), lineWidth: 0.6)
            for (shape, colour) in coloured {
                context.fill(shape, with: .color(colour))
                context.stroke(shape, with: .color(.white.opacity(0.85)), lineWidth: 1)
                // A guessed country too small to see gets a dot in its colour.
                let box = shape.boundingRect
                if max(box.width, box.height) < 12 {
                    let dot = CGRect(x: box.midX - 6, y: box.midY - 6, width: 12, height: 12)
                    context.fill(Path(ellipseIn: dot), with: .color(colour))
                    context.stroke(Path(ellipseIn: dot), with: .color(.white), lineWidth: 1.5)
                }
            }

            // Shading at the rim so it reads as a ball.
            context.fill(
                Path(ellipseIn: disc),
                with: .radialGradient(
                    Gradient(colors: [.clear, .clear, Color.black.opacity(0.35)]),
                    center: centre,
                    startRadius: 0,
                    endRadius: radius
                )
            )
        }
    }
}
