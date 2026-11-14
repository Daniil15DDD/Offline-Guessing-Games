import SwiftUI

struct ScaleItView: View {
    @StateObject private var game: ScaleGame
    private let mode: PlayMode

    private let kind = GameKind.scale
    /// The space each outline may use.
    private let maxHeight: CGFloat = 190
    private let maxWidth: CGFloat = 150

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: ScaleGame(mode: mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
            status: "Round \(game.roundIndex + 1) of \(ScaleGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: { game.restart() }
        ) {
            GameColumn {
                VStack(spacing: 4) {
                    Text("\(game.pair.targetName) next to \(game.pair.referenceName)")
                        .bodyText(20, weight: .bold)
                        .multilineTextAlignment(.center)
                    Text("Slide until the one on the right is its true size.")
                        .caption()
                        .multilineTextAlignment(.center)
                }

                HStack(alignment: .bottom, spacing: 14) {
                    figure(name: game.pair.referenceName, outline: game.pair.referenceOutline,
                           height: referenceHeight, color: Color(white: 0.78))
                    figure(name: game.pair.targetName, outline: game.pair.targetOutline,
                           height: targetHeight, color: kind.accent)
                }
                .frame(height: maxHeight + 52, alignment: .bottom)
                .panel()
                // The outline follows the slider exactly while it is dragged.
                // Only the jump to the real size on reveal is animated.
                .animation(Motion.settle, value: game.revealed)

                if game.revealed {
                    reveal
                        .transition(Motion.rise)
                } else {
                    Slider(value: $game.slider, in: 0...1)
                        .tint(kind.accent)
                        .accessibilityLabel("Size of \(game.pair.targetName)")
                    Button("Lock in") {
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
                }
            }
        }
    }

    /// After the reveal the outlines snap to the real proportions.
    private var shownRatio: CGFloat {
        CGFloat(game.revealed ? game.pair.ratio : game.ratio)
    }

    /// The tallest either outline may be drawn so that both still fit their
    /// half of the card, even when one of them is very wide.
    private var fullHeight: CGFloat {
        let widest = max(Silhouettes.aspect(for: game.pair.referenceOutline),
                         Silhouettes.aspect(for: game.pair.targetOutline))
        return min(maxHeight, maxWidth / max(widest, 0.01))
    }

    private var referenceHeight: CGFloat {
        shownRatio <= 1 ? fullHeight : fullHeight / shownRatio
    }

    private var targetHeight: CGFloat {
        shownRatio <= 1 ? fullHeight * shownRatio : fullHeight
    }

    private func figure(name: String, outline: String, height: CGFloat, color: Color) -> some View {
        VStack(spacing: 8) {
            SilhouetteView(key: outline, height: max(height, 2), color: color)
            Text(name)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(height: 34)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
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
                withAnimation(Motion.settle) {
                    game.next()
                }
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }
}
