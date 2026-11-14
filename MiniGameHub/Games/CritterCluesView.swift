import SwiftUI

struct CritterCluesView: View {
    @StateObject private var game: CritterGame
    private let mode: PlayMode
    @State private var text = ""

    private let kind = GameKind.critter
    private let headings = ["Class", "Diet", "Home", "Legs", "Region", "Weight"]

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: CritterGame(mode: mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
            status: "Guess \(min(game.rows.count + 1, CritterGame.maxGuesses)) of \(CritterGame.maxGuesses)",
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
                if game.isOver {
                    reveal
                        .transition(Motion.rise)
                } else {
                    entry
                }

                if game.rows.isEmpty {
                    if !game.isOver {
                        VStack(spacing: 10) {
                            legend(Theme.good, "Green", "That trait matches the mystery animal.")
                            legend(Theme.near, "Amber", "It partly matches, such as one shared region.")
                            legend(Theme.fillStrong, "Arrows", "The answer has more or fewer legs, or weighs more or less.")
                        }
                        .panel()
                    }
                } else {
                    HStack(spacing: 4) {
                        ForEach(headings, id: \.self) { heading in
                            Text(heading.uppercased())
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 10)
                    ForEach(game.rows.reversed()) { row in
                        ClueRow(row: row)
                            .transition(Motion.rise)
                    }
                }
            }
        }
    }

    /// One line of the key shown before the first guess.
    private func legend(_ colour: Color, _ name: String, _ meaning: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(colour)
                .frame(width: 14, height: 14)
                .alignmentGuide(.firstTextBaseline) { $0[.bottom] - 1 }
            Text(name)
                .bodyText(15)
                .frame(width: 58, alignment: .leading)
            Text(meaning)
                .font(.system(size: 15))
                .foregroundColor(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private var entry: some View {
        VStack(spacing: 8) {
            AnswerField(placeholder: "Type an animal", text: $text) {
                if let first = game.suggestions(for: text).first {
                    choose(first)
                }
            }
            ForEach(game.suggestions(for: text)) { critter in
                Button {
                    choose(critter)
                } label: {
                    HStack(spacing: 10) {
                        Image(critter.art)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text(critter.name).bodyText(16, weight: .regular)
                        Spacer()
                        Image(systemName: "arrow.up.left")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(Theme.textTertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.fill))
                }
                .buttonStyle(PressableButtonStyle())
            }
            HStack {
                Text("\(Critters.all.count) animals to choose from").caption()
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
        }
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            Image(game.target.art)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            Text(game.solved ? "YOU FOUND IT" : "IT WAS").eyebrow()
            Text(game.target.name)
                .bodyText(28, weight: .bold)
                .multilineTextAlignment(.center)
            PointsBadge(points: game.score)
            Button("See result") {
                game.finish()
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    private func choose(_ critter: Critter) {
        withAnimation(Motion.settle) {
            game.guess(critter)
        }
        text = ""
        if game.solved {
            Feedback.success()
        } else {
            Feedback.tap()
        }
    }
}

private struct ClueRow: View {
    let row: CritterGame.Row

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Image(row.critter.art)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                Text(row.critter.name).bodyText(15)
            }
            HStack(spacing: 4) {
                cell(row.critter.group, row.group)
                cell(row.critter.diet, row.diet)
                cell(row.critter.home, row.home)
                cell("\(row.critter.legs)", row.legs)
                cell(row.critter.regions.joined(separator: ", "), row.regions)
                cell(Self.weightText(row.critter.weightKg), row.weight)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.fill))
    }

    private func cell(_ text: String, _ mark: CritterGame.Mark) -> some View {
        VStack(spacing: 2) {
            Text(text)
                .font(.system(size: 10, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
            if mark == .higher {
                Image(systemName: "arrow.up").font(.system(size: 10, weight: .bold))
            } else if mark == .lower {
                Image(systemName: "arrow.down").font(.system(size: 10, weight: .bold))
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 46)
        .padding(.horizontal, 2)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Self.color(mark)))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(text), \(Self.spoken(mark))")
    }

    private static func color(_ mark: CritterGame.Mark) -> Color {
        switch mark {
        case .match: return Theme.good
        case .partial: return Theme.near
        case .miss, .higher, .lower: return Theme.fillStrong
        }
    }

    private static func spoken(_ mark: CritterGame.Mark) -> String {
        switch mark {
        case .match: return "matches"
        case .partial: return "partly matches"
        case .miss: return "does not match"
        case .higher: return "the answer is higher"
        case .lower: return "the answer is lower"
        }
    }

    static func weightText(_ kilograms: Double) -> String {
        if kilograms >= 100 {
            return "\(NumberText.grouped(kilograms.rounded())) kg"
        }
        if kilograms >= 1 {
            return "\(NumberText.trimmed(kilograms, maxDecimals: 1)) kg"
        }
        let grams = kilograms * 1000
        return "\(NumberText.trimmed(grams, maxDecimals: grams < 1 ? 2 : 1)) g"
    }
}
