import Foundation
import Combine

/// Ten Count: name everything on a top-ten list before five wrong guesses.
final class TopTenGame: ObservableObject {
    enum Outcome: Equatable {
        case correct(rank: Int)
        case alreadyFound
        case alreadyTried
        case wrong
        case ignored
    }

    static let maxWrong = 5
    static let maxScore = 100

    @Published private(set) var list: TopTenList
    /// Indexes into `list.entries`.
    @Published private(set) var found: Set<Int> = []
    @Published private(set) var wrongGuesses: [String] = []
    @Published private(set) var message = ""
    @Published private(set) var isOver = false
    @Published private(set) var isFinished = false

    private let lists: [TopTenList]

    init(lists: [TopTenList] = TopTenLists.all) {
        precondition(!lists.isEmpty, "Ten Count needs lists")
        self.lists = lists
        self.list = lists[0]
        deal()
    }

    var score: Int { found.count * 10 }
    var livesLeft: Int { Self.maxWrong - wrongGuesses.count }

    func restart() {
        deal()
    }

    private func deal() {
        list = lists[Deck.next("topten", count: lists.count)]
        found = []
        wrongGuesses = []
        message = ""
        isOver = false
        isFinished = false
    }

    @discardableResult
    func submit(_ text: String) -> Outcome {
        let typed = TextMatch.normalize(text)
        guard !isOver, !typed.isEmpty else { return .ignored }

        if let index = TextMatch.bestMatch(text, in: list.entries.map(\.spellings)) {
            if found.contains(index) {
                message = "\(list.entries[index].name) is already on the board"
                return .alreadyFound
            }
            found.insert(index)
            message = "Yes, number \(index + 1)"
            if found.count == list.entries.count {
                isOver = true
            }
            return .correct(rank: index + 1)
        }

        if wrongGuesses.contains(where: { TextMatch.normalize($0) == typed }) {
            message = "You already tried that"
            return .alreadyTried
        }
        wrongGuesses.append(text.trimmingCharacters(in: .whitespacesAndNewlines))
        message = "Not on the list"
        if wrongGuesses.count >= Self.maxWrong {
            isOver = true
        }
        return .wrong
    }

    func giveUp() {
        guard !isOver else { return }
        isOver = true
    }

    func finish() {
        guard isOver else { return }
        isFinished = true
    }
}
