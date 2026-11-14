import SwiftUI

struct TopTenView: View {
    @StateObject private var game: TopTenGame
    private let mode: PlayMode
    @State private var text = ""

    private let kind = GameKind.topTen

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: DemoMode.topTen(mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
            status: "\(game.found.count) of 10 found",
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
                VStack(spacing: 6) {
                    Text("TOP TEN").eyebrow()
                    Text(game.list.title)
                        .bodyText(24, weight: .bold)
                        .multilineTextAlignment(.center)
                    Text(game.list.basis)
                        .caption()
                        .multilineTextAlignment(.center)
                }
                .panel()

                if game.isOver {
                    Button("See result") {
                        game.finish()
                    }
                    .buttonStyle(PrimaryButtonStyle(kind: kind))
                    .transition(Motion.rise)
                } else {
                    entry
                }

                VStack(spacing: 0) {
                    ForEach(Array(game.list.entries.enumerated()), id: \.offset) { index, entry in
                        row(rank: index + 1, entry: entry, found: game.found.contains(index))
                        if index < game.list.entries.count - 1 {
                            Rectangle()
                                .fill(Theme.hairline)
                                .frame(height: 0.5)
                                .padding(.leading, 52)
                        }
                    }
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                        .strokeBorder(Theme.hairline, lineWidth: 0.5)
                )

                if !game.wrongGuesses.isEmpty {
                    Text("Not on the list: " + game.wrongGuesses.joined(separator: ", "))
                        .caption()
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    private var entry: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                AnswerField(placeholder: "Type an answer", text: $text, onSubmit: submit)
                Button("Guess", action: submit)
                    .buttonStyle(PrimaryButtonStyle(kind: kind))
                    .frame(width: 96)
            }

            HStack(spacing: 5) {
                ForEach(0..<TopTenGame.maxWrong, id: \.self) { index in
                    Image(systemName: "heart.fill")
                        .font(.footnote)
                        .foregroundColor(index < game.livesLeft ? Theme.bad : Theme.fillStrong)
                        .animation(Motion.quick, value: game.livesLeft)
                }
                Text(game.message)
                    .caption()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Button("Give up") {
                    withAnimation(Motion.settle) {
                        game.giveUp()
                    }
                }
                .font(.system(size: 15))
                .foregroundColor(Theme.bad)
            }
            .padding(.horizontal, 4)
            .accessibilityElement(children: .contain)
        }
    }

    private func row(rank: Int, entry: TopTenEntry, found: Bool) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.system(size: 15, weight: .semibold))
                .monospacedDigit()
                .foregroundColor(found ? kind.accent : Theme.textTertiary)
                .frame(width: 26)
            if found {
                Text(entry.name)
                    .bodyText(16)
                    .transition(Motion.rise)
            } else if game.isOver {
                Text(entry.name)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textSecondary)
                    .transition(.opacity)
            } else {
                Text(" ").bodyText(16)
            }
            Spacer()
            if found {
                Image(systemName: "checkmark")
                    .font(.footnote.weight(.bold))
                    .foregroundColor(kind.accent)
                    .transition(Motion.pop)
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 44)
        .background(kind.accent.opacity(found ? 0.14 : 0))
    }

    private func submit() {
        var outcome = TopTenGame.Outcome.ignored
        withAnimation(Motion.settle) {
            outcome = game.submit(text)
        }
        switch outcome {
        case .correct:
            Feedback.success()
            text = ""
        case .wrong:
            Feedback.failure()
            text = ""
        case .alreadyFound, .alreadyTried:
            text = ""
        case .ignored:
            break
        }
    }
}
