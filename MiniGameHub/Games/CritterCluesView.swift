import SwiftUI

struct CritterCluesView: View {
    @StateObject private var game = DemoMode.critter()
    @State private var text = ""

    private let kind = GameKind.critter
    private let headings = ["Class", "Diet", "Home", "Legs", "Region", "Weight"]

    var body: some View {
        GameChrome(
            kind: kind,
            status: "Guess \(min(game.rows.count + 1, CritterGame.maxGuesses)) of \(CritterGame.maxGuesses)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                text = ""
                game.restart()
            }
        ) {
            GameColumn {
                if game.isOver {
                    reveal
                } else {
                    entry
                }

                if game.rows.isEmpty {
                    Text("Guess any animal. Green means that trait matches the mystery animal, amber means partly, and arrows say whether the answer has more or less.")
                        .caption()
                        .multilineTextAlignment(.center)
                } else {
                    HStack(spacing: 4) {
                        ForEach(headings, id: \.self) { heading in
                            Text(heading.uppercased())
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.textSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    ForEach(game.rows.reversed()) { row in
                        ClueRow(row: row)
                    }
                }
            }
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
                    HStack {
                        Text(critter.name).bodyText()
                        Spacer()
                        Image(systemName: "arrow.up.left").foregroundColor(Theme.textSecondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.surface))
                }
            }
            HStack {
                Text("\(Critters.all.count) animals to choose from").caption()
                Spacer()
                Button("Give up") {
                    game.giveUp()
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.bad)
            }
        }
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            Text(game.solved ? "You found it" : "It was").caption()
            Text(game.target.name)
                .bodyText(26, weight: .heavy)
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
        game.guess(critter)
        text = ""
        if game.solved {
            Haptics.success()
        } else {
            Haptics.tap()
        }
    }
}

private struct ClueRow: View {
    let row: CritterGame.Row

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(row.critter.name).bodyText(15)
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
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
    }

    private func cell(_ text: String, _ mark: CritterGame.Mark) -> some View {
        VStack(spacing: 2) {
            Text(text)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
            if mark == .higher {
                Image(systemName: "arrow.up").font(.system(size: 10, weight: .heavy))
            } else if mark == .lower {
                Image(systemName: "arrow.down").font(.system(size: 10, weight: .heavy))
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
        case .miss, .higher, .lower: return Theme.surfaceRaised
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
        return "\(NumberText.trimmed(kilograms * 1000, maxDecimals: 1)) g"
    }
}
