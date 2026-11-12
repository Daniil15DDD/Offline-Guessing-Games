import SwiftUI

struct BorderlineView: View {
    @StateObject private var game = DemoMode.borderline()
    @State private var text = ""

    private let kind = GameKind.borderline

    var body: some View {
        GameChrome(
            kind: kind,
            status: "Country \(game.roundIndex + 1) of \(BorderlineGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                text = ""
                game.restart()
            }
        ) {
            GameColumn {
                CountryShape(country: game.target)
                    .fill(kind.gradient)
                    .frame(height: 200)
                    .padding(12)
                    .panel(padding: 0)
                    .accessibilityLabel("Outline of the mystery country")

                if game.roundOver {
                    reveal
                } else {
                    entry
                }

                ForEach(game.guesses.reversed()) { guess in
                    GuessRow(guess: guess)
                }

                if game.guesses.isEmpty && !game.roundOver {
                    Text("Each guess shows how far away the answer is, and in which direction.")
                        .caption()
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    private var entry: some View {
        VStack(spacing: 8) {
            AnswerField(placeholder: "Type a country", text: $text) {
                // Return picks the top suggestion.
                if let first = game.suggestions(for: text).first {
                    choose(first)
                }
            }

            ForEach(game.suggestions(for: text)) { country in
                Button {
                    choose(country)
                } label: {
                    HStack {
                        Text(country.name).bodyText()
                        Spacer()
                        Image(systemName: "arrow.up.left").foregroundColor(Theme.textSecondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.surface))
                }
            }

            HStack {
                Text("Guess \(game.guesses.count + 1) of \(BorderlineGame.maxGuesses)").caption()
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
            Text(game.solved ? "Correct" : "It was")
                .caption()
            Text(game.target.name)
                .bodyText(26, weight: .heavy)
                .multilineTextAlignment(.center)
            PointsBadge(points: game.lastPoints)
            Button(game.roundIndex + 1 >= BorderlineGame.rounds ? "See result" : "Next country") {
                text = ""
                game.next()
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    private func choose(_ country: Country) {
        game.guess(country)
        text = ""
        if game.solved {
            Haptics.success()
        } else {
            Haptics.tap()
        }
    }
}

private struct GuessRow: View {
    let guess: BorderlineGame.Guess

    var body: some View {
        HStack(spacing: 10) {
            Text(guess.name)
                .bodyText(15)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 4)
            if guess.isCorrect {
                Image(systemName: "checkmark.circle.fill").foregroundColor(Theme.good)
            } else {
                Text("\(NumberText.grouped(Double(guess.distanceKm))) km")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(Theme.textSecondary)
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(guess.bearing))
                    .frame(width: 22)
                    .accessibilityLabel("Direction \(guess.compass)")
                Text("\(guess.proximity)%")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(guess.proximity >= 85 ? Theme.good : (guess.proximity >= 65 ? Theme.near : Theme.bad))
                    .frame(width: 44, alignment: .trailing)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.surface))
    }
}

/// Draws a country's outline, scaled to fit whatever space it is given.
struct CountryShape: Shape {
    let country: Country

    func path(in rect: CGRect) -> Path {
        let points = country.rings.flatMap { $0 }
        guard let minX = points.map(\.x).min(),
              let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(),
              let maxY = points.map(\.y).max(),
              rect.width > 0, rect.height > 0 else { return Path() }

        // Shrink east-west distances by latitude so shapes are not stretched.
        let middle = (minY + maxY) / 2
        let squeeze = max(0.2, cos(middle * .pi / 180))
        let width = max((maxX - minX) * squeeze, 0.0001)
        let height = max(maxY - minY, 0.0001)
        let scale = min(rect.width / width, rect.height / height)
        let left = rect.midX - width * scale / 2
        let top = rect.midY - height * scale / 2

        var path = Path()
        for ring in country.rings {
            for (index, point) in ring.enumerated() {
                let spot = CGPoint(
                    x: left + (point.x - minX) * squeeze * scale,
                    y: top + (maxY - point.y) * scale
                )
                if index == 0 {
                    path.move(to: spot)
                } else {
                    path.addLine(to: spot)
                }
            }
            path.closeSubpath()
        }
        return path
    }
}
