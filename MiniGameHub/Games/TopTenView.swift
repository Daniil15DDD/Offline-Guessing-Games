import SwiftUI

struct TopTenView: View {
    @StateObject private var game = TopTenGame()
    @State private var text = ""

    private let kind = GameKind.topTen

    var body: some View {
        GameChrome(
            kind: kind,
            status: "\(game.found.count) of 10 found",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                text = ""
                game.restart()
            }
        ) {
            GameColumn {
                VStack(spacing: 6) {
                    Text(game.list.title)
                        .bodyText(22, weight: .heavy)
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
                } else {
                    entry
                }

                VStack(spacing: 6) {
                    ForEach(Array(game.list.entries.enumerated()), id: \.offset) { index, entry in
                        row(rank: index + 1, entry: entry, found: game.found.contains(index))
                    }
                }

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
                    Image(systemName: index < game.livesLeft ? "heart.fill" : "heart")
                        .foregroundColor(index < game.livesLeft ? Theme.bad : Theme.surfaceRaised)
                }
                Text(game.message)
                    .caption()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Button("Give up") {
                    game.giveUp()
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.bad)
            }
            .accessibilityElement(children: .contain)
        }
    }

    private func row(rank: Int, entry: TopTenEntry, found: Bool) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundColor(found ? .white : Theme.textSecondary)
                .frame(width: 26)
            if found {
                Text(entry.name).bodyText(16)
            } else if game.isOver {
                Text(entry.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.bad)
            } else {
                Text(" ").bodyText(16)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(found ? kind.accent.opacity(0.35) : Theme.surface)
        )
    }

    private func submit() {
        let outcome = game.submit(text)
        switch outcome {
        case .correct:
            Haptics.success()
            text = ""
        case .wrong:
            Haptics.failure()
            text = ""
        case .alreadyFound, .alreadyTried:
            text = ""
        case .ignored:
            break
        }
    }
}
