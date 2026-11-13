import Foundation
import Combine

/// Fourfold: sort sixteen words into four hidden groups of four.
final class FourfoldGame: ObservableObject {
    static let maxMistakes = 4
    static let maxScore = 500

    @Published private(set) var puzzle: GroupPuzzle
    /// Tiles still on the board, in display order.
    @Published private(set) var board: [String] = []
    @Published private(set) var selected: [String] = []
    /// Group indexes in the order they were completed or revealed.
    @Published private(set) var solvedGroups: [Int] = []
    @Published private(set) var foundByPlayer = 0
    @Published private(set) var mistakes = 0
    @Published private(set) var message = ""
    /// The board is complete (won or out of mistakes).
    @Published private(set) var isOver = false
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    let mode: PlayMode
    private var tried: Set<String> = []

    init(mode: PlayMode = .free) {
        self.mode = mode
        self.puzzle = GroupPuzzles.all[0]
        deal()
    }

    func restart() {
        deal()
    }

    private func deal() {
        var dealer = Dealer(key: "fourfold", mode: mode)
        puzzle = GroupPuzzles.puzzle(number: dealer.index(count: GroupPuzzles.poolSize))
        board = dealer.shuffled(puzzle.words)
        selected = []
        solvedGroups = []
        foundByPlayer = 0
        mistakes = 0
        message = ""
        isOver = false
        score = 0
        isFinished = false
        tried = []
    }

    var mistakesLeft: Int { Self.maxMistakes - mistakes }

    func toggle(_ word: String) {
        guard !isOver, board.contains(word) else { return }
        if let index = selected.firstIndex(of: word) {
            selected.remove(at: index)
        } else if selected.count < 4 {
            selected.append(word)
        }
        message = ""
    }

    func clearSelection() {
        selected = []
    }

    func shuffleBoard() {
        board.shuffle()
    }

    func submit() {
        guard !isOver, selected.count == 4 else { return }
        let key = selected.sorted().joined(separator: "|")
        guard !tried.contains(key) else {
            message = "Already tried that set"
            return
        }
        tried.insert(key)

        // How many of the four picks sit in each group.
        var best = 0
        var bestGroup = 0
        for (index, group) in puzzle.groups.enumerated() {
            let count = selected.filter { group.words.contains($0) }.count
            if count > best {
                best = count
                bestGroup = index
            }
        }

        if best == 4 {
            complete(group: bestGroup)
            foundByPlayer += 1
            message = ""
            if solvedGroups.count == puzzle.groups.count {
                score = foundByPlayer * 100 + mistakesLeft * 25
                isOver = true
            }
        } else {
            mistakes += 1
            message = best == 3 ? "One away" : "Not a group"
            if mistakes >= Self.maxMistakes {
                selected = []
                for index in puzzle.groups.indices where !solvedGroups.contains(index) {
                    complete(group: index)
                }
                score = foundByPlayer * 100
                message = "Out of guesses"
                isOver = true
            }
        }
    }

    private func complete(group index: Int) {
        let words = puzzle.groups[index].words
        board.removeAll { words.contains($0) }
        selected.removeAll { words.contains($0) }
        solvedGroups.append(index)
    }

    func finish() {
        guard isOver else { return }
        isFinished = true
    }
}
