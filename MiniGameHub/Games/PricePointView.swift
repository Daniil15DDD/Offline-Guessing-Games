import SwiftUI

struct PricePointView: View {
    @StateObject private var game = PriceGame()
    @State private var text = ""

    private let kind = GameKind.price

    var body: some View {
        GameChrome(
            kind: kind,
            status: "Item \(game.roundIndex + 1) of \(PriceGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                text = ""
                game.restart()
            }
        ) {
            GameColumn {
                VStack(spacing: 6) {
                    Text(game.item.name)
                        .bodyText(24, weight: .heavy)
                        .multilineTextAlignment(.center)
                    Text(game.item.detail)
                        .caption()
                        .multilineTextAlignment(.center)
                    Text("Typical US shop price. Get within 5% to win.")
                        .caption()
                        .multilineTextAlignment(.center)
                }
                .panel()

                if game.roundOver {
                    reveal
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

                ForEach(game.guesses.reversed()) { guess in
                    HStack {
                        Text(Self.money(guess.amount))
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.white)
                        Spacer()
                        if guess.isClose && guess.hint != .correct {
                            Text("Close").caption()
                        }
                        Label(Self.label(guess.hint), systemImage: Self.symbol(guess.hint))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(guess.hint == .correct ? Theme.good : (guess.isClose ? Theme.near : Theme.bad))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.surface))
                }
            }
        }
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            Text(game.solved ? "Close enough" : "The price was").caption()
            Text(Self.money(game.item.price))
                .bodyText(30, weight: .heavy)
            PointsBadge(points: game.lastPoints)
            Button(game.roundIndex + 1 >= PriceGame.rounds ? "See result" : "Next item") {
                text = ""
                game.next()
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    private func submit() {
        guard let amount = NumberText.parse(text) else { return }
        game.guess(amount)
        text = ""
        if game.solved {
            Haptics.success()
        } else {
            Haptics.tap()
        }
    }

    private static func money(_ amount: Double) -> String {
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
