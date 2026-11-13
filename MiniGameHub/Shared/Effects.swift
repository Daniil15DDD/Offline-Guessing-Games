import SwiftUI

/// A burst of falling paper shown over a good result. It draws itself for a
/// few seconds and then goes away.
struct ConfettiView: View {
    let colors: [Color]

    @State private var start = Date()
    @State private var finished = false

    private static let lifetime = 3.4
    private static let pieces = 90

    var body: some View {
        Group {
            if finished {
                EmptyView()
            } else {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let elapsed = timeline.date.timeIntervalSince(start)
                        for index in 0..<Self.pieces {
                            // Three fixed pseudo-random numbers per piece.
                            let seed = Double(index)
                            let a = Self.fraction(sin(seed * 12.9898) * 43758.5453)
                            let b = Self.fraction(sin(seed * 78.233) * 12543.123)
                            let c = Self.fraction(sin(seed * 39.425) * 3141.59)

                            let time = elapsed - c * 0.6
                            guard time > 0 else { continue }
                            let x = size.width * a + sin(time * (2 + 3 * c) + seed) * 26
                            let y = -20 + (170 + 240 * b) * time + 70 * time * time
                            guard y < size.height + 20 else { continue }

                            var piece = context
                            piece.opacity = max(0, 1 - time / 3)
                            piece.translateBy(x: x, y: y)
                            piece.rotate(by: .radians(time * (3 + 5 * a)))
                            piece.fill(
                                Path(CGRect(x: -4, y: -6, width: 8, height: 12)),
                                with: .color(colors[index % max(colors.count, 1)])
                            )
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            start = Date()
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.lifetime) {
                finished = true
            }
        }
    }

    private static func fraction(_ value: Double) -> Double {
        value - floor(value)
    }
}

/// Wobbles a view from side to side. Raise `animatableData` by 1 inside
/// `withAnimation` to play it once.
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 9 * sin(animatableData * .pi * 4), y: 0))
    }
}

/// One to three stars for a result.
struct StarRating: View {
    /// Score divided by the best possible score.
    let fraction: Double

    static func stars(for fraction: Double) -> Int {
        if fraction >= 0.9 { return 3 }
        if fraction >= 0.65 { return 2 }
        if fraction >= 0.35 { return 1 }
        return 0
    }

    var body: some View {
        let earned = Self.stars(for: fraction)
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < earned ? "star.fill" : "star")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(index < earned ? Color(hex: 0xF5C542) : Theme.surfaceRaised)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(earned) of 3 stars")
    }
}

/// The "how to play" sheet behind the question mark button.
struct RulesSheet: View {
    let kind: GameKind
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    Image(kind.art)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("How to play").caption()
                        Text(kind.title)
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }

                ForEach(Array(kind.rules.enumerated()), id: \.offset) { index, rule in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(Circle().fill(kind.gradient))
                        Text(rule)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.92))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Text("A full run is worth up to \(kind.maxScore) points.")
                    .caption()

                Button("Got it") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle(kind: kind))
                .padding(.top, 4)
            }
            .padding(22)
        }
        .background(Theme.surface.ignoresSafeArea())
        .presentationDetents([.medium, .large])
    }
}
