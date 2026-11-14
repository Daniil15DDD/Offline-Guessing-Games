import SwiftUI

struct PricePointView: View {
    @StateObject private var game: PriceGame
    private let mode: PlayMode
    @State private var text = ""

    private let kind = GameKind.price

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: PriceGame(mode: mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
            status: "Item \(game.roundIndex + 1) of \(PriceGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                text = ""
                withAnimation(Motion.settle) {
                    game.restart()
                }
            }
        ) {
            GameColumn {
                ProductCard(item: game.item)

                if game.roundOver {
                    reveal
                        .transition(Motion.rise)
                } else {
                    HStack(spacing: 8) {
                        AnswerField(placeholder: "Price in dollars", text: $text, numeric: true, onSubmit: submit)
                        Button("Guess", action: submit)
                            .buttonStyle(PrimaryButtonStyle(kind: kind))
                            .frame(width: 96)
                            .disabled(NumberText.parse(text) == nil)
                    }
                    Text("\(game.guessesLeft) guesses left").caption()
                }

                VStack(spacing: 8) {
                    ForEach(game.guesses.reversed()) { guess in
                        HStack {
                            Text(Self.money(guess.amount))
                                .font(.system(size: 17, weight: .semibold))
                                .monospacedDigit()
                                .foregroundColor(.white)
                            Spacer()
                            if guess.isClose && guess.hint != .correct {
                                Text("Close").caption()
                            }
                            Label(Self.label(guess.hint), systemImage: Self.symbol(guess.hint))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(guess.hint == .correct ? Theme.good : (guess.isClose ? Theme.near : Theme.bad))
                        }
                        .row()
                        .transition(Motion.rise)
                    }
                }
            }
        }
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            Text(game.solved ? "CLOSE ENOUGH" : "THE PRICE WAS").eyebrow()
            Text(Self.money(game.item.price))
                .bodyText(34, weight: .bold)
                .monospacedDigit()
            PointsBadge(points: game.lastPoints)
            Button(game.roundIndex + 1 >= PriceGame.rounds ? "See result" : "Next item") {
                text = ""
                withAnimation(Motion.settle) {
                    game.next()
                }
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    private func submit() {
        guard let amount = NumberText.parse(text) else { return }
        withAnimation(Motion.settle) {
            game.guess(amount)
        }
        text = ""
        if game.solved {
            Feedback.success()
        } else {
            Feedback.tap()
        }
    }

    static func money(_ amount: Double) -> String {
        if amount >= 100 {
            return "$" + NumberText.grouped(amount.rounded())
        }
        return "$" + String(format: "%.2f", amount)
    }

    private static func label(_ hint: PriceGame.Hint) -> String {
        switch hint {
        case .higher: return "Higher"
        case .lower: return "Lower"
        case .correct: return "Got it"
        }
    }

    private static func symbol(_ hint: PriceGame.Hint) -> String {
        switch hint {
        case .higher: return "arrow.up"
        case .lower: return "arrow.down"
        case .correct: return "checkmark"
        }
    }
}

/// The item on show, like a product on a shop shelf.
private struct ProductCard: View {
    let item: PriceItem

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0xFDFEFF), Color(hex: 0xDCE4F2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                // Soft shadow under the item so it sits on the surface.
                Ellipse()
                    .fill(Color.black.opacity(0.18))
                    .frame(width: 130, height: 18)
                    .blur(radius: 8)
                    .offset(y: 78)
                Image(item.art)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 168, height: 168)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 8)
            }
            .frame(height: 210)

            VStack(spacing: 5) {
                Text(item.name)
                    .bodyText(22, weight: .bold)
                    .multilineTextAlignment(.center)
                Text(item.detail)
                    .caption()
                    .multilineTextAlignment(.center)
                Text("Typical US shop price. Get within 5% to win.")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .strokeBorder(Theme.hairline, lineWidth: 0.5)
        )
        // A new item swaps in place of the old one.
        .id(item.name)
        .transition(.opacity)
        .accessibilityElement(children: .combine)
    }
}
