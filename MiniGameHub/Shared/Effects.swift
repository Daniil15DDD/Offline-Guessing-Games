import SwiftUI
import UIKit

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

/// One to three stars for a result. Earned stars pop in one after another.
struct StarRating: View {
    /// Score divided by the best possible score.
    let fraction: Double

    @State private var shown = false

    static func stars(for fraction: Double) -> Int {
        if fraction >= 0.9 { return 3 }
        if fraction >= 0.65 { return 2 }
        if fraction >= 0.35 { return 1 }
        return 0
    }

    var body: some View {
        let earned = Self.stars(for: fraction)
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                ZStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.white.opacity(0.12))
                    if index < earned {
                        Image(systemName: "star.fill")
                            .foregroundColor(Theme.star)
                            .scaleEffect(shown || UIAccessibility.isReduceMotionEnabled ? 1 : 0.2)
                            .opacity(shown ? 1 : 0)
                            .animation(Motion.bounce.delay(0.3 + 0.14 * Double(index)), value: shown)
                    }
                }
                .font(.system(size: 34, weight: .semibold))
            }
        }
        .onAppear {
            shown = true
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
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 14) {
                    GameIcon(kind: kind, size: 60)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HOW TO PLAY").eyebrow()
                        Text(kind.title)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(kind.rules.enumerated()), id: \.offset) { index, rule in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.subheadline.weight(.bold))
                                .monospacedDigit()
                                .foregroundColor(kind.accent)
                                .frame(width: 18, alignment: .leading)
                            Text(rule)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.92))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Text("A full run is worth up to \(kind.maxScore) points.")
                    .font(.footnote)
                    .foregroundColor(Theme.textSecondary)

                Button("Got it") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle(kind: kind))
            }
            .padding(.horizontal, 22)
            .padding(.top, 28)
            .padding(.bottom, 22)
        }
        .background(Theme.surface.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
