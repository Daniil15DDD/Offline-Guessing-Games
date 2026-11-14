import SwiftUI
import UIKit

struct FourfoldView: View {
    @StateObject private var game: FourfoldGame
    private let mode: PlayMode
    /// Goes up by one on each wrong guess, which plays the shake.
    @State private var shakes: CGFloat = 0

    private let kind = GameKind.fourfold
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    /// One colour per group, easiest first.
    private let groupColors = [Color(hex: 0x30B0C7), Color(hex: 0xFF9F0A), Color(hex: 0xFF375F), Color(hex: 0x5E5CE6)]

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: DemoMode.fourfold(mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
            status: "\(game.solvedGroups.count) of 4 groups",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                withAnimation(Motion.settle) {
                    game.restart()
                }
            }
        ) {
            GameColumn {
                Text("Find four groups of four words that belong together.")
                    .caption()
                    .multilineTextAlignment(.center)

                ForEach(game.solvedGroups, id: \.self) { index in
                    let group = game.puzzle.groups[index]
                    VStack(spacing: 3) {
                        Text(group.title.uppercased())
                            .font(.system(size: 14, weight: .bold))
                        Text(group.words.joined(separator: ", "))
                            .font(.system(size: 13, weight: .regular))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .padding(.horizontal, 8)
                    .background(RoundedRectangle(cornerRadius: Theme.controlRadius, style: .continuous).fill(groupColors[index % 4]))
                    .transition(Motion.pop)
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(game.board, id: \.self) { word in
                        let isSelected = game.selected.contains(word)
                        Button {
                            game.toggle(word)
                            Feedback.tap()
                        } label: {
                            Text(word)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .foregroundColor(isSelected ? .black : .white)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.controlRadius, style: .continuous)
                                        .fill(isSelected ? Color.white : Theme.fillStrong)
                                )
                        }
                        .buttonStyle(PressableButtonStyle())
                        .modifier(ShakeEffect(animatableData: isSelected ? shakes : 0))
                        .animation(Motion.quick, value: isSelected)
                        .accessibilityLabel(isSelected ? "\(word), selected" : word)
                    }
                }

                if game.isOver {
                    guessGrid
                        .transition(Motion.rise)
                    Button("See result") {
                        game.finish()
                    }
                    .buttonStyle(PrimaryButtonStyle(kind: kind))
                } else {
                    controls
                }
            }
        }
    }

    /// Every guess as four coloured squares, like a record of the game.
    private var guessGrid: some View {
        VStack(spacing: 8) {
            Text("YOUR GUESSES").eyebrow()
            VStack(spacing: 5) {
                ForEach(Array(game.history.enumerated()), id: \.offset) { _, guess in
                    HStack(spacing: 5) {
                        ForEach(Array(guess.enumerated()), id: \.offset) { _, group in
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(groupColors[group % 4])
                                .frame(width: 26, height: 26)
                        }
                    }
                }
            }
        }
        .panel()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(game.history.count) guesses made")
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Text("Mistakes left").caption()
                ForEach(0..<FourfoldGame.maxMistakes, id: \.self) { index in
                    Circle()
                        .fill(index < game.mistakesLeft ? Color.white : Theme.fillStrong)
                        .frame(width: 10, height: 10)
                        .animation(Motion.quick, value: game.mistakesLeft)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(game.mistakesLeft) mistakes left")

            Text(game.message.isEmpty ? " " : game.message)
                .bodyText(15)

            HStack(spacing: 10) {
                Button("Shuffle") {
                    withAnimation(Motion.settle) {
                        game.shuffleBoard()
                    }
                }
                .buttonStyle(SecondaryButtonStyle())

                Button("Clear") {
                    game.clearSelection()
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(game.selected.isEmpty)

                Button("Submit") {
                    let before = game.solvedGroups.count
                    let mistakesBefore = game.mistakes
                    withAnimation(Motion.settle) {
                        game.submit()
                    }
                    if game.solvedGroups.count > before && game.mistakes == mistakesBefore {
                        Feedback.success()
                    } else if game.mistakes > mistakesBefore {
                        Feedback.failure()
                        if !UIAccessibility.isReduceMotionEnabled {
                            withAnimation(.linear(duration: 0.4)) {
                                shakes += 1
                            }
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle(kind: kind))
                .disabled(game.selected.count != 4)
            }
        }
    }
}
