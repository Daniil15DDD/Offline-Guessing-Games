import SwiftUI

struct FourfoldView: View {
    @StateObject private var game = DemoMode.fourfold()

    private let kind = GameKind.fourfold
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    /// One colour per group, easiest first.
    private let groupColors = [Color(hex: 0x2BA6A0), Color(hex: 0xE2892F), Color(hex: 0xD9507C), Color(hex: 0x6C63E0)]

    var body: some View {
        GameChrome(
            kind: kind,
            status: "\(game.solvedGroups.count) of 4 groups",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: { game.restart() }
        ) {
            GameColumn {
                Text("Find four groups of four words that belong together.")
                    .caption()
                    .multilineTextAlignment(.center)

                ForEach(game.solvedGroups, id: \.self) { index in
                    let group = game.puzzle.groups[index]
                    VStack(spacing: 3) {
                        Text(group.title.uppercased())
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                        Text(group.words.joined(separator: ", "))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(groupColors[index % 4]))
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(game.board, id: \.self) { word in
                        let isSelected = game.selected.contains(word)
                        Button {
                            game.toggle(word)
                            Haptics.tap()
                        } label: {
                            Text(word)
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity)
                                .frame(height: 62)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(isSelected ? kind.accent : Theme.surfaceRaised)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isSelected ? "\(word), selected" : word)
                    }
                }

                if game.isOver {
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

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Text("Mistakes left").caption()
                ForEach(0..<FourfoldGame.maxMistakes, id: \.self) { index in
                    Circle()
                        .fill(index < game.mistakesLeft ? kind.accent : Theme.surfaceRaised)
                        .frame(width: 12, height: 12)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(game.mistakesLeft) mistakes left")

            Text(game.message.isEmpty ? " " : game.message)
                .bodyText(15)

            HStack(spacing: 10) {
                Button("Shuffle") {
                    game.shuffleBoard()
                }
                .buttonStyle(SecondaryButtonStyle())

                Button("Clear") {
                    game.clearSelection()
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(game.selected.isEmpty)

                Button("Submit") {
                    let before = game.solvedGroups.count
                    game.submit()
                    if game.solvedGroups.count > before && game.mistakesLeft > 0 {
                        Haptics.success()
                    } else {
                        Haptics.failure()
                    }
                }
                .buttonStyle(PrimaryButtonStyle(kind: kind))
                .disabled(game.selected.count != 4)
            }
        }
    }
}
