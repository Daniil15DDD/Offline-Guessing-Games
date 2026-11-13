import SwiftUI

struct ScaleItView: View {
    @StateObject private var game = DemoMode.scale()

    private let kind = GameKind.scale
    /// The larger of the two shapes is always drawn this big.
    private let fullSize: CGFloat = 190

    var body: some View {
        GameChrome(
            kind: kind,
            status: "Round \(game.roundIndex + 1) of \(ScaleGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: { game.restart() }
        ) {
            GameColumn {
                Text("Resize the \(game.pair.targetName) until the two look true to life.")
                    .bodyText(17)
                    .multilineTextAlignment(.center)

                HStack(alignment: .bottom, spacing: 18) {
                    figure(name: game.pair.referenceName, size: referenceSize, color: Color(hex: 0x8FA0D8))
                    figure(name: game.pair.targetName, size: targetSize, color: kind.accent)
                }
                .frame(height: fullSize + 50, alignment: .bottom)
                .panel()
                .animation(.easeOut(duration: 0.35), value: game.revealed)

                if game.revealed {
                    reveal
                } else {
                    Slider(value: $game.slider, in: 0...1)
                        .tint(kind.accent)
                        .accessibilityLabel("Size of the \(game.pair.targetName)")
                    Button("Lock in") {
                        game.lockIn()
                        if game.lastPoints >= 70 {
                            Haptics.success()
                        } else {
                            Haptics.bump()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(kind: kind))
                }
            }
        }
    }

    /// After the reveal the shapes snap to the real proportions.
    private var shownRatio: Double {
        game.revealed ? game.pair.ratio : game.ratio
    }

    private var referenceSize: CGFloat {
        shownRatio <= 1 ? fullSize : fullSize / CGFloat(shownRatio)
    }

    private var targetSize: CGFloat {
        shownRatio <= 1 ? fullSize * CGFloat(shownRatio) : fullSize
    }

    private func figure(name: String, size: CGFloat, color: Color) -> some View {
        VStack(spacing: 8) {
            if game.pair.shape == .circle {
                Circle()
                    .fill(color)
                    .overlay(
                        // A highlight and a shaded edge so it reads as a ball.
                        Circle().fill(
                            RadialGradient(
                                colors: [.white.opacity(0.55), .white.opacity(0), .black.opacity(0.28)],
                                center: UnitPoint(x: 0.32, y: 0.28),
                                startRadius: 0,
                                endRadius: max(size, 2) * 0.75
                            )
                        )
                    )
                    .frame(width: max(size, 2), height: max(size, 2))
            } else {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous).fill(
                            LinearGradient(
                                colors: [.white.opacity(0.35), .white.opacity(0), .black.opacity(0.25)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )
                    .frame(width: 44, height: max(size, 2))
            }
            Text(name)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(height: 34)
        }
        .frame(maxWidth: .infinity)
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            Text("\(game.pair.referenceName): \(NumberText.plain(game.pair.referenceSize)) \(game.pair.unit)")
                .caption()
                .multilineTextAlignment(.center)
            Text("\(game.pair.targetName): \(NumberText.plain(game.pair.targetSize)) \(game.pair.unit)")
                .caption()
                .multilineTextAlignment(.center)
            Text("You made it \(NumberText.trimmed(game.ratio, maxDecimals: 2)) times the size. It is really \(NumberText.trimmed(game.pair.ratio, maxDecimals: 2)) times.")
                .bodyText(15)
                .multilineTextAlignment(.center)
            PointsBadge(points: game.lastPoints)
            Button(game.roundIndex + 1 >= ScaleGame.rounds ? "See result" : "Next pair") {
                game.next()
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }
}
