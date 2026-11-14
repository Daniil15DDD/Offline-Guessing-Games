import SwiftUI

struct BallparkView: View {
    @StateObject private var game: BallparkGame
    private let mode: PlayMode
    @State private var text = ""
    @State private var multiplier = 1.0
    @State private var showCalculator = false
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
                withAnimation(Motion.settle) {
                    game.restart()
                }
            }
        ) {
            GameColumn {
                VStack(spacing: 8) {
                    Text("QUESTION \(game.roundIndex + 1)").eyebrow()
                    Text(game.question.text)
                        .bodyText(24, weight: .bold)
                        .multilineTextAlignment(.center)
                    Text(game.question.unit.isEmpty ? "Answer with a number" : "Answer in \(game.question.unit)")
                        .caption()
                }
                .panel(padding: 20)

                if game.revealed {
                    reveal
                        .transition(Motion.rise)
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
                        Feedback.tap()
                    } label: {
                        Text(name)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .foregroundColor(multiplier == value ? .black : .white)
                            .frame(maxWidth: .infinity, minHeight: 38)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.chipRadius, style: .continuous)
                                    .fill(multiplier == value ? Color.white : Theme.fillStrong)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .animation(Motion.quick, value: multiplier)
                    .accessibilityAddTraits(multiplier == value ? .isSelected : [])
                }
            }

            Text(typedValue.map { "= \(NumberText.plain($0)) \(game.question.unit)" } ?? "Type a number, then pick a size.")
                .bodyText(15)
                .multilineTextAlignment(.center)

            Button("Lock in") {
                if let value = typedValue {
                    withAnimation(Motion.settle) {
                        game.lockIn(value)
                    }
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
                withAnimation(Motion.settle) {
                    showCalculator.toggle()
                }
            } label: {
                Label(showCalculator ? "Hide calculator" : "Calculator", systemImage: "plus.forwardslash.minus")
            }
            .buttonStyle(SecondaryButtonStyle())

            if showCalculator {
                calculatorPad
                    .transition(Motion.rise)
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
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(kind.accent)
                Spacer()
                Text(calculator.display)
                    .font(.system(size: 30, weight: .light))
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.black.opacity(0.3)))

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
                    withAnimation(Motion.settle) {
                        showCalculator = false
                    }
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
                .font(.system(size: 21, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(RoundedRectangle(cornerRadius: Theme.controlRadius, style: .continuous).fill(Theme.fillStrong))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            Text("THE ANSWER").eyebrow()
            Text("\(NumberText.plain(game.question.answer)) \(game.question.unit)")
                .bodyText(26, weight: .bold)
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
                withAnimation(Motion.settle) {
                    game.next()
                }
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
