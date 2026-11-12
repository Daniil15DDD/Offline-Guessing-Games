import SwiftUI

struct BallparkView: View {
    @StateObject private var game = DemoMode.ballpark()
    @State private var text = ""
    @State private var multiplier = 1.0

    private let kind = GameKind.ballpark
    private let multipliers: [(String, Double)] = [
        ("x1", 1), ("thousand", 1e3), ("million", 1e6), ("billion", 1e9), ("trillion", 1e12)
    ]

    private var typedValue: Double? {
        guard let number = NumberText.parse(text), number > 0 else { return nil }
        return number * multiplier
    }

    var body: some View {
        GameChrome(
            kind: kind,
            status: "Question \(game.roundIndex + 1) of \(BallparkGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                clear()
                game.restart()
            }
        ) {
            GameColumn {
                VStack(spacing: 8) {
                    Text(game.question.text)
                        .bodyText(22, weight: .heavy)
                        .multilineTextAlignment(.center)
                    Text("Answer in \(game.question.unit)")
                        .caption()
                }
                .panel()

                if game.revealed {
                    reveal
                } else {
                    entry
                }
            }
        }
    }

    private var entry: some View {
        VStack(spacing: 12) {
            AnswerField(placeholder: "Your estimate", text: $text, numeric: true) {}

            HStack(spacing: 6) {
                ForEach(multipliers, id: \.0) { name, value in
                    Button {
                        multiplier = value
                    } label: {
                        Text(name)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(multiplier == value ? kind.accent : Theme.surfaceRaised)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(typedValue.map { "= \(NumberText.plain($0)) \(game.question.unit)" } ?? "Type a number, then pick a size.")
                .bodyText(15)
                .multilineTextAlignment(.center)

            Button("Lock in") {
                if let value = typedValue {
                    game.lockIn(value)
                    if game.lastPoints >= 70 {
                        Haptics.success()
                    } else {
                        Haptics.bump()
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
            .disabled(typedValue == nil)

            Text("One guess per question. You score by how many times too big or too small you were.")
                .caption()
                .multilineTextAlignment(.center)
        }
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            Text("The answer").caption()
            Text("\(NumberText.plain(game.question.answer)) \(game.question.unit)")
                .bodyText(24, weight: .heavy)
                .multilineTextAlignment(.center)
            Text("You said \(NumberText.plain(game.guess ?? 0)). That is \(NumberText.factor(game.factor)).")
                .caption()
                .multilineTextAlignment(.center)
            PointsBadge(points: game.lastPoints)
            Button(game.roundIndex + 1 >= BallparkGame.rounds ? "See result" : "Next question") {
                clear()
                game.next()
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    private func clear() {
        text = ""
        multiplier = 1
    }
}
