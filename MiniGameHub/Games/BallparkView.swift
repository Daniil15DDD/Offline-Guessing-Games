import SwiftUI

struct BallparkView: View {
    @StateObject private var game: BallparkGame
    private let mode: PlayMode
    @State private var text = ""
    @State private var multiplier = 1.0
    @State private var showCalculator = DemoMode.flag("calc")
    @State private var calculator = Calculator()

    private let kind = GameKind.ballpark
    private let multipliers: [(String, Double)] = [
        ("x1", 1), ("thousand", 1e3), ("million", 1e6), ("billion", 1e9), ("trillion", 1e12)
    ]

    private var typedValue: Double? {
        guard let number = NumberText.parse(text), number > 0 else { return nil }
        return number * multiplier
    }

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: BallparkGame(mode: mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
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
                    Image("hub_ballpark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .accessibilityHidden(true)
                    Text(game.question.text)
                        .bodyText(22, weight: .heavy)
                        .multilineTextAlignment(.center)
                    Text(game.question.unit.isEmpty ? "Answer with a number" : "Answer in \(game.question.unit)")
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
                        Feedback.success()
                    } else {
                        Feedback.bump()
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
            .disabled(typedValue == nil)

            Text("One guess per question. You score by how many times too big or too small you were.")
                .caption()
                .multilineTextAlignment(.center)

            Button {
                showCalculator.toggle()
            } label: {
                Label(showCalculator ? "Hide calculator" : "Calculator", systemImage: "plus.forwardslash.minus")
            }
            .buttonStyle(SecondaryButtonStyle())

            if showCalculator {
                calculatorPad
            }
        }
    }

    // MARK: - Calculator

    private var calculatorPad: some View {
        let rows: [[(String, Calculator.Key)]] = [
            [("7", .digit(7)), ("8", .digit(8)), ("9", .digit(9)), ("/", .operation(.divide))],
            [("4", .digit(4)), ("5", .digit(5)), ("6", .digit(6)), ("x", .operation(.multiply))],
            [("1", .digit(1)), ("2", .digit(2)), ("3", .digit(3)), ("-", .operation(.subtract))],
            [("0", .digit(0)), (".", .point), ("=", .equals), ("+", .operation(.add))]
        ]
        return VStack(spacing: 8) {
            HStack {
                Text(calculator.pendingSymbol ?? " ")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(kind.accent)
                Spacer()
                Text(calculator.display)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.black.opacity(0.35)))

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, key in
                        calculatorKey(key.0) {
                            calculator.press(key.1)
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                calculatorKey("C") {
                    calculator.press(.clear)
                }
                calculatorKey("Del") {
                    calculator.press(.backspace)
                }
                Button("Use this") {
                    text = calculator.display
                    multiplier = 1
                    showCalculator = false
                }
                .buttonStyle(PrimaryButtonStyle(kind: kind))
                .disabled(calculator.value <= 0)
            }
        }
        .panel(padding: 12)
    }

    private func calculatorKey(_ label: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            Feedback.tap()
        } label: {
            Text(label)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.surfaceRaised))
        }
        .buttonStyle(.plain)
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
            if game.factors.count > 1 {
                Text("Average so far: \(NumberText.factor(game.averageFactor))")
                    .caption()
            }
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
        calculator = Calculator()
        showCalculator = false
    }
}
