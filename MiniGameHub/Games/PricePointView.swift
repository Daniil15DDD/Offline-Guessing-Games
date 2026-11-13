import SwiftUI

struct PricePointView: View {
    @StateObject private var game = DemoMode.price()
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
                ProductCard(item: game.item)

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
                    .bodyText(22, weight: .heavy)
                    .multilineTextAlignment(.center)
                Text(item.detail)
                    .caption()
                    .multilineTextAlignment(.center)
                Text("Typical US shop price. Get within 5% to win.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.textSecondary.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Theme.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}
