import SwiftUI

struct RareFindView: View {
    @StateObject private var game = RareGame()
    @State private var text = ""

    private let kind = GameKind.rare
    private let clock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        GameChrome(
            kind: kind,
            status: "Prompt \(game.roundIndex + 1) of \(RareGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                text = ""
                game.restart()
            }
        ) {
            GameColumn {
                VStack(spacing: 12) {
                    Text(game.prompt.text)
                        .bodyText(24, weight: .heavy)
                        .multilineTextAlignment(.center)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.surfaceRaised)
                            Capsule()
                                .fill(game.timeLeft > 8 ? kind.accent : Theme.bad)
                                .frame(width: geometry.size.width * CGFloat(game.timeLeft / RareGame.secondsPerPrompt))
                        }
                    }
                    .frame(height: 8)
                    .accessibilityLabel("\(Int(game.timeLeft.rounded(.up))) seconds left")
                }
                .panel()

                if game.roundOver {
                    reveal
                } else {
                    HStack(spacing: 8) {
                        AnswerField(placeholder: "Your answer", text: $text, onSubmit: submit)
                        Button("Go", action: submit)
                            .buttonStyle(PrimaryButtonStyle(kind: kind))
                            .frame(width: 80)
                    }
                    Text("Any accepted answer scores. The less obvious it is, the more it is worth, up to 100.")
                        .caption()
                        .multilineTextAlignment(.center)
                    if !game.rejected.isEmpty {
                        Text("Not accepted: " + game.rejected.joined(separator: ", "))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.bad)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .onReceive(clock) { now in
            game.tick(now: now)
        }
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            if let answer = game.accepted {
                Text(RarePrompts.tierNames[answer.tier - 1].uppercased())
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(kind.accent)
                Text(answer.name)
                    .bodyText(24, weight: .heavy)
                    .multilineTextAlignment(.center)
            } else {
                Text("Out of time").bodyText(22, weight: .heavy)
            }
            PointsBadge(points: game.lastPoints)
            if !game.rarestExamples.isEmpty {
                Text("Among the rarest answers: " + game.rarestExamples.joined(separator: ", "))
                    .caption()
                    .multilineTextAlignment(.center)
            }
            Button(game.roundIndex + 1 >= RareGame.rounds ? "See result" : "Next prompt") {
                text = ""
                game.next()
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    private func submit() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if game.submit(text) {
            Haptics.success()
        } else {
            Haptics.failure()
        }
        text = ""
    }
}
